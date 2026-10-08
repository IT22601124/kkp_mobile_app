import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dsr_models.dart';
import '../models/shop_model.dart';
import '../provider/shop_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/outlet_card.dart';

class RouteOutletsScreen extends StatefulWidget {
  final Function(Outlet) onSelectOutletForInvoice;

  const RouteOutletsScreen({super.key, required this.onSelectOutletForInvoice});

  @override
  State<RouteOutletsScreen> createState() => _RouteOutletsScreenState();
}

class _RouteOutletsScreenState extends State<RouteOutletsScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShopProvider>().getTodayVisitedShops();
    });
  }

  Outlet _convertToOutlet(ShopModel shop) {
    return Outlet(
      id: shop.id,
      shopName: shop.shopName,
      ownerName: shop.ownerName,
      phone: shop.phone,
      address: shop.address,
      routeName: 'Route #${shop.routeId}',
      category: shop.status.isNotEmpty ? shop.status : 'Active Outlet',
      status: OutletStatus.visited,
      outstandingBalance: shop.currentCreditBalance,
    );
  }

  void _showCheckInDialog(Outlet outlet) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.pin_drop, color: AppColors.primaryOrange),
            SizedBox(width: 10),
            Expanded(child: Text('GPS Check-in', style: TextStyle(fontSize: 16))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Confirm outlet arrival check-in for:'),
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
                  Text('GPS Accuracy: Verified', style: TextStyle(fontSize: 12, color: AppColors.emeraldSuccess)),
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

    return Consumer<ShopProvider>(
      builder: (context, shopProvider, _) {
        final rawShops = shopProvider.todayVisitedShops;
        final outlets = rawShops.map(_convertToOutlet).toList();

        final filteredOutlets = outlets.where((o) {
          return o.shopName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              o.ownerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              o.phone.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Refresh Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Shops Visited Today (${filteredOutlets.length})',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextMain : AppColors.lightTextMain,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20, color: AppColors.primaryOrange),
                    onPressed: () => shopProvider.getTodayVisitedShops(),
                    tooltip: 'Refresh Today Visited Shops',
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Search Field
              TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  hintText: 'Search visited shop or owner...',
                  hintStyle: TextStyle(fontSize: 12),
                  prefixIcon: Icon(Icons.search, color: AppColors.darkTextSub, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                ),
              ),
              const SizedBox(height: 12),

              // Outlets List or Empty State
              Expanded(
                child: shopProvider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.primaryOrange),
                      )
                    : filteredOutlets.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.store_mall_directory_outlined,
                                      size: 56, color: Colors.grey.shade400),
                                  const SizedBox(height: 12),
                                  Text(
                                    _searchQuery.isNotEmpty
                                        ? 'No visited shops matching "$_searchQuery"'
                                        : 'No shops visited today yet',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'When a sale is recorded today for a shop, it will appear here under Today Shops.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: () => shopProvider.getTodayVisitedShops(),
                                    icon: const Icon(Icons.refresh, size: 16),
                                    label: const Text('Refresh'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryOrange,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
      },
    );
  }
}
