import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/sales_provider.dart';
import '../theme/app_theme.dart';

class EndOfDayScreen extends StatefulWidget {
  final VoidCallback onEndTripSuccess;

  const EndOfDayScreen({super.key, required this.onEndTripSuccess});

  @override
  State<EndOfDayScreen> createState() => _EndOfDayScreenState();
}

class _EndOfDayScreenState extends State<EndOfDayScreen> {
  Map<String, dynamic>? _settlementData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSettlementData();
  }

  Future<void> _fetchSettlementData() async {
    setState(() {
      _isLoading = true;
    });

    final data = await context.read<SalesProvider>().getDailySettlement();

    if (mounted) {
      setState(() {
        _settlementData = data;
        _isLoading = false;
      });
    }
  }

  double _parseDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final dateStr =
        _settlementData?['date'] ?? DateTime.now().toString().split(' ').first;
    final int shopsVisited =
        (_settlementData?['shops_visited_count'] as int?) ?? 0;
    final double totalSalesValue = _parseDouble(
      _settlementData?['total_sales_value'],
    );
    final double cashCollected = _parseDouble(
      _settlementData?['total_cash_collected'],
    );
    final double chequesCollected = _parseDouble(
      _settlementData?['total_cheques_collected'],
    );
    final double onlineCollected = _parseDouble(
      _settlementData?['total_online_collected'],
    );
    final double creditIssued = _parseDouble(
      _settlementData?['total_credit_issued'],
    );
    final double endingCredit = _parseDouble(
      _settlementData?['ending_shop_credit'],
    );
    final itemsMatrix = (_settlementData?['items_matrix'] as List?) ?? [];

    final double totalCollected =
        cashCollected + chequesCollected + onlineCollected;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchSettlementData,
          color: AppColors.primaryOrange,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // DSR Daily Settlement Sheet Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DSR DAILY SETTLEMENT SHEET',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkTextSub,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Date: $dateStr ($shopsVisited Shops Visited)',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryOrange,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (_settlementData?['is_saved'] == true ||
                                  _settlementData?['status'] == 'SUBMITTED')
                              ? AppColors.emeraldSuccess.withOpacity(0.2)
                              : AppColors.primaryOrange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                (_settlementData?['is_saved'] == true ||
                                    _settlementData?['status'] == 'SUBMITTED')
                                ? AppColors.emeraldSuccess
                                : AppColors.primaryOrange.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          (_settlementData?['is_saved'] == true ||
                                  _settlementData?['status'] == 'SUBMITTED')
                              ? 'SUBMITTED\nSaved in DB'
                              : 'Pre-Balanced\nDraft',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:
                                (_settlementData?['is_saved'] == true ||
                                    _settlementData?['status'] == 'SUBMITTED')
                                ? AppColors.emeraldSuccess
                                : AppColors.primaryOrange,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Info Note Box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.cyanAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.darkYellow.withOpacity(0.3),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        color: AppColors.darkYellow,
                        size: 18,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Auto-Calculated Real-Time from Sales Transactions. Pull down to refresh live values.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.darkYellow,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryOrange,
                      ),
                    ),
                  )
                else ...[
                  // 1. Product Stock & Sales Matrix
                  const Text(
                    '1. Product Sales Matrix Today',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                'ITEM NAME',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkTextSub,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'SOLD QTY',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkTextSub,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'REVENUE',
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkTextSub,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        if (itemsMatrix.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Text(
                              'No product sales recorded today.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.darkTextSub,
                              ),
                            ),
                          )
                        else
                          ...itemsMatrix.map((item) {
                            final String name = item['name'] ?? 'Item';
                            final int soldQty =
                                (item['sold_qty'] as num?)?.toInt() ?? 0;
                            final double rev = _parseDouble(
                              item['total_revenue'],
                            );
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? AppColors.darkTextMain
                                            : AppColors.lightTextMain,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '$soldQty',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.roseDanger,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'LKR ${rev.toStringAsFixed(2)}',
                                      textAlign: TextAlign.end,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.emeraldSuccess,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. Daily Collection Ledger
                  const Text(
                    '2. Daily Collections & Payment Ledger',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.cyanAccent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildCashRow(
                          'Cash Collections',
                          'LKR ${cashCollected.toStringAsFixed(2)}',
                          isDark,
                        ),
                        const SizedBox(height: 8),
                        _buildCashRow(
                          'Cheque Collections',
                          'LKR ${chequesCollected.toStringAsFixed(2)}',
                          isDark,
                        ),
                        const SizedBox(height: 8),
                        _buildCashRow(
                          'Online / Card Collections',
                          'LKR ${onlineCollected.toStringAsFixed(2)}',
                          isDark,
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'TOTAL PAYMENTS\nCOLLECTED TODAY:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.emeraldSuccess,
                              ),
                            ),
                            Text(
                              'LKR ${totalCollected.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppColors.emeraldSuccess,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 3. Shop Credit Reconciliation
                  const Text(
                    '3. Shop Credit Reconciliation',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.purpleAccent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildReconRow(
                          'Today Sales Revenue:',
                          'LKR ${totalSalesValue.toStringAsFixed(2)}',
                          isDark,
                          Colors.white,
                        ),
                        const SizedBox(height: 8),
                        _buildReconRow(
                          'Today Credit Issued (+):',
                          '+LKR ${creditIssued.toStringAsFixed(2)}',
                          isDark,
                          AppColors.primaryOrange,
                        ),
                        const SizedBox(height: 8),
                        _buildReconRow(
                          'Today Payments Collected (-):',
                          '-LKR ${totalCollected.toStringAsFixed(2)}',
                          isDark,
                          AppColors.emeraldSuccess,
                        ),
                        const Divider(height: 20),
                        _buildReconRow(
                          'ENDING SHOP CREDIT BALANCE:',
                          'LKR ${endingCredit.toStringAsFixed(2)}',
                          isDark,
                          AppColors.purpleAccent,
                          isBold: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            title: const Text('Submit Settlement Sheet'),
                            content: Text(
                              'Submit pre-balanced settlement sheet for $dateStr (Total Sales: LKR ${totalSalesValue.toStringAsFixed(2)})?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryOrange,
                                ),
                                onPressed: () async {
                                  Navigator.pop(ctx);
                                  await _submitDailySettlementSheet(
                                    totalSalesValue,
                                    cashCollected,
                                    chequesCollected,
                                    onlineCollected,
                                    creditIssued,
                                    endingCredit,
                                    shopsVisited,
                                    dateStr,
                                    itemsMatrix,
                                  );
                                },
                                child: const Text(
                                  'Confirm & Submit',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.send, color: Colors.white),
                      label: const Text(
                        'Submit Pre-Balanced Sheet to Agent',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitDailySettlementSheet(
    double totalSalesValue,
    double cashCollected,
    double chequesCollected,
    double onlineCollected,
    double creditIssued,
    double endingCredit,
    int shopsVisited,
    String dateStr,
    List<dynamic> itemsMatrix,
  ) async {
    final salesProvider = Provider.of<SalesProvider>(context, listen: false);
    try {
      final payload = <String, dynamic>{
        'date': dateStr,
        'shops_visited_count': shopsVisited,
        'total_sales_value': totalSalesValue,
        'total_cash_collected': cashCollected,
        'total_cheques_collected': chequesCollected,
        'total_online_collected': onlineCollected,
        'total_credit_issued': creditIssued,
        'ending_shop_credit': endingCredit,
        'items': itemsMatrix,
      };

      final result = await salesProvider.submitDailySettlement(payload);
      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Daily Settlement Sheet successfully saved to database!',
            ),
            backgroundColor: AppColors.emeraldSuccess,
          ),
        );
        _fetchSettlementData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save settlement sheet: '),
            backgroundColor: AppColors.roseDanger,
          ),
        );
      }
    }
  }

  Widget _buildCashRow(String title, String amount, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub,
          ),
        ),
        Text(
          amount,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.emeraldSuccess,
          ),
        ),
      ],
    );
  }

  Widget _buildReconRow(
    String title,
    String amount,
    bool isDark,
    Color color, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
