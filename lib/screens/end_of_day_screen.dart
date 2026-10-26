import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/sales_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_snack_bar.dart';
import 'daily_settlement_history_screen.dart';
import '../widgets/other_screen header.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _fetchSettlementData();
    });
  }

  Future<void> _fetchSettlementData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _settlementData = null;
    });
    final data = await context.read<SalesProvider>().getDailySettlement();
    const requiredTotals = [
      'total_sales_value',
      'total_cash_collected',
      'total_cheques_collected',
      'total_online_collected',
      'total_credit_issued',
      'ending_shop_credit',
      'total_credit_collected',
    ];
    final valid =
        data != null &&
        data['date'] is String &&
        data['shops_visited_count'] is int &&
        data['items_matrix'] is List &&
        requiredTotals.every(
          (key) => num.tryParse(data[key]?.toString() ?? '')?.isFinite == true,
        );
    if (!mounted) return;
    setState(() {
      _settlementData = valid ? data : null;
      _isLoading = false;
    });
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
    final creditCollected = _parseDouble(
      _settlementData?['total_credit_collected'],
    );
    final isApproved = _settlementData?['status'] == 'APPROVED';
    final statusLabel = _settlementData == null
        ? 'Unavailable'
        : '${_settlementData!['status']}\n${_settlementData!['is_saved'] == true ? 'Saved snapshot' : 'Live values'}';

    final double totalCollected =
        cashCollected + chequesCollected + onlineCollected;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: OtherScreenHeader(
          title: 'DSR Daily Settlement Sheet',
          isDarkMode: isDark,
          isKeepTheme: false,
          onToggleTheme: () {},
        ),
      ),
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
                          Text(
                            'Date: $dateStr',
                            style: const TextStyle(
                              fontSize: 16,
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
                              ? AppColors.emeraldSuccess.withAlpha((0.2 * 255).toInt())
                              : AppColors.primaryOrange.withAlpha((0.15 * 255).toInt()),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                (_settlementData?['is_saved'] == true ||
                                    _settlementData?['status'] == 'SUBMITTED')
                                ? AppColors.emeraldSuccess
                                : AppColors.primaryOrange.withAlpha((0.3 * 255).toInt()),
                          ),
                        ),
                        child: Text(
                          (_settlementData?['is_saved'] == true ||
                                  _settlementData?['status'] == 'SUBMITTED')
                              ? 'SUBMITTED'
                              : 'Pre-Balanced Draft',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:
                                (_settlementData?['is_saved'] == true ||
                                    _settlementData?['status'] == 'SUBMITTED')
                                ? AppColors.emeraldSuccess
                                : AppColors.primaryOrange,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

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
                  const Text(
                    '1. Product Sales Matrix Today',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(0),
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
                              flex: 2,
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
                                    flex: 2,
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
                          }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. Daily Collection Ledger
                   Text(
                    '2. Daily Collections',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.cyanAccent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(0),

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
                              'TOTAL PAYMENTS TODAY:',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.emeraldSuccess,
                              ),
                            ),
                            Text(
                              'LKR ${totalCollected.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
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
                    '3. Shop Credit',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.purpleAccent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(0),
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
                          'TOTAL CREDIT BALANCE:',
                          'LKR ${endingCredit.toStringAsFixed(2)}',
                          isDark,
                          AppColors.purpleAccent,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const DailySettlementHistoryScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryOrange,
                    side: const BorderSide(color: AppColors.primaryOrange),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.history, size: 18),
                  label: const Text(
                    'View Previous Settlements & Status',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading || _settlementData == null || isApproved
                      ? null
                      : () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              title: const Text('Submit Settlement Sheet'),
                              content: Text(
                                'Submit settlement sheet for $dateStr (Total Sales: LKR ${totalSalesValue.toStringAsFixed(2)})?',
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
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.send, color: Colors.white),
                  label: const Text(
                    'Submit Settlement Sheet to Agent',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
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
        AppSnackBar.showSuccess(
          context,
          title: 'Settlement Saved',
          message: 'Daily Settlement Sheet successfully saved to database!',
        );
        _fetchSettlementData();
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(
          context,
          title: 'Settlement Error',
          message: 'Failed to save settlement sheet: $e',
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
