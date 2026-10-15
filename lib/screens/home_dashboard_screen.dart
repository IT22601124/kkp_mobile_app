import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kkp_rep_mobile_app/models/dsr_rep_profile.dart';
import 'package:kkp_rep_mobile_app/provider/sales_provider.dart';
import 'package:kkp_rep_mobile_app/provider/shop_provider.dart';
import 'package:kkp_rep_mobile_app/provider/item_provider.dart';
import '../models/shop_model.dart';
import '../models/rep_stock_model.dart';
import '../theme/app_theme.dart';
import '../widgets/register_shop_bottom_sheet.dart';
import '../widgets/request_stock_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
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
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  bool _isLoading = true;
  double _todayRevenue = 0.0;
  final double _dailyTarget = 50000.0;
  List<ShopModel> _routeShops = [];
  List<ShopModel> _visitedShops = [];
  List<RepStockModel> _repStocks = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDashboardData();
    });
  }

  Future<void> _fetchDashboardData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final shopProvider = context.read<ShopProvider>();
      final salesProvider = context.read<SalesProvider>();
      final itemProvider = context.read<ItemProvider>();

      // Fetch active route shops and visited shops
      await Future.wait([
        shopProvider.getShopsByRoute(),
        shopProvider.getTodayVisitedShops(),
        itemProvider.getRepStocks(widget.profile.id),
      ]);

      // Fetch today's sales
      final now = DateTime.now();
      final dateStr = DateTime(now.year, now.month, now.day).toIso8601String().split('T').first;
      final sales = await salesProvider.getSales(startDate: dateStr, endDate: dateStr);

      double rev = 0.0;
      for (var sale in sales) {
        if (sale['status'] != 'CANCELLED') {
          final amount = (sale['paid_amount'] ?? sale['total_amount'] ?? 0.0) is num
              ? (sale['paid_amount'] ?? sale['total_amount'] ?? 0.0).toDouble()
              : double.tryParse((sale['paid_amount'] ?? sale['total_amount'] ?? '0.0').toString()) ?? 0.0;
          rev += amount;
        }
      }

      if (mounted) {
        setState(() {
          _routeShops = shopProvider.listShops;
          _visitedShops = shopProvider.todayVisitedShops;
          _repStocks = itemProvider.listRepStocks;
          _todayRevenue = rev;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching dashboard data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // KPI Math
    final double ratio = (_todayRevenue / _dailyTarget).clamp(0.0, 1.0);
    final String percentage = (ratio * 100).toStringAsFixed(0);

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
                      _isLoading 
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.darkBlack))
                          : Text(
                              'LKR ${_todayRevenue.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkBlack,
                              ),
                            ),
                      const SizedBox(height: 8),
                      Text(
                        'Target: LKR ${_dailyTarget.toStringAsFixed(0)} ($percentage% Met)',
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
                        value: ratio,
                        strokeWidth: 9,
                        strokeCap: StrokeCap.round,
                        backgroundColor: isDark ? AppColors.darkBlack.withAlpha((0.15 * 255).toInt()) : AppColors.lightInput,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.darkBlack),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$percentage%',
                          style: const TextStyle(
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
                            color: AppColors.emeraldSuccess.withAlpha((0.15 * 255).toInt()),
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
                            color: AppColors.yellowLight.withAlpha((0.15 * 255).toInt()),
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
                onTap: () => widget.onNavigateTab(1),
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
          _isLoading
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryOrange))
              : _repStocks.isEmpty
                  ? const Text('No stocks available.')
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _repStocks.take(4).map((stock) {
                        return SizedBox(
                          width: (MediaQuery.of(context).size.width - 32 - 24) / 4,
                          child: _buildStockCard(
                            stock.itemName,
                            stock.quantity.toString(),
                            isDark,
                          ),
                        );
                      }).toList(),
                    ),
          const SizedBox(height: 24),

          // 5. Route Outlets
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Route Outlets (${_routeShops.length} Shops)',
                style: const TextStyle(fontSize: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.emeraldSuccess.withAlpha((0.15 * 255).toInt()),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_visitedShops.length} Visited',
                  style: const TextStyle(
                    color: AppColors.emeraldSuccess,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _isLoading
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryOrange))
              : _routeShops.isEmpty
                  ? const Text('No shops found for your route.')
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _routeShops.take(5).length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (ctx, index) {
                        final shop = _routeShops[index];
                        final bool isVisited = _visitedShops.any((v) => v.id == shop.id);
                        return _buildOutletCard(
                          context,
                          name: shop.shopName,
                          code: shop.shopCode.isNotEmpty ? shop.shopCode : 'SH-${shop.id}',
                          address: shop.address,
                          saleInfo: isVisited ? 'Visited' : 'Pending',
                          status: isVisited ? 'Visited' : 'Pending Visit',
                          isDark: isDark,
                        );
                      },
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
                    color: AppColors.emeraldSuccess.withAlpha((0.15 * 255).toInt()),
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
