import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/shop_model.dart';
import '../provider/shop_provider.dart';
import '../provider/sales_provider.dart';
import '../theme/app_theme.dart';

class PaymentCollectionScreen extends StatefulWidget {
  const PaymentCollectionScreen({super.key});

  @override
  State<PaymentCollectionScreen> createState() => _PaymentCollectionScreenState();
}

class _PaymentCollectionScreenState extends State<PaymentCollectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShopProvider>().getCreditShops();
    });
  }

  double _parseDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  void _showShopCreditDetailsSheet(ShopModel shop) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return FutureBuilder<List<Map<String, dynamic>>>(
              future: context.read<SalesProvider>().getShopCreditSales(shop.id),
              builder: (context, snapshot) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  shop.shopName,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Owner: ${shop.ownerName.isNotEmpty ? shop.ownerName : "N/A"} | Phone: ${shop.phone.isNotEmpty ? shop.phone : "N/A"}',
                                  style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const Divider(height: 16),

                      // Credit Summary Banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.roseDanger.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.roseDanger.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Current Credit Balance:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text(
                              'LKR ${shop.currentCreditBalance.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.roseDanger),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text('Credit Sales History:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryOrange)),
                      const SizedBox(height: 8),

                      // Sales list
                      Expanded(
                        child: snapshot.connectionState == ConnectionState.waiting
                            ? const Center(child: CircularProgressIndicator(color: AppColors.purpleAccent))
                            : snapshot.hasError
                                ? Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: AppColors.roseDanger)))
                                : (snapshot.data == null || snapshot.data!.isEmpty)
                                    ? const Center(
                                        child: Text('No active credit sales records found.', style: TextStyle(color: AppColors.darkTextSub)),
                                      )
                                    : ListView.builder(
                                        controller: scrollController,
                                        itemCount: snapshot.data!.length,
                                        itemBuilder: (context, index) {
                                          final sale = snapshot.data![index];
                                          final double total = _parseDouble(sale['total_amount']);
                                          final double paid = _parseDouble(sale['paid_amount']);
                                          final double due = _parseDouble(sale['due_amount']);
                                          final items = (sale['sales_items'] ?? sale['items'] ?? []) as List;
                                          final String saleCode = sale['sale_code'] ?? 'SALE-${sale['id']}';
                                          final String dateStr = sale['sale_date'] ?? '';

                                          return Card(
                                            margin: const EdgeInsets.only(bottom: 10),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                            ),
                                            color: isDark ? AppColors.darkCard : AppColors.lightCard,
                                            child: Padding(
                                              padding: const EdgeInsets.all(12.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        saleCode,
                                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryOrange),
                                                      ),
                                                      Text(
                                                        dateStr.length >= 10 ? dateStr.substring(0, 10) : dateStr,
                                                        style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 6),

                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text('Total: LKR ${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
                                                      Text('Paid: LKR ${paid.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: AppColors.emeraldSuccess)),
                                                      Text(
                                                        'Due: LKR ${due.toStringAsFixed(2)}',
                                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.roseDanger),
                                                      ),
                                                    ],
                                                  ),

                                                  if (items.isNotEmpty) ...[
                                                    const Divider(height: 12),
                                                    Text('Items (${items.length}):', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                                    const SizedBox(height: 4),
                                                    Column(
                                                      children: items.map((i) {
                                                        final itemObj = i['item'] ?? {};
                                                        final name = itemObj['name'] ?? itemObj['item_name'] ?? 'Item #${i['item_id']}';
                                                        final int qty = (i['quantity'] is num) ? (i['quantity'] as num).toInt() : (int.tryParse(i['quantity']?.toString() ?? '1') ?? 1);
                                                        final double price = _parseDouble(i['unit_price']);
                                                        return Padding(
                                                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text('- $name (x$qty)', style: const TextStyle(fontSize: 11)),
                                                              Text('LKR ${(qty * price).toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                                                            ],
                                                          ),
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                      ),

                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _collectCashDialog(shop);
                          },
                          icon: const Icon(Icons.payments_outlined, color: Colors.white),
                          label: const Text('Collect Cash / Settle Credit', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.purpleAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _collectCashDialog(ShopModel shop) {
    final amountController = TextEditingController(text: shop.currentCreditBalance.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Settle Credit - ${shop.shopName}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Shop Code: ${shop.shopCode}', style: const TextStyle(fontSize: 12, color: AppColors.primaryOrange)),
            const SizedBox(height: 6),
            Text('Current Credit Outstanding: LKR ${shop.currentCreditBalance.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.roseDanger)),
            const SizedBox(height: 14),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Collected Amount (LKR)',
                border: OutlineInputBorder(),
                isDense: true,
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.purpleAccent),
            onPressed: () async {
              final double amount = double.tryParse(amountController.text) ?? 0.0;
              if (amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid amount'), backgroundColor: AppColors.roseDanger),
                );
                return;
              }

              Navigator.pop(ctx);
              final success = await context.read<ShopProvider>().settleCredit(shopId: shop.id, amount: amount);

              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Successfully collected LKR ${amount.toStringAsFixed(2)} from ${shop.shopName}!'),
                      backgroundColor: AppColors.emeraldSuccess,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to record credit settlement'),
                      backgroundColor: AppColors.roseDanger,
                    ),
                  );
                }
              }
            },
            child: const Text('CONFIRM SETTLEMENT', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        child: Consumer<ShopProvider>(
          builder: (context, shopProvider, _) {
            final creditShops = shopProvider.creditShops;
            final double totalOutstanding = creditShops.fold(0.0, (sum, shop) => sum + shop.currentCreditBalance);

            return RefreshIndicator(
              onRefresh: () => shopProvider.getCreditShops(),
              color: AppColors.purpleAccent,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Total Shop Credit Outstanding Header Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.lightCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.purpleAccent.withOpacity(0.5), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.purpleAccent.withOpacity(0.15),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TOTAL SHOP CREDIT OUTSTANDING',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'LKR ${totalOutstanding.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.purpleAccent,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh, color: AppColors.purpleAccent),
                            onPressed: () => shopProvider.getCreditShops(),
                            tooltip: 'Refresh Credit Balance',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Credit Shops List
                    if (shopProvider.isLoading && creditShops.isEmpty)
                       Center(
                        child: CircularProgressIndicator(color: AppColors.purpleAccent),
                      )
                    else if (creditShops.isEmpty)
                      Center(
                        child: Column(
                          children: [
                            const Icon(Icons.check_circle_outline, size: 56, color: AppColors.emeraldSuccess),
                            const SizedBox(height: 12),
                            const Text('No Outstanding Credit Balances!',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('All retail outlets have zero credit due balance.',
                                style: TextStyle(color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub, fontSize: 12)),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: creditShops.length,
                        itemBuilder: (context, index) {
                          final shop = creditShops[index];
                          final due = shop.currentCreditBalance;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCard : AppColors.lightCard,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => _showShopCreditDetailsSheet(shop),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                shop.shopName,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: isDark ? AppColors.darkTextMain : AppColors.lightTextMain,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              const Icon(Icons.info_outline, size: 14, color: AppColors.purpleAccent),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Code: ${shop.shopCode} | ${shop.address.isNotEmpty ? shop.address : "No Address"}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Due Outstanding: LKR ${due.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.roseDanger,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () => _collectCashDialog(shop),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.purpleAccent,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text(
                                        'Collect Cash',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
