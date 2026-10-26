import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/dsr_models.dart';
import '../models/shop_model.dart';
import '../provider/shop_provider.dart';
import '../provider/sales_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/outlet_card.dart';
import '../widgets/app_snack_bar.dart';

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
                color: AppColors.emeraldSuccess.withAlpha((0.12 * 255).toInt()),
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

  void _shareToWhatsApp(String shopName, String phone, String saleCode, double total, double paid, String paymentType) async {
    final message = '''
*Invoice Receipt*
Shop: $shopName
Transaction Code: $saleCode
Total Amount: LKR ${total.toStringAsFixed(2)}
Paid Amount: LKR ${paid.toStringAsFixed(2)}
Payment Method: $paymentType

Thank you for your business!
''';

    String? formattedPhone;
    if (phone.isNotEmpty) {
      String cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
      if (cleanPhone.startsWith('0') && cleanPhone.length == 10) {
        cleanPhone = '94${cleanPhone.substring(1)}';
      } else if (!cleanPhone.startsWith('94') && cleanPhone.length == 9) {
        cleanPhone = '94$cleanPhone';
      }
      formattedPhone = cleanPhone;
    }

    Uri uri;
    if (formattedPhone != null && formattedPhone.isNotEmpty) {
      uri = Uri.parse('whatsapp://send?phone=$formattedPhone&text=${Uri.encodeComponent(message)}');
    } else {
      uri = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(message)}');
    }

    try {
      bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        if (mounted) AppSnackBar.showError(context, message: 'Could not launch WhatsApp. Is it installed?');
      }
    } catch (e) {
      if (mounted) AppSnackBar.showError(context, message: 'Failed to open WhatsApp');
    }
  }

  void _viewReceipt(Outlet outlet) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) =>  Center(child:
      LoadingAnimationWidget.hexagonDots(
        color: AppColors.primaryOrange,
        size: 38,
      ),
      ),
    );

    try {
      final now = DateTime.now();
      final dateStr = DateTime(now.year, now.month, now.day).toIso8601String().split('T').first;
      final sales = await context.read<SalesProvider>().getSales(startDate: dateStr, endDate: dateStr);
      
      if (mounted) Navigator.pop(context); // pop loading

      // Find sale for this shop
      final shopSales = sales.where((s) {
        if (s['shop_id'] != outlet.id || s['status'] == 'CANCELLED') return false;
        final sDate = (s['sale_date'] ?? s['created_at'])?.toString().split('T').first;
        return sDate == dateStr;
      }).toList();
      
      if (shopSales.isEmpty) {
        if (mounted) {
          AppSnackBar.showInfo(context, message: 'No sale recorded for ${outlet.shopName} today. Please issue a new invoice.', title: 'No Sale Found');
          widget.onSelectOutletForInvoice(outlet);
        }
        return;
      }

      final latestSale = shopSales.first;
      final saleCode = latestSale['sale_code'] ?? 'SALE-${latestSale['id']}';
      
      final amount = (latestSale['total_amount'] ?? latestSale['paid_amount'] ?? 0.0) is num
            ? (latestSale['total_amount'] ?? latestSale['paid_amount'] ?? 0.0).toDouble()
            : double.tryParse((latestSale['total_amount'] ?? latestSale['paid_amount'] ?? '0.0').toString()) ?? 0.0;
            
      final paid = (latestSale['paid_amount'] ?? 0.0) is num
            ? (latestSale['paid_amount'] ?? 0.0).toDouble()
            : double.tryParse((latestSale['paid_amount'] ?? '0.0').toString()) ?? 0.0;

      final paymentType = latestSale['payment_type'] ?? 'Unknown';

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black),
              title: const Text(
                'Sale Receipt',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.receipt_long, size: 64, color: Colors.black87),
                    const SizedBox(height: 16),
                    Text(
                      outlet.shopName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (outlet.phone.isNotEmpty)
                      Text(
                        outlet.phone,
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    const SizedBox(height: 32),
                    
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        border: Border.all(color: Colors.grey.shade300, width: 1.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _buildReceiptRow('Receipt No', saleCode, isBold: true),
                          const SizedBox(height: 12),
                          _buildReceiptRow('Payment Method', paymentType),
                          const SizedBox(height: 12),
                          _buildReceiptRow('Date & Time', '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Divider(color: Colors.grey, thickness: 1),
                          ),
                          _buildReceiptRow('Total Amount', 'LKR ${amount.toStringAsFixed(2)}', isBold: true, isLarge: true),
                          const SizedBox(height: 8),
                          _buildReceiptRow('Paid Amount', 'LKR ${paid.toStringAsFixed(2)}'),
                          const SizedBox(height: 8),
                          _buildReceiptRow('Balance Due', 'LKR ${(amount - paid).clamp(0.0, double.infinity).toStringAsFixed(2)}', isHighlight: true),
                        ],
                      ),
                    ),
                    
                    const Spacer(),
                    
                    const Text(
                      'Thank you for your business!',
                      style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black54, fontSize: 14),
                    ),
                    const SizedBox(height: 24),

                    // WhatsApp Share Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () => _shareToWhatsApp(outlet.shopName, outlet.phone, saleCode, amount, paid, paymentType),
                        icon: const Icon(Icons.chat, color: Colors.white),
                        label: const Text(
                          'Share to WhatsApp',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366), // WhatsApp Brand Color
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text(
                          'Back to Route Outlets',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // pop loading
        AppSnackBar.showError(context, message: 'Could not fetch sale details.');
      }
    }
  }

  Widget _buildReceiptRow(String label, String value, {bool isBold = false, bool isLarge = false, bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isLarge ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isLarge ? 18 : 14,
            fontWeight: (isBold || isHighlight) ? FontWeight.w900 : FontWeight.bold,
            color: isHighlight ? AppColors.roseDanger : Colors.black87,
          ),
        ),
      ],
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
                    ?  Center(
                        child: LoadingAnimationWidget.hexagonDots(
                          color: AppColors.primaryOrange,
                          size: 38,
                        ),
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
                                onSell: () => _viewReceipt(outlet),
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
