import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:makers/Controller/order_list_controller.dart';
import 'package:makers/Screens/individual_details.dart';

class OrderList extends StatelessWidget {
  const OrderList({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    Get.put(OrderController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildSearchBar(context),
          _buildFilterChips(context),
          _buildSortOptions(context),
          Expanded(
            child: Obx(() {
              final controller = Get.find<OrderController>();
              return _buildOrdersList(context, controller);
            }),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return AppBar(
      title: Text(
        'My Orders',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      centerTitle: true,
      backgroundColor: Colors.blue[600],
      foregroundColor: Colors.white,
      elevation: 0,

      actions: [
        IconButton(
          icon: Icon(Icons.filter_list, size: isTablet ? 28 : 24),
          onPressed: () => _showFilterBottomSheet(context),
        ),
      ],
    );
  }

  Widget _buildOrdersList(BuildContext context, OrderController controller) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final crossAxisCount = isTablet ? 2 : 1;

    // Handle empty states
    if (controller.filteredOrders.isEmpty && controller.orders.isNotEmpty) {
      return _buildEmptyState(
        context: context,
        icon: Icons.filter_list_off,
        title: 'No orders match your filters',
        subtitle: 'Try adjusting your search criteria',
        action: TextButton(
          onPressed: controller.clearAllFilters,
          child: const Text('Clear Filters'),
        ),
      );
    }

    if (controller.orders.isEmpty) {
      return _buildEmptyState(
        context: context,
        icon: Icons.shopping_bag_outlined,
        title: 'No orders found',
        subtitle: 'Your orders will appear here',
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refreshOrders,
      child: isTablet
          ? _buildGridView(context, controller, crossAxisCount)
          : _buildListView(context, controller),
    );
  }

  Widget _buildListView(BuildContext context, OrderController controller) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.04;

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 16.0,
      ),
      itemCount: controller.filteredOrders.length,
      itemBuilder: (context, index) {
        final document = controller.filteredOrders[index];
        final data = document.data() as Map<String, dynamic>;
        final docId = document.id;
        return _buildOrderCard(context, data, docId);
      },
    );
  }

  Widget _buildGridView(
    BuildContext context,
    OrderController controller,
    int crossAxisCount,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.04;

    return GridView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 16.0,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: controller.filteredOrders.length,
      itemBuilder: (context, index) {
        final document = controller.filteredOrders[index];
        final data = document.data() as Map<String, dynamic>;
        final docId = document.id;
        return _buildOrderCard(context, data, docId);
      },
    );
  }

