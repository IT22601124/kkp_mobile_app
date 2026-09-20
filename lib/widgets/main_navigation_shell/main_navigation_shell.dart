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

  final List<String> _titles = [
    'DSR Dashboard',
    'Handheld Stock Bag',
    'Shops & Credits',
    'End of Day Sheet',
    'Reports & Settings',
    'Route Outlets',
    'Issue Invoice',
  ];

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
      case 6:
        currentBody = InvoiceCreationScreen(initialOutlet: _selectedInvoiceOutlet);
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
            _buildDrawerTile(6, 'Issue Invoice', Icons.receipt_long),
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
              profile: _repProfile,
              isDarkMode: widget.isDarkMode,
              onToggleTheme: widget.onToggleTheme,
            ),
            Expanded(child: currentBody),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() => _currentIndex = 6); // Go to Invoice / POS
        },
        backgroundColor: AppColors.primaryOrange,
        child: const Icon(Icons.shopping_cart, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex > 4 ? 0 : _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), activeIcon: Icon(Icons.shopping_bag), label: 'Sales'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: 'Stock'),
          BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), activeIcon: Icon(Icons.storefront), label: 'Shops'),
          BottomNavigationBarItem(icon: Icon(Icons.description_outlined), activeIcon: Icon(Icons.description), label: 'Sheet'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart), label: 'Reports'),
        ],
      ),
    );
  }

  Widget _buildDrawerTile(int index, String title, IconData icon) {
    final isSelected = _currentIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.primaryOrange : AppColors.darkTextSub),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppColors.primaryOrange : null,
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
