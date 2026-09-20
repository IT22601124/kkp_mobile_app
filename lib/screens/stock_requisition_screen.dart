import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StockRequisitionScreen extends StatelessWidget {
  const StockRequisitionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, dynamic>> handheldStock = [
      {
        'name': 'Hutch Rs. 100 Recharge Card',
        'code': 'CARD-100',
        'units': 500,
        'soldToday': 30,
      },
      {
        'name': 'Hutch Rs. 500 Super Value Card',
        'code': 'CARD-500',
        'units': 430,
        'soldToday': 30,
      },
      {
        'name': 'Hutch 4G SIM Starter Pack',
        'code': 'SIM-4G',
        'units': 30,
        'soldToday': 0,
      },
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // My Handheld Stock Bag Banner Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cyanAccent.withOpacity(0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Handheld Stock Bag',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.cyanAccent,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Issued stock for Dampola Route',
                          style: TextStyle(fontSize: 12, color: AppColors.darkTextSub),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => _showRequestStockBottomSheet(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cyanAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      child: const Text('+ Request Stock', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Stock Items List Container
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: handheldStock.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                  itemBuilder: (context, index) {
                    final item = handheldStock[index];
                    final sold = item['soldToday'] as int;
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'] as String,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColors.darkTextMain : AppColors.lightTextMain,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Code: ${item['code']}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.darkTextSub),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${item['units']} Units',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.cyanAccent,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                sold > 0 ? '$sold Sold Today' : '0 Sold',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: sold > 0 ? AppColors.emeraldSuccess : AppColors.darkTextSub,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  void _showRequestStockBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateSheet) {
          final List<Map<String, dynamic>> requisitionLines = [
            {'item': 'CARD-100 - Hutch Rs. 100...', 'qty': '250'},
            {'item': 'SIM-4G - Hutch 4G SIM S...', 'qty': '50'},
          ];
          String selectedUrgency = 'High Stock Out Demand on Dampola Route';

          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Request Warehouse Multi-Item Stock',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.cyanAccent,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Build Multi-Item Requisition Order to Branch Hub',
                    style: TextStyle(fontSize: 12, color: AppColors.darkTextSub),
                  ),
                  const SizedBox(height: 20),
                  ...requisitionLines.map((line) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkInput : AppColors.lightInput,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Product Item', style: TextStyle(fontSize: 10, color: AppColors.darkTextSub, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(line['item']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Quantity', style: TextStyle(fontSize: 10, color: AppColors.darkTextSub, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  TextField(
                                    controller: TextEditingController(text: line['qty']),
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setStateSheet(() {
                                  requisitionLines.remove(line);
                                });
                              },
                              icon: const Icon(Icons.delete_outline, color: AppColors.roseDanger),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () {
                      setStateSheet(() {
                        requisitionLines.add({'item': 'RELOAD-EASY - Easy Reload Balance', 'qty': '100'});
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.cyanAccent,
                      side: const BorderSide(color: AppColors.cyanAccent),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Center(child: Text('+ Add Requisition Item Line', style: TextStyle(fontWeight: FontWeight.bold))),
                  ),
                  const SizedBox(height: 16),
                  const Text('Requisition Urgency / Reason', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkTextSub)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkInput : AppColors.lightInput,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedUrgency,
                        isExpanded: true,
                        items: ['High Stock Out Demand on Dampola Route', 'Regular Weekly Stock Replenishment', 'Special Event Promotion Stock']
                            .map((u) => DropdownMenuItem(value: u, child: Text(u, style: const TextStyle(fontSize: 13))))
                            .toList(),
                        onChanged: (val) {
                          setStateSheet(() {
                            selectedUrgency = val!;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Multi-Item Requisition Request successfully sent to Branch Hub!'),
                            backgroundColor: AppColors.emeraldSuccess,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cyanAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text(
                        'Send Multi-Item Requisition Request to Hub',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
