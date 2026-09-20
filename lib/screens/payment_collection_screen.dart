import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PaymentCollectionScreen extends StatefulWidget {
  const PaymentCollectionScreen({super.key});

  @override
  State<PaymentCollectionScreen> createState() => _PaymentCollectionScreenState();
}

class _PaymentCollectionScreenState extends State<PaymentCollectionScreen> {
  final List<Map<String, dynamic>> _creditShops = [
    {
      'name': 'Shanika Communication',
      'code': 'SH-1008',
      'address': 'Main Street',
      'due': 14000.00,
    },
    {
      'name': 'New City Mobile Centre',
      'code': 'SH-1010',
      'address': 'Main Street',
      'due': 28500.00,
    },
    {
      'name': 'Rathnayake Cellular',
      'code': 'SH-1014',
      'address': 'Main Street',
      'due': 18200.00,
    },
    {
      'name': 'Gayan Stores',
      'code': 'SH-1019',
      'address': 'Main Street',
      'due': 9400.00,
    },
  ];

  void _collectCash(Map<String, dynamic> shop) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Collect Cash - ${shop['name']}'),
        content: Text('Record cash collection of LKR ${shop['due'].toStringAsFixed(2)}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Successfully collected LKR ${shop['due'].toStringAsFixed(2)} from ${shop['name']}!'),
                  backgroundColor: AppColors.emeraldSuccess,
                ),
              );
              setState(() {
                shop['due'] = 0.00;
              });
            },
            child: const Text('Confirm Collection'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalOutstanding = _creditShops.fold(0.0, (sum, shop) => sum + (shop['due'] as double));

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Shop Credit Outstanding Card
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
                child: Column(
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
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.purpleAccent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Credit Shops List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _creditShops.length,
                itemBuilder: (context, index) {
                  final shop = _creditShops[index];
                  final due = shop['due'] as double;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                shop['name'] as String,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.darkTextMain : AppColors.lightTextMain,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Code: ${shop['code']} | ${shop['address']}',
                                style: TextStyle(
                                  fontSize: 12,
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
                          onPressed: due > 0 ? () => _collectCash(shop) : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.purpleAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                  );
                },
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
