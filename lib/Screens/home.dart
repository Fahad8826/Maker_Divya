import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:makers/Controller/dashboard_controller.dart';
import 'package:makers/Screens/complaint.dart';
import 'package:makers/Screens/free_stocks.dart';
import 'package:makers/Screens/order_list.dart';
import 'package:makers/Screens/profile.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.refreshDashboard();
          // Show success message after refresh
        },
        color: Color(0xFF9B0062),
        backgroundColor: Colors.white,
        strokeWidth: 2.0,
        displacement: 40.0,
        child: CustomScrollView(
          physics:
              AlwaysScrollableScrollPhysics(), // Ensure scroll is always possible
          slivers: [
            _buildSliverAppBar(controller, size),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(size.width * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeSection(size),
                    SizedBox(height: size.height * 0.03),
                    _buildProgressCard(controller, size),
                    SizedBox(height: size.height * 0.03),
                    _buildQuickStatsSection(controller, size),
                    SizedBox(height: size.height * 0.03),
                    _buildQuickActionsSection(size),
                    SizedBox(height: size.height * 0.02),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(DashboardController controller, Size size) {
    return SliverAppBar(
      expandedHeight: size.height * 0.15,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Color(0xFF9B0062),
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 249, 2, 159),
                Color.fromARGB(200, 223, 0, 141),
                Color(0xFF9B0062),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(height: size.height * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Dashboard",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: size.width * 0.06,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Manage your business",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: size.width * 0.035,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          // Profile Button
                          Container(
                            margin: EdgeInsets.only(right: size.width * 0.02),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => Get.to(() => Profile()),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.account_circle_rounded,
                                    color: Colors.white,
                                    size: size.width * 0.045,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Logout Button
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _showLogoutDialog(controller),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.logout_rounded,
                                  color: Colors.white,
                                  size: size.width * 0.045,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.02),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFF9B0062).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.dashboard_rounded,
              color: Color(0xFF9B0062),
              size: size.width * 0.06,
            ),
          ),
          SizedBox(width: size.width * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back!',
                  style: TextStyle(
                    fontSize: size.width * 0.045,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Manage your business efficiently',
                  style: TextStyle(
                    fontSize: size.width * 0.035,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(DashboardController controller, Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up_rounded,
                color: Color(0xFF9B0062),
                size: size.width * 0.05,
              ),
              SizedBox(width: size.width * 0.02),
              Text(
                'Order Progress',
                style: TextStyle(
                  fontSize: size.width * 0.045,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.02),
          Obx(() {
            // Show loading state
            if (controller.isLoading.value ||
                controller.orderCount.value == -1) {
              return Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF9B0062),
                      ),
                      minHeight: 8,
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),
                  Text(
                    'Loading orders...',
                    style: TextStyle(
                      fontSize: size.width * 0.035,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              );
            }

            // Show actual progress
            double progress = (controller.orderCount.value / 500.0).clamp(
              0.0,
              1.0,
            );
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${controller.orderCount.value} Orders',
                      style: TextStyle(
                        fontSize: size.width * 0.04,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: size.width * 0.04,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF9B0062),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.01),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF9B0062),
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuickStatsSection(DashboardController controller, Size size) {
    return Obx(() {
      // Show loading shimmer effect for stats
      if (controller.isLoading.value) {
        return Row(
          children: [
            Expanded(child: _buildLoadingStatCard(size)),
            SizedBox(width: size.width * 0.02),
            Expanded(child: _buildLoadingStatCard(size)),
            SizedBox(width: size.width * 0.02),
            Expanded(child: _buildLoadingStatCard(size)),
            SizedBox(width: size.width * 0.02),
            Expanded(child: _buildLoadingStatCard(size)),
          ],
        );
      }

      return Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Orders',
              '${controller.orderCount.value}',
              Icons.shopping_cart_rounded,
              Color(0xFF9B0062),
              size,
            ),
          ),
          SizedBox(width: size.width * 0.02),
          Expanded(
            child: _buildStatCard(
              'Pending',
              '${controller.pendingCount.value}',
              Icons.access_time_rounded,
              Color(0xFF9B0062),
              size,
            ),
          ),
          SizedBox(width: size.width * 0.02),
          Expanded(
            child: _buildStatCard(
              'Out for Delivery',
              '${controller.outForDeliveryCount.value}',
              Icons.local_shipping_rounded,
              Color(0xFF9B0062),
              size,
            ),
          ),
          SizedBox(width: size.width * 0.02),
          Expanded(
            child: _buildStatCard(
              'Delivered',
              '${controller.inProgressCount.value}',
              Icons.check_circle_rounded,
              Color(0xFF9B0062),
              size,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildLoadingStatCard(Size size) {
    return Container(
      height: size.height * 0.15,
      padding: EdgeInsets.all(size.width * 0.03),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: size.width * 0.1,
            height: size.width * 0.1,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(height: size.height * 0.01),
          Container(
            width: size.width * 0.12,
            height: size.width * 0.04,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(height: size.height * 0.005),
          Container(
            width: size.width * 0.15,
            height: size.width * 0.025,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    Size size,
  ) {
    return Container(
      height: size.height * 0.15,
      padding: EdgeInsets.all(size.width * 0.03),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: size.width * 0.05),
          ),
          SizedBox(height: size.height * 0.01),
          Text(
            value,
            style: TextStyle(
              fontSize: size.width * 0.04,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontSize: size.width * 0.025,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: size.width * 0.045,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: size.height * 0.02),
        _buildActionCard(
          title: 'Free Stocks',
          subtitle: 'Manage inventory and stock levels',
          icon: Icons.inventory_2_rounded,
          iconColor: Color(0xFF9B0062),
          onTap: () => Get.offAll(() => FreeStocks()),
          size: size,
        ),
        _buildActionCard(
          title: 'Order List',
          subtitle: 'View and manage all orders',
          icon: Icons.list_alt_rounded,
          iconColor: Color(0xFF9B0062),
          onTap: () => Get.to(() => OrderList()),
          size: size,
        ),
        _buildActionCard(
          title: 'Complaints',
          subtitle: 'Handle customer complaints',
          icon: Icons.report_problem_rounded,
          iconColor: Color(0xFF9B0062),
          onTap: () => Get.to(() => Complaint()),
          size: size,
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
    required Size size,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: size.height * 0.015),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.05),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(size.width * 0.04),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: size.width * 0.055),
                ),
                SizedBox(width: size.width * 0.04),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: size.width * 0.04,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: size.width * 0.032,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: size.width * 0.035,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(DashboardController controller) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Logout', style: TextStyle(fontWeight: FontWeight.w600)),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF9B0062),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
