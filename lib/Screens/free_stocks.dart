import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:makers/Controller/free_stocks_controller.dart';
import 'package:makers/Screens/home.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

// Global CacheManager instance
final customCacheManager = CacheManager(
  Config(
    'productImageCache',
    stalePeriod: const Duration(days: 30),
    maxNrOfCacheObjects: 100,
  ),
);

class FreeStocks extends StatefulWidget {
  const FreeStocks({super.key});

  @override
  State<FreeStocks> createState() => _FreeStocksState();
}

class _FreeStocksState extends State<FreeStocks> {
  late final FreeStocksController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(FreeStocksController());
  }

  @override
  void dispose() {
    // Properly dispose all text editing controllers
    controller.disposeControllers();

    // Delete the controller from GetX memory (prevents reuse of disposed controller)
    Get.delete<FreeStocksController>();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) Get.off(() => const Dashboard());
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: _buildAppBar(controller),
        body: Column(
          children: [
            _buildSearchBar(controller),
            _buildStatsRow(),
            Expanded(child: _buildProductList(controller)),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(FreeStocksController controller) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, size: 20),
        onPressed: () => Get.to(() => const Dashboard()),
      ),
      elevation: 0,
      backgroundColor: Color(0xFF9B0062),
      foregroundColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      title: const Text(
        'Inventory Management',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          onPressed: () {
            HapticFeedback.lightImpact();
            controller.refreshProducts();
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar(FreeStocksController controller) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 6), // Reduced margin
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), // Smaller corner radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6, // Smaller blur
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) => controller.searchQuery.value = value,
        decoration: InputDecoration(
          hintText: 'Search products...',
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.grey.shade500,
            size: 20, // Smaller icon
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10, // Reduced padding
          ),
        ),
        style: const TextStyle(fontSize: 14), // Smaller text
      ),
    );
  }

  Widget _buildStatsRow() {
    return StreamBuilder<QuerySnapshot>(
      stream: controller.products.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final docs = snapshot.data!.docs;
        int totalProducts = docs.length;
        int outOfStock = 0;
        int lowStock = 0;

        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final stock = data['stock'] ?? 0;
          if (stock == 0) {
            outOfStock++;
          } else if (stock <= 5) {
            lowStock++;
          }
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _buildStatCard(
                'Total Products',
                totalProducts.toString(),
                Icons.inventory_2_rounded,
                const Color(0xFF3B82F6),
              ),
              const SizedBox(width: 8),
              _buildStatCard(
                'Low Stock',
                lowStock.toString(),
                Icons.warning_rounded,
                const Color(0xFFF59E0B),
              ),
              const SizedBox(width: 8),
              _buildStatCard(
                'Out of Stock',
                outOfStock.toString(),
                Icons.error_rounded,
                const Color(0xFFEF4444),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18), // Smaller icon
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 14, // Reduced font size
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 9, // Smaller title font
                color: color.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList(FreeStocksController controller) {
    return StreamBuilder<QuerySnapshot>(
      stream: controller.products.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(
            'No products found',
            'Add some products to get started',
            Icons.add_box_rounded,
          );
        }

        return Obx(() {
          final filteredDocs = _filterProducts(
            snapshot.data!.docs,
            controller.searchQuery.value,
          );

          if (filteredDocs.isEmpty && controller.searchQuery.isNotEmpty) {
            return _buildEmptyState(
              'No products found',
              'Try adjusting your search terms',
              Icons.search_off_rounded,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              final doc = filteredDocs[index];
              final product = doc.data() as Map<String, dynamic>;
              return _buildProductCard(controller, product, doc.id);
            },
          );
        });
      },
    );
  }

  List<QueryDocumentSnapshot> _filterProducts(
    List<QueryDocumentSnapshot> docs,
    String query,
  ) {
    if (query.isEmpty) return docs;

    return docs.where((doc) {
      final product = doc.data() as Map<String, dynamic>;
      final name = (product['name'] ?? '').toString().toLowerCase();
      final id = (product['id'] ?? '').toString().toLowerCase();
      final searchQuery = query.toLowerCase();

      return name.contains(searchQuery) || id.contains(searchQuery);
    }).toList();
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: const Color(0xFFEF4444),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please try again later',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF1E40AF), strokeWidth: 3),
          SizedBox(height: 16),
          Text(
            'Loading products...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, size: 48, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(
    FreeStocksController controller,
    Map<String, dynamic> product,
    String productId,
  ) {
    final currentStock = (product['stock'] ?? 0) as int;
    final productName = product['name']?.toString() ?? 'No name';
    final productIdDisplay = product['id']?.toString() ?? '';
    final productDescription =
        product['description']?.toString() ?? 'No description';

    final stockController = controller.stockControllers.putIfAbsent(
      productId,
      () => TextEditingController(),
    );

    if (stockController.text != currentStock.toString()) {
      stockController.text = currentStock.toString();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildProductImage(product['imageUrl']),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        productName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      _buildStockStatus(currentStock),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (productIdDisplay.isNotEmpty)
                    Text(
                      'ID: $productIdDisplay',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  const SizedBox(height: 4),
                  if (productDescription.isNotEmpty)
                    Row(
                      children: [
                        Text(
                          productDescription,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        _buildStockControls(
                          controller,
                          productId,
                          currentStock,
                          stockController,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(String? imageUrl) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: imageUrl?.isNotEmpty == true
              ? imageUrl!
              : 'https://via.placeholder.com/60x60/E5E7EB/9CA3AF?text=No+Image',
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          cacheManager: customCacheManager,
          placeholder: (context, url) => Container(
            width: 60,
            height: 60,
            color: Colors.grey.shade100,
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF1E40AF),
              ),
            ),
          ),
          errorWidget: (context, url, error) {
            return Container(
              width: 60,
              height: 60,
              color: Colors.grey.shade100,
              child: Icon(
                Icons.image_not_supported_rounded,
                color: Colors.grey.shade400,
                size: 24,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStockStatus(int stock) {
    late final Color statusColor;
    late final String statusText;
    late final IconData statusIcon;

    if (stock == 0) {
      statusColor = const Color(0xFFEF4444);
      statusText = 'Out of Stock';
      statusIcon = Icons.error_rounded;
    } else if (stock <= 5) {
      statusColor = const Color(0xFFF59E0B);
      statusText = 'Low Stock';
      statusIcon = Icons.warning_rounded;
    } else {
      statusColor = const Color(0xFF10B981);
      statusText = 'In Stock';
      statusIcon = Icons.check_circle_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 12, color: statusColor),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockControls(
    FreeStocksController controller,
    String productId,
    int currentStock,
    TextEditingController stockController,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 8),
        Container(
          width: 60,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          alignment: Alignment.center, // Ensure inner alignment
          child: TextField(
            controller: stockController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isCollapsed: true,
              contentPadding: EdgeInsets.zero,
            ),
            onSubmitted: (value) {
              final newStock = int.tryParse(value);
              if (newStock != null && newStock >= 0) {
                controller.updateStock(productId, newStock);
              } else {
                stockController.text = currentStock.toString();
              }
            },
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
