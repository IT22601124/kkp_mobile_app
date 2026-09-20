import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../provider/shop_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/register_shop_bottom_sheet.dart';

class AllShopsScreen extends StatefulWidget {
  const AllShopsScreen({super.key});

  @override
  State<AllShopsScreen> createState() => _AllShopsScreenState();
}

class _AllShopsScreenState extends State<AllShopsScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shopProvider = Provider.of<ShopProvider>(context, listen: false);
      if (shopProvider.listShops.isEmpty) {
        shopProvider.getMyShops();
      }
    });
  }

  Future<void> _fetchShops() async {
    await Provider.of<ShopProvider>(context, listen: false).getMyShops();
  }

  Future<void> _deleteShop(int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Shop'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.roseDanger)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
      final success = await Provider.of<ShopProvider>(context, listen: false).deleteShop(id);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Shop "$name" deleted successfully'), backgroundColor: AppColors.emeraldSuccess),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete shop'), backgroundColor: AppColors.roseDanger),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<ShopProvider>(
      builder: (ctx, shopProvider, _) {
        final filteredShops = shopProvider.listShops.where((shop) {
          return shop.shopName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              shop.ownerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              shop.phone.contains(_searchQuery) ||
              shop.address.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Field & Create Button
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        hintText: 'Search all shops by name, owner, phone...',
                        hintStyle: TextStyle(fontSize: 12),
                        prefixIcon: Icon(Icons.search, color: AppColors.darkTextSub, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      RegisterShopBottomSheet.show(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Create', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Total Count Header & Refresh
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Registered Shops (${filteredShops.length})',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20, color: AppColors.cyanAccent),
                    onPressed: _fetchShops,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Shops List
              Expanded(
                child: shopProvider.isLoading
                    ? Center(
                        child: LoadingAnimationWidget.fallingDot(color: AppColors.primaryOrange, size: 40),
                      )
                    : filteredShops.isEmpty
                        ? const Center(
                            child: Text('No shops found.', style: TextStyle(color: AppColors.darkTextSub)),
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchShops,
                            child: ListView.builder(
                              itemCount: filteredShops.length,
                              itemBuilder: (ctx, idx) {
                                final shop = filteredShops[idx];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              shop.shopName,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? AppColors.darkTextMain : AppColors.lightTextMain,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryOrange.withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              shop.shopCode,
                                              style: const TextStyle(
                                                color: AppColors.primaryOrange,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            onPressed: () => _deleteShop(shop.id, shop.shopName),
                                            icon: const Icon(Icons.delete_outline, color: AppColors.roseDanger, size: 20),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Owner: ${shop.ownerName} • Phone: ${shop.phone}',
                                        style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Address: ${shop.address}',
                                        style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Route ID: ${shop.routeId} • Status: ${shop.status}',
                                            style: const TextStyle(fontSize: 11, color: AppColors.cyanAccent, fontWeight: FontWeight.w600),
                                          ),
                                          if (shop.currentCreditBalance > 0)
                                            Text(
                                              'Due: LKR ${shop.currentCreditBalance.toStringAsFixed(2)}',
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.roseDanger),
                                            )
                                          else
                                            const Text(
                                              'Credit Limit: LKR 100,000',
                                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.emeraldSuccess),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}
