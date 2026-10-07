import 'package:flutter/material.dart';
import '../models/dsr_models.dart';
import '../theme/app_theme.dart';
import '../widgets/register_shop_bottom_sheet.dart';
import '../widgets/request_stock_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  final DsrRepProfile profile;
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final Function(int) onNavigateTab;

  const HomeDashboardScreen({
    super.key,
    required this.profile,
    required this.isDarkMode,
    required this.onToggleTheme,
    required this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 2. Sales Revenue KPI Card with Circular Chart
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.yellowLight : AppColors.yellowLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TODAY SALES REVENUE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.darkBlack : AppColors.darkBlack,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'LKR 45,000.00',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkBlack,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Target: LKR 50,000 (90% Met)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.darkBlack : AppColors.darkBlack,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Circular Target Chart Indicator
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 72,
                      height: 72,
                      child: CircularProgressIndicator(
                        value: 0.9,
                        strokeWidth: 9,
                        strokeCap: StrokeCap.round,
                        backgroundColor: isDark ? AppColors.darkBlack.withAlpha(32) : AppColors.lightInput,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.darkBlack),
                      ),
                    ),
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '90%',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkBlack,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Register Shop & Request Stock Action Cards
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => RegisterShopBottomSheet.show(context),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.emeraldSuccess.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.storefront, color: AppColors.emeraldSuccess, size: 24),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Register Shop',
                          style: TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '+ Add Retail Outlet',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RequestStockScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.yellowLight.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.inventory_2_outlined, color: AppColors.darkYellow, size: 24),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Request Stock',
                          style: TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Multi-Item Hub Request',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Handheld Stock Balance',
                style: TextStyle(fontSize: 16),
              ),
              GestureDetector(
                onTap: () => onNavigateTab(1),
                child: const Row(
                  children: [
                    Text(
                      'View',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.darkYellow,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 14, color: AppColors.darkYellow),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStockCard('CARDS', '500', isDark),
              _buildStockCard('4G SIMS', '30', isDark),
              _buildStockCard('RELOAD', '117.1K', isDark, isPrimary: true),
              _buildStockCard('RELOAD', '117.1K', isDark, isPrimary: true),
            ],
          ),
          const SizedBox(height: 24),

          // 5. Route Outlets (4 Shops)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Route Outlets (4 Shops)',
                style: TextStyle(fontSize: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.emeraldSuccess.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '2 Visited',
                  style: TextStyle(
                    color: AppColors.emeraldSuccess,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildOutletCard(
            context,
            name: 'Saman Stores',
            code: 'SH-1002',
            address: 'Main Street, Dampola',
            saleInfo: 'LKR 12,500',
            status: 'Visited',
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _buildOutletCard(
            context,
            name: 'Lanka Traders',
            code: 'SH-1004',
            address: 'Market Place',
            saleInfo: 'LKR 8,400',
            status: 'Visited',
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _buildOutletCard(
            context,
            name: 'Shanika Communication',
            code: 'SH-1008',
            address: 'Bus Stand Junction',
            saleInfo: 'LKR 14,000',
            isCreditWarning: true,
            showPosButton: true,
            isDark: isDark,
            onPosTap: () => onNavigateTab(3),
          ),
          const SizedBox(height: 10),
          _buildOutletCard(
            context,
            name: 'Kandy Mini Mart',
            code: 'SH-1010',
            address: 'Temple Road',
            saleInfo: 'Pending Visit',
            isDark: isDark,
          ),
          const SizedBox(height: 80), // Padding for bottom nav / FAB
        ],
      ),
    );
  }

  Widget _buildStockCard(String title, String value, bool isDark, {bool isPrimary = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),

        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isPrimary ? AppColors.darkYellow : (isDark ? AppColors.darkTextSub : AppColors.lightTextSub),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isPrimary ? AppColors.darkYellow : (isDark ? AppColors.darkTextMain : AppColors.lightTextMain),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutletCard(
    BuildContext context, {
    required String name,
    required String code,
    required String address,
    required String saleInfo,
    String? status,
    bool isCreditWarning = false,
    bool showPosButton = false,
    required bool isDark,
    VoidCallback? onPosTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle
                ),
                child: const Icon(Icons.supervised_user_circle, color: AppColors.cyanAccent, size: 24),
              ),
              Expanded(
                child: Text(
                  overflow: TextOverflow.ellipsis,
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextMain : AppColors.lightTextMain,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(child: Text('Rs $saleInfo',style: TextStyle(fontSize: 11))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.emeraldSuccess.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check, size: 12, color: AppColors.emeraldSuccess),
                      SizedBox(width: 4),
                      Text(
                        'Visited',
                        style: TextStyle(
                          color: AppColors.emeraldSuccess,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                )

            ],
          ),

        ],
      ),
    );
  }
}
