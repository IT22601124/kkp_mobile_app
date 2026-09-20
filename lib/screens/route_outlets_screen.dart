import 'package:flutter/material.dart';
import '../models/dsr_models.dart';
import '../theme/app_theme.dart';
import '../widgets/outlet_card.dart';

class RouteOutletsScreen extends StatefulWidget {
  final Function(Outlet) onSelectOutletForInvoice;

  const RouteOutletsScreen({super.key, required this.onSelectOutletForInvoice});

  @override
  State<RouteOutletsScreen> createState() => _RouteOutletsScreenState();
}

class _RouteOutletsScreenState extends State<RouteOutletsScreen> {
  String _selectedRoute = 'Route R-04: Colombo North';
  String _filter = 'ALL';
  String _searchQuery = '';

  final List<String> _routes = [
    'Route R-04: Colombo North',
    'Route R-02: Kandy Expressway',
    'Route R-07: Galle Coastal',
  ];

  final List<Outlet> _outlets = [
    Outlet(
      id: 1,
      shopName: 'New City Mobile Centre',
      ownerName: 'M. F. Perera',
      phone: '0773456789',
      address: 'No 142, Main Street, Pettah, Colombo',
      routeName: 'Route R-04: Colombo North',
      category: 'A Grade Outlet',
      status: OutletStatus.visited,
      outstandingBalance: 12500.0,
    ),
    Outlet(
      id: 2,
      shopName: 'Global Telecom & Electronics',
      ownerName: 'K. S. De Silva',
      phone: '0718901234',
      address: 'No 88, Galle Road, Bambalapitiya',
      routeName: 'Route R-04: Colombo North',
      category: 'Super Outlet',
      status: OutletStatus.invoiced,
      outstandingBalance: 0.0,
    ),
    Outlet(
      id: 3,
      shopName: 'Apex Mobile & Accessories',
      ownerName: 'N. R. Jayawardena',
      phone: '0754321098',
      address: 'No 45, Highlevel Road, Nugegoda',
      routeName: 'Route R-04: Colombo North',
      category: 'B Grade Outlet',
      status: OutletStatus.pending,
      outstandingBalance: 4500.0,
    ),
    Outlet(
      id: 4,
      shopName: 'Smart Connections Shop',
      ownerName: 'S. T. Fernando',
      phone: '0761122334',
      address: 'No 12, Kandy Road, Kiribathgoda',
      routeName: 'Route R-04: Colombo North',
      category: 'A Grade Outlet',
      status: OutletStatus.pending,
      outstandingBalance: 0.0,
    ),
    Outlet(
      id: 5,
      shopName: 'Lanka Reload Centre',
      ownerName: 'R. M. Bandara',
      phone: '0729988776',
      address: 'No 204, Negombo Road, Wattala',
      routeName: 'Route R-04: Colombo North',
      category: 'C Grade Outlet',
      status: OutletStatus.skipped,
      outstandingBalance: 1890.0,
    ),
  ];

  void _showCheckInDialog(Outlet outlet) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.pin_drop, color: AppColors.primaryOrange),
            const SizedBox(width: 10),
            Expanded(child: Text('GPS Check-in', style: const TextStyle(fontSize: 16))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Confirm outlet arrival check-in for:'),
            const SizedBox(height: 6),
            Text(outlet.shopName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.emeraldSuccess.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.emeraldSuccess, size: 18),
                  SizedBox(width: 8),
                  Text('GPS Accuracy: ±3m Verified', style: TextStyle(fontSize: 12, color: AppColors.emeraldSuccess)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                outlet.status = OutletStatus.visited;
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Checked in at ${outlet.shopName}!'),
                  backgroundColor: AppColors.emeraldSuccess,
                ),
              );
            },
            child: const Text('CONFIRM CHECK-IN'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredOutlets = _outlets.where((o) {
      final matchesSearch = o.shopName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          o.ownerName.toLowerCase().contains(_searchQuery.toLowerCase());
      if (_filter == 'PENDING') return matchesSearch && o.status == OutletStatus.pending;
      if (_filter == 'VISITED') return matchesSearch && (o.status == OutletStatus.visited || o.status == OutletStatus.invoiced);
      return matchesSearch;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Search Field
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              hintText: 'Search shop name or owner...',
              hintStyle: TextStyle(fontSize: 12),
              prefixIcon: Icon(Icons.search, color: AppColors.darkTextSub, size: 20),
            ),
          ),
          const SizedBox(height: 12),

          // Outlets List
          Expanded(
            child: filteredOutlets.isEmpty
                ? const Center(
                    child: Text('No outlets found matching criteria.', style: TextStyle(color: AppColors.darkTextSub)),
                  )
                : ListView.builder(
                    itemCount: filteredOutlets.length,
                    itemBuilder: (ctx, idx) {
                      final outlet = filteredOutlets[idx];
                      return OutletCard(
                        outlet: outlet,
                        onCheckIn: () => _showCheckInDialog(outlet),
                        onSell: () => widget.onSelectOutletForInvoice(outlet),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
