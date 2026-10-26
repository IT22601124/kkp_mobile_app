import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/sales_provider.dart';
import '../theme/app_theme.dart';

class DailySettlementHistoryScreen extends StatefulWidget {
  const DailySettlementHistoryScreen({super.key});

  @override
  State<DailySettlementHistoryScreen> createState() => _DailySettlementHistoryScreenState();
}

class _DailySettlementHistoryScreenState extends State<DailySettlementHistoryScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _historyList = [];

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoading = true);
    try {
      final salesProvider = context.read<SalesProvider>();
      final data = await salesProvider.getDailySettlementHistory();
      if (mounted) {
        setState(() {
          _historyList = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching settlement history: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  double _parseDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
      case 'VERIFIED':
        return AppColors.emeraldSuccess;
      case 'REJECTED':
      case 'FAILED':
        return AppColors.roseDanger;
      case 'PENDING':
      case 'SUBMITTED':
      default:
        return AppColors.amberWarning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Previous Settlement Sheets & Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        elevation: 1,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchHistory,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange))
            : _historyList.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 150),
                      Center(
                        child: Text(
                          'No previous settlement sheets found.',
                          style: TextStyle(color: AppColors.darkTextSub, fontSize: 13),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _historyList.length,
                    itemBuilder: (context, index) {
                      final item = _historyList[index];
                      final dateStr = item['date']?.toString() ?? item['created_at']?.toString().split('T').first ?? 'N/A';
                      final status = item['status']?.toString().toUpperCase() ?? 'PENDING';
                      final totalSales = _parseDouble(item['total_sales_value'] ?? item['total_sales']);
                      final cash = _parseDouble(item['cash_collected'] ?? item['cash']);
                      final cheques = _parseDouble(item['cheque_collected'] ?? item['cheques']);
                      final online = _parseDouble(item['online_collected'] ?? item['online']);
                      final credit = _parseDouble(item['credit_issued'] ?? item['credit']);
                      final shopsVisited = item['shops_visited_count'] ?? item['shops_visited'] ?? 0;

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
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 16, color: AppColors.primaryOrange),
                                    const SizedBox(width: 8),
                                    Text(
                                      dateStr,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? AppColors.darkTextMain : AppColors.lightTextMain,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: _getStatusColor(status)),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: _getStatusColor(status),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Sales:', style: TextStyle(fontSize: 12, color: AppColors.darkTextSub)),
                                Text('LKR ${totalSales.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryOrange)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Cash Collected:', style: TextStyle(fontSize: 12, color: AppColors.darkTextSub)),
                                Text('LKR ${cash.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Cheques / Online / Credit:', style: TextStyle(fontSize: 12, color: AppColors.darkTextSub)),
                                Text('LKR ${cheques.toStringAsFixed(2)} / LKR ${online.toStringAsFixed(2)} / LKR ${credit.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Shops Visited:', style: TextStyle(fontSize: 12, color: AppColors.darkTextSub)),
                                Text('$shopsVisited outlets', style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
