import 'package:flutter/material.dart';

import '../../models/dsr_models.dart';
import '../../screens/end_of_day_screen.dart';
import '../../screens/home_dashboard_screen.dart';
import '../../screens/invoice_creation_screen.dart';
import '../../screens/profile_settings_screen.dart';
import '../../screens/route_outlets_screen.dart';
import '../../screens/shops_hub_screen.dart';
import '../../screens/stock_requisition_screen.dart';
import '../../theme/app_theme.dart';
import '../profile_header_widget.dart';

class MainNavigationShell extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final VoidCallback onLogout;

  const MainNavigationShell({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
    required this.onLogout,
  });

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  Outlet? _selectedInvoiceOutlet;

  final DsrRepProfile _repProfile = DsrRepProfile(
    repCode: 'DSR-701',
    name: 'Nuwan Perera',
    phone: '0771234567',
    branchName: 'Colombo Central Hub',
    activeRoute: 'Dampola Route (R-01)',
  );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget currentBody;
    switch (_currentIndex) {
      case 0:
        currentBody = HomeDashboardScreen(
          profile: _repProfile,
          isDarkMode: widget.isDarkMode,
          onToggleTheme: widget.onToggleTheme,
          onNavigateTab: (idx) => setState(() => _currentIndex = idx),
        );
        break;
      case 1:
        currentBody = const StockRequisitionScreen();
        break;
      case 2:
        currentBody = ShopsHubScreen(
          isDarkMode: widget.isDarkMode,
          onToggleTheme: widget.onToggleTheme,
          onSelectOutletForInvoice: (outlet) {
            setState(() {
              _selectedInvoiceOutlet = outlet;
              _currentIndex = 6; // Go to Invoice Creation
            });
          },
        );
        break;
      case 3:
        currentBody = EndOfDayScreen(
          onEndTripSuccess: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('DSR Day Trip successfully closed and cash sheet submitted!'),
                backgroundColor: AppColors.emeraldSuccess,
              ),
            );
            setState(() => _currentIndex = 0);
          },
        );
        break;
      case 4:
        currentBody = ProfileSettingsScreen(
          profile: _repProfile,
          isDarkMode: widget.isDarkMode,
          onToggleTheme: widget.onToggleTheme,
          onLogout: widget.onLogout,
        );
        break;
      case 5:
        currentBody = RouteOutletsScreen(
          onSelectOutletForInvoice: (outlet) {
            setState(() {
              _selectedInvoiceOutlet = outlet;
              _currentIndex = 6; // Go to Invoice Creation
            });
          },
        );
        break;
      default:
        currentBody = const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      drawer: Drawer(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryOrange, Color(0xFFE03E00)],
                ),
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, size: 36, color: Colors.white),
              ),
              accountName: Text(_repProfile.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              accountEmail: Text('Rep Code: ${_repProfile.repCode} • ${_repProfile.branchName}'),
            ),
            _buildDrawerTile(0, 'Dashboard', Icons.dashboard),
            _buildDrawerTile(5, 'Route Outlets', Icons.storefront),
            _buildDrawerTile(1, 'Stock Requisition', Icons.inventory_2_outlined),
            _buildDrawerTile(2, 'Shops & Credits', Icons.storefront_outlined),
            _buildDrawerTile(3, 'End of Day Trip', Icons.shield_outlined),
            _buildDrawerTile(4, 'Settings & Profile', Icons.settings_outlined),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.roseDanger),
              title: const Text('Log Out', style: TextStyle(color: AppColors.roseDanger, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                widget.onLogout();
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Global Profile Header
            ProfileHeaderWidget(
              isDarkMode: widget.isDarkMode,
              onToggleTheme: widget.onToggleTheme,
            ),
            Expanded(child: currentBody),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InvoiceCreationScreen(initialOutlet: _selectedInvoiceOutlet),
            ),
          );
        },
        backgroundColor: AppColors.primaryOrange,
        child: const Icon(Icons.shopping_cart, color: Colors.white),
      ),
      bottomNavigationBar: _buildFloatingPillNavBar(isDark),
    );
  }

  Widget _buildFloatingPillNavBar(bool isDark) {
    final navItems = [
      {'label': 'Home', 'icon': Icons.home_rounded, 'index': 0},
      {'label': 'Stock', 'icon': Icons.view_in_ar_rounded, 'index': 1},
      {'label': 'Shops', 'icon': Icons.storefront_outlined, 'index': 2},
      {'label': 'Sheet', 'icon': Icons.swap_vert_rounded, 'index': 3},
      {'label': 'More', 'icon': Icons.more_horiz_rounded, 'index': 4},
    ];

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        height: 64,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(35),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.35 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
            if (isDark)
              BoxShadow(
                color: AppColors.darkBg.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: navItems.map((item) {
            final idx = item['index'] as int;
            final isSelected = _currentIndex == idx;
            final label = item['label'] as String;
            final icon = item['icon'] as IconData;

            return GestureDetector(
              onTap: () => setState(() => _currentIndex = idx),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: isSelected
                    ? const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
                    : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.darkBg
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.darkBg.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppColors.darkTextSub : AppColors.lightTextSub),
                      size: 20,
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDrawerTile(int index, String title, IconData icon) {
    final isSelected = _currentIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.darkBg : AppColors.darkTextSub),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppColors.darkBg : null,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        setState(() => _currentIndex = index);
        Navigator.pop(context);
      },
    );
  }
}
