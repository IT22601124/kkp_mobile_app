import 'package:flutter/material.dart';
import '../models/dsr_models.dart';
import '../theme/app_theme.dart';
import 'all_shops_screen.dart';
import 'payment_collection_screen.dart';
import 'route_outlets_screen.dart';

class ShopsHubScreen extends StatelessWidget {
  final Function(Outlet) onSelectOutletForInvoice;
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const ShopsHubScreen({
    super.key,
    required this.onSelectOutletForInvoice,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.lightCard,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              // Sub-Tab Bar: Today Shops, All Shops & Credits
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: AppColors.amberWarning,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: isDark ? AppColors.darkTextSub : AppColors.lightTextSub,
                  dividerColor: Colors.transparent,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextMain : AppColors.lightTextMain,
                  ),
                  tabs: const [
                    Tab(text: 'Today Shops'),
                    Tab(text: 'All Shops'),
                    Tab(text: 'Credits'),
                  ],
                ),
              ),

              // TabBarView Content
              Expanded(
                child: TabBarView(
                  children: [
                    RouteOutletsScreen(onSelectOutletForInvoice: onSelectOutletForInvoice),
                    const AllShopsScreen(),
                    const PaymentCollectionScreen(),
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
