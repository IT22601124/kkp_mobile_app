import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kkp_rep_mobile_app/models/dsr_rep_profile.dart';
import 'package:kkp_rep_mobile_app/provider/auth_provider.dart';
import 'package:kkp_rep_mobile_app/provider/sales_provider.dart';
import 'package:kkp_rep_mobile_app/provider/shop_provider.dart';
import 'package:kkp_rep_mobile_app/provider/item_provider.dart';
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
  final double _monthlyTarget = 1200000.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final shopProvider = context.read<ShopProvider>();
      final salesProvider = context.read<SalesProvider>();
      final itemProvider = context.read<ItemProvider>();
      final authProvider = context.read<AuthProvider>();

      if (authProvider.user == null) {
        await authProvider.checkSavedToken();
      }
      if (authProvider.user?.repProfile == null) {
        await authProvider.fetchRepMe();
      }

      int repId =
          authProvider.user?.id ??
          authProvider.user?.repProfile?.userId ??
          authProvider.user?.repProfile?.id ??
          widget.profile.id;

      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

      final startStr = firstDayOfMonth.toIso8601String().split('T').first;
      final endStr = lastDayOfMonth.toIso8601String().split('T').first;

      await Future.wait([
        forceRefresh
            ? shopProvider.getShopsByRoute()
            : shopProvider.loadRouteShopsIfNeeded(),
        forceRefresh
            ? shopProvider.getTodayVisitedShops()
            : shopProvider.loadTodayVisitedShopsIfNeeded(),
        forceRefresh
            ? itemProvider.getRepStocks(repId)
            : itemProvider.loadRepStocksIfNeeded(repId),
        forceRefresh
            ? salesProvider.getSales(startDate: startStr, endDate: endStr)
            : salesProvider.loadSalesIfNeeded(
                startDate: startStr,
                endDate: endStr,
              ),
      ]);
    } catch (e) {
      debugPrint('Error fetching dashboard data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final shopProvider = context.watch<ShopProvider>();
    final itemProvider = context.watch<ItemProvider>();
    final salesProvider = context.watch<SalesProvider>();
    final repId =
        authProvider.user?.id ??
        authProvider.user?.repProfile?.userId ??
        authProvider.user?.repProfile?.id ??
        widget.profile.id;
    final now = DateTime.now();
    final startStr = DateTime(
      now.year,
      now.month,
      1,
    ).toIso8601String().split('T').first;
    final endStr = DateTime(
      now.year,
      now.month + 1,
      0,
    ).toIso8601String().split('T').first;
    final todayStr = DateTime(
      now.year,
      now.month,
      now.day,
    ).toIso8601String().split('T').first;
    final routeShops = shopProvider.listShops;
    final visitedShops = shopProvider.todayVisitedShops;
    final visitedShopIds = visitedShops.map((shop) => shop.id).toSet();
    final visitedRouteShopCount = routeShops
        .where((shop) => visitedShopIds.contains(shop.id))
        .length;
    final routeProgress = routeShops.isEmpty
        ? 0.0
        : visitedRouteShopCount / routeShops.length;
    final repStocks = itemProvider.repStocksRepId == repId
        ? itemProvider.listRepStocks
        : <RepStockModel>[];
    final sales = salesProvider.salesForRange(
      startDate: startStr,
      endDate: endStr,
    );
    double monthlyRevenue = 0;
    double todayRevenue = 0;
    for (final sale in sales) {
      if (sale['status'] == 'CANCELLED') continue;
      final rawAmount = sale['paid_amount'] ?? sale['total_amount'] ?? 0;
      final amount = rawAmount is num
          ? rawAmount.toDouble()
          : double.tryParse(rawAmount.toString()) ?? 0;
      monthlyRevenue += amount;
      final saleDate =
          (sale['sale_date'] ?? sale['created_at'])
              ?.toString()
              .split('T')
              .first ??
          '';
      if (saleDate == todayStr) todayRevenue += amount;
    }
    final salesLoading =
        _isLoading &&
        !salesProvider.hasLoadedSales(startDate: startStr, endDate: endStr);
    final stockLoading =
        _isLoading && !itemProvider.hasLoadedRepStocksFor(repId);
    final shopsLoading =
        _isLoading &&
        (!shopProvider.hasLoadedRouteShops ||
            !shopProvider.hasLoadedTodayVisitedShops);

    // KPI Math
    final double ratio = (monthlyRevenue / _monthlyTarget).clamp(0.0, 1.0);
    final String percentage = (ratio * 100).toStringAsFixed(0);
    final int lastDay = DateTime(now.year, now.month + 1, 0).day;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF061426), Color(0xFF0B1B30), AppColors.darkBg]
              : const [Color(0xFFF9FCFF), Color(0xFFF1F5FA), AppColors.lightBg],
          stops: const [0.0, 0.42, 1.0],
        ),
      ),
      child: RefreshIndicator(
        onRefresh: () => _loadDashboardData(forceRefresh: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSalesHero(
                monthlyRevenue: monthlyRevenue,
                todayRevenue: todayRevenue,
                percentage: percentage,
                ratio: ratio,
                lastDay: lastDay,
                month: _monthName(now.month),
                isLoading: salesLoading,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      title: 'Register Shop',
                      subtitle: '+ Add Retail Outlet',
                      icon: Icons.storefront_outlined,
                      colors: const [Color(0xFF079B88), Color(0xFF006C78)],
                      onTap: () => RegisterShopBottomSheet.show(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      title: 'Request Stock',
                      subtitle: 'Multi-Item Hub Request',
                      icon: Icons.inventory_2_outlined,
                      colors: const [Color(0xFF5661D5), Color(0xFF28328D)],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RequestStockScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // 4. Handheld Stock Balance Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Handheld Stock Balance',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (repStocks.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryOrange.withAlpha(
                              (0.15 * 255).toInt(),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${repStocks.length} Items',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryOrange,
                            ),
                          ),
                        ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => widget.onNavigateTab(1),
                    child: const Row(
                      children: [
                        Text(
                          'View All',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.primaryOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          size: 14,
                          color: AppColors.primaryOrange,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              stockLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryOrange,
                      ),
                    )
                  : repStocks.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkCard
                            : AppColors.lightCard,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'No handheld stock currently assigned.',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.darkTextSub
                              : AppColors.lightTextSub,
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 110,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: repStocks.length,
                        itemBuilder: (ctx, index) {
                          return _buildStockCard(repStocks[index], isDark);
                        },
                      ),
                    ),
              const SizedBox(height: 24),

              // 5. Route Outlets
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Route Outlets',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${routeShops.length} shops assigned for today',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.darkTextSub
                              : AppColors.lightTextSub,
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () => widget.onNavigateTab(2),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryOrange,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                    label: const Text(
                      'View all',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkCard.withValues(alpha: 0.82)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : const Color(0xFFE5EAF0),
                  ),
                  boxShadow: isDark
                      ? null
                      : [
                          BoxShadow(
                            color: const Color(
                              0xFF0F172A,
                            ).withValues(alpha: 0.05),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.emeraldSuccess.withValues(
                              alpha: 0.12,
                            ),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: const Icon(
                            Icons.route_rounded,
                            color: AppColors.emeraldSuccess,
                            size: 21,
                          ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$visitedRouteShopCount of ${routeShops.length} completed',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.darkTextMain
                                      : AppColors.lightTextMain,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                routeShops.isEmpty
                                    ? 'No outlets assigned'
                                    : '${routeShops.length - visitedRouteShopCount} visits remaining',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppColors.darkTextSub
                                      : AppColors.lightTextSub,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${(routeProgress * 100).round()}%',
                          style: const TextStyle(
                            color: AppColors.emeraldSuccess,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: routeProgress,
                        minHeight: 6,
                        backgroundColor: isDark
                            ? AppColors.darkInput
                            : const Color(0xFFE8EDF3),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.emeraldSuccess,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              shopsLoading
                  ? const SizedBox(
                      height: 88,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                    )
                  : routeShops.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : const Color(0xFFE5EAF0),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.storefront_outlined,
                            color: AppColors.primaryOrange,
                            size: 30,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No shops found for your route',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.darkTextMain
                                  : AppColors.lightTextMain,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: routeShops.take(5).length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (ctx, index) {
                        final shop = routeShops[index];
                        final isVisited = visitedShopIds.contains(shop.id);
                        return _buildOutletCard(
                          context,
                          name: shop.shopName,
                          code: shop.shopCode.isNotEmpty
                              ? shop.shopCode
                              : 'SH-${shop.id}',
                          address: shop.address,
                          isVisited: isVisited,
                          isDark: isDark,
                          onTap: () => widget.onNavigateTab(2),
                        );
                      },
                    ),
              const SizedBox(height: 80), // Padding for bottom nav / FAB
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSalesHero({
    required double monthlyRevenue,
    required double todayRevenue,
    required String percentage,
    required double ratio,
    required int lastDay,
    required String month,
    required bool isLoading,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 150,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF38D), Color(0xFFFFB31A)],
          ),
        ),
        child: Stack(
          children: [
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 48,
              child: CustomPaint(painter: _SalesWavePainter()),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 15, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Monthly Sales Revenue',
                              style: TextStyle(
                                color: Color(0xFF191300),
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 18,
                              color: Color(0xFF5A4700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '01 - $lastDay $month',
                          style: const TextStyle(
                            color: Color(0xFF6D5700),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 5),
                        if (isLoading)
                          const SizedBox(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.darkBlack,
                            ),
                          )
                        else
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'LKR ${monthlyRevenue.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppColors.darkBlack,
                                fontSize: 25,
                                height: 1.05,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ),
                        const Spacer(),
                        Row(
                          children: [
                            Text(
                              'Today: LKR ${todayRevenue.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Color(0xFF5B4700),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              width: 3,
                              height: 3,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF665000),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                '$percentage% Target Met',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF3D3100),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 78,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.62),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: const Icon(
                            Icons.bar_chart_rounded,
                            color: Color(0xFF7C6300),
                            size: 17,
                          ),
                        ),
                        const Spacer(),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 76,
                              height: 76,
                              child: CircularProgressIndicator(
                                value: ratio,
                                strokeWidth: 10,
                                strokeCap: StrokeCap.round,
                                backgroundColor: const Color(0x28A97700),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFFFFF1A0),
                                ),
                              ),
                            ),
                            Text(
                              '$percentage%',
                              style: const TextStyle(
                                color: AppColors.darkBlack,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(15),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -12,
                bottom: -15,
                child: Icon(
                  icon,
                  size: 90,
                  color: Colors.white.withValues(alpha: 0.09),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(icon, color: Colors.white, size: 23),
                    ),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.72),
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white,
                            size: 17,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  Widget _buildStockCard(RepStockModel stock, bool isDark) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withAlpha(
                    (0.15 * 255).toInt(),
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  stock.itemCode.isNotEmpty ? stock.itemCode : 'STOCK',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryOrange,
                  ),
                ),
              ),
              const Icon(
                Icons.inventory_2_outlined,
                size: 16,
                color: AppColors.primaryOrange,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            stock.itemName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextMain : AppColors.lightTextMain,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${stock.quantity}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.emeraldSuccess,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                stock.unit.isNotEmpty ? stock.unit : 'u',
                style: TextStyle(
                  fontSize: 10,
                  color: isDark
                      ? AppColors.darkTextSub
                      : AppColors.lightTextSub,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOutletCard(
    BuildContext context, {
    required String name,
    required String code,
    required String address,
    required bool isVisited,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final statusColor = isVisited
        ? AppColors.emeraldSuccess
        : AppColors.amberWarning;
    final displayAddress = address.trim().isEmpty
        ? 'Address not available'
        : address.trim();

    return Material(
      color: isDark ? AppColors.darkCard : Colors.white,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : const Color(0xFFE5EAF0),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  color: AppColors.primaryOrange,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name.trim().isEmpty ? 'Unnamed shop' : name.trim(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.darkTextMain
                                  : AppColors.lightTextMain,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isVisited
                                    ? Icons.check_circle_rounded
                                    : Icons.schedule_rounded,
                                size: 12,
                                color: statusColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isVisited ? 'Visited' : 'Pending',
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      code,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSub
                            : AppColors.lightTextSub,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: isDark
                              ? AppColors.darkTextSub
                              : AppColors.lightTextSub,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            displayAddress,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.darkTextSub
                                  : AppColors.lightTextSub,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: isDark
                              ? AppColors.darkTextSub
                              : AppColors.lightTextSub,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SalesWavePainter extends CustomPainter {
  const _SalesWavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x36F58A00);
    final path = Path()
      ..moveTo(0, size.height * 0.46)
      ..quadraticBezierTo(
        size.width * 0.12,
        size.height * 0.02,
        size.width * 0.30,
        size.height * 0.50,
      )
      ..quadraticBezierTo(
        size.width * 0.49,
        size.height * 0.98,
        size.width * 0.66,
        size.height * 0.45,
      )
      ..quadraticBezierTo(
        size.width * 0.83,
        size.height * 0.02,
        size.width,
        size.height * 0.42,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