  Widget _buildEmptyState({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? action,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: isTablet ? 100 : 80, color: Colors.grey[400]),
            SizedBox(height: isTablet ? 24 : 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isTablet ? 22 : 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            if (subtitle != null) ...[
              SizedBox(height: isTablet ? 12 : 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
            if (action != null) ...[
              SizedBox(height: isTablet ? 24 : 16),
              action,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final horizontalPadding = screenWidth * 0.04;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 16,
      ),
      child: TextField(
        onChanged: (value) => Get.find<OrderController>().setSearchQuery(value),
        decoration: InputDecoration(
          hintText: 'Search orders...',
          hintStyle: TextStyle(
            fontSize: isTablet ? 16 : 14,
            color: Colors.grey[500],
          ),
          prefixIcon: Icon(
            Icons.search,
            size: isTablet ? 24 : 20,
            color: Colors.grey[600],
          ),
          suffixIcon: Obx(() {
            final controller = Get.find<OrderController>();
            return controller.searchQuery.value.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, size: isTablet ? 24 : 20),
                    onPressed: () => controller.setSearchQuery(''),
                  )
                : const SizedBox.shrink();
          }),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isTablet ? 20 : 16,
            vertical: isTablet ? 20 : 16,
          ),
        ),
        style: TextStyle(fontSize: isTablet ? 16 : 14),
      ),
    );
  }

  Widget _buildSortOptions(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final horizontalPadding = screenWidth * 0.04;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
      child: Row(
        children: [
          Text(
            'Sort by:',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Obx(() {
                final controller = Get.find<OrderController>();
                return Row(
                  children: [
                    _buildSortChip('Date', 'createdAt', controller, context),
                    SizedBox(width: isTablet ? 12 : 8),
                    _buildSortChip(
                      'Delivery',
                      'deliveryDate',
                      controller,
                      context,
                    ),
                    SizedBox(width: isTablet ? 12 : 8),
                    _buildSortChip('Order ID', 'orderId', controller, context),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(
    String label,
    String field,
    OrderController controller,
    BuildContext context,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final isSelected = controller.sortBy.value == field;

    return GestureDetector(
      onTap: () => controller.setSortBy(field),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 16 : 12,
          vertical: isTablet ? 10 : 6,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[100] : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue[300]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.blue[700] : Colors.grey[700],
              ),
            ),
            if (isSelected) ...[
              SizedBox(width: isTablet ? 6 : 4),
              Icon(
                controller.sortDescending.value
                    ? Icons.arrow_downward
                    : Icons.arrow_upward,
                size: isTablet ? 16 : 14,
                color: Colors.blue[700],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final horizontalPadding = screenWidth * 0.04;

    return Obx(() {
      final controller = Get.find<OrderController>();
      final activeFilters = <Widget>[];

      if (controller.selectedStatus.value.isNotEmpty) {
        activeFilters.add(
          _buildFilterChip(
            'Status: ${_getStatusText(controller.selectedStatus.value)}',
            controller.clearStatusFilter,
            _getStatusColor(controller.selectedStatus.value),
            context,
          ),
        );
      }

      if (controller.selectedDateRange.value != null) {
        activeFilters.add(
          _buildFilterChip(
            'Date: ${controller.getDateRangeText()}',
            controller.clearDateFilter,
            Colors.blue,
            context,
          ),
        );
      }

      if (activeFilters.isEmpty) return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 12,
        ),
        child: Wrap(
          spacing: isTablet ? 12 : 8,
          runSpacing: isTablet ? 8 : 4,
          children: [
            ...activeFilters,
            if (activeFilters.length > 1)
              ActionChip(
                label: Text(
                  'Clear All',
                  style: TextStyle(fontSize: isTablet ? 14 : 12),
                ),
                onPressed: controller.clearAllFilters,
                backgroundColor: Colors.red.withOpacity(0.1),
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 12 : 8,
                  vertical: isTablet ? 8 : 4,
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildFilterChip(
    String label,
    VoidCallback onDelete,
    Color color,
    BuildContext context,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return Chip(
      label: Text(label, style: TextStyle(fontSize: isTablet ? 14 : 12)),
      deleteIcon: Icon(Icons.close, size: isTablet ? 20 : 18),
      onDeleted: onDelete,
      backgroundColor: color.withOpacity(0.1),
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 8 : 4,
        vertical: isTablet ? 4 : 2,
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = MediaQuery.of(context).size.width >= 600;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: isTablet ? 0.6 : 0.7,
        maxChildSize: isTablet ? 0.8 : 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) =>
            _buildFilterContent(context, scrollController),
      ),
    );
  }

  Widget _buildFilterContent(
    BuildContext context,
    ScrollController scrollController,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Orders',
                style: TextStyle(
                  fontSize: isTablet ? 24 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => Get.find<OrderController>().clearAllFilters(),
                child: Text(
                  'Clear All',
                  style: TextStyle(fontSize: isTablet ? 16 : 14),
                ),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: ListView(
              controller: scrollController,
              children: [
                _buildStatusFilter(context),
                SizedBox(height: isTablet ? 24 : 20),
                _buildDateFilter(context),
                SizedBox(height: isTablet ? 24 : 20),
                _buildQuickDateFilters(context),
                SizedBox(height: isTablet ? 48 : 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: isTablet ? 20 : 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    const statuses = [
      'pending',
      'accepted',
      'inprogress',
      'sent out for delivery',
      'delivered',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Status',
          style: TextStyle(
            fontSize: isTablet ? 18 : 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: isTablet ? 16 : 12),
        Obx(() {
          final controller = Get.find<OrderController>();
          return Wrap(
            spacing: isTablet ? 12 : 8,
            runSpacing: isTablet ? 12 : 8,
            children: statuses.map((status) {
              final isSelected = controller.selectedStatus.value == status;
              return FilterChip(
                label: Text(
                  _getStatusText(status),
                  style: TextStyle(fontSize: isTablet ? 14 : 12),
                ),
                selected: isSelected,
                onSelected: (selected) =>
                    controller.setStatusFilter(selected ? status : ''),
                backgroundColor: Colors.grey[100],
                selectedColor: _getStatusColor(status).withOpacity(0.2),
                checkmarkColor: _getStatusColor(status),
                avatar: isSelected
                    ? null
                    : Icon(_getStatusIcon(status), size: isTablet ? 18 : 16),
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 12 : 8,
                  vertical: isTablet ? 8 : 4,
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildDateFilter(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range',
          style: TextStyle(
            fontSize: isTablet ? 18 : 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: isTablet ? 16 : 12),
        Obx(() {
          final controller = Get.find<OrderController>();
          return InkWell(
            onTap: controller.selectDateRange,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 20 : 16,
                vertical: isTablet ? 16 : 12,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.date_range,
                    color: Colors.grey[600],
                    size: isTablet ? 24 : 20,
                  ),
                  SizedBox(width: isTablet ? 16 : 12),
                  Expanded(
                    child: Text(
                      controller.selectedDateRange.value != null
                          ? controller.getDateRangeText()
                          : 'Select date range',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        color: controller.selectedDateRange.value != null
                            ? Colors.black87
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                  if (controller.selectedDateRange.value != null)
                    IconButton(
                      icon: Icon(Icons.clear, size: isTablet ? 24 : 20),
                      onPressed: controller.clearDateFilter,
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildQuickDateFilters(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    final quickFilters = [
      ('Today', () => Get.find<OrderController>().setTodayFilter()),
      ('This Week', () => Get.find<OrderController>().setThisWeekFilter()),
      ('This Month', () => Get.find<OrderController>().setThisMonthFilter()),
      ('Last 30 Days', () => Get.find<OrderController>().setLast30DaysFilter()),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Filters',
          style: TextStyle(
            fontSize: isTablet ? 18 : 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: isTablet ? 16 : 12),
        Wrap(
          spacing: isTablet ? 12 : 8,
          runSpacing: isTablet ? 12 : 8,
          children: quickFilters.map((filter) {
            return ActionChip(
              label: Text(
                filter.$1,
                style: TextStyle(fontSize: isTablet ? 14 : 12),
              ),
              onPressed: filter.$2,
              backgroundColor: Colors.blue[50],
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 16 : 12,
                vertical: isTablet ? 8 : 4,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    Map<String, dynamic> data,
    String docId,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final orderStatus = data['order_status']?.toString() ?? 'pending';
    final statusColor = _getStatusColor(orderStatus);
    final statusIcon = _getStatusIcon(orderStatus);

    return Card(
      margin: EdgeInsets.only(bottom: isTablet ? 12 : 8),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () =>
            Get.to(() => OrderDetailPage(orderData: data, docId: docId)),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 16 : 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Order #${data['orderId']?.toString() ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  _buildStatusBadge(
                    orderStatus,
                    statusColor,
                    statusIcon,
                    context,
                  ),
                ],
              ),
              SizedBox(height: isTablet ? 12 : 8),
              ..._buildOrderInfo(data, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(
    String status,
    Color color,
    IconData icon,
    BuildContext context,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 16 : 12,
        vertical: isTablet ? 8 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isTablet ? 16 : 14, color: color),
          SizedBox(width: isTablet ? 6 : 4),
          Text(
            _getStatusText(status),
            style: TextStyle(
              color: color,
              fontSize: isTablet ? 14 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildOrderInfo(
    Map<String, dynamic> data,
    BuildContext context,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    final infoItems = [
      (Icons.person_outline, 'Customer', data['name']?.toString() ?? 'N/A'),
      (Icons.badge, 'Customer ID', data['customerId']?.toString() ?? 'N/A'),
      (
        Icons.inventory_2_outlined,
        'Product ID',
        data['productID']?.toString() ?? 'N/A',
      ),
    ];

    return infoItems.map((item) {
      return Padding(
        padding: EdgeInsets.only(bottom: isTablet ? 8 : 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(item.$1, size: isTablet ? 18 : 16, color: Colors.grey[600]),
            SizedBox(width: isTablet ? 12 : 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.$2,
                    style: TextStyle(
                      fontSize: isTablet ? 12 : 11,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    item.$3,
                    style: TextStyle(
                      fontSize: isTablet ? 15 : 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'inprogress':
        return Colors.orange;
      case 'sent out for delivery':
        return Colors.blue;
      case 'delivered':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Icons.check_circle_outline;
      case 'inprogress':
        return Icons.build_circle_outlined;
      case 'sent out for delivery':
        return Icons.local_shipping_outlined;
      case 'delivered':
        return Icons.done_all;
      default:
        return Icons.pending_outlined;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return 'Accepted';
      case 'inprogress':
        return 'In Progress';
      case 'sent out for delivery':
        return 'Out for Delivery';
      case 'delivered':
        return 'Delivered';
      default:
        return 'Pending';
    }
  }
}
