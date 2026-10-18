import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:kkp_rep_mobile_app/models/dsr_rep_profile.dart';
import 'package:kkp_rep_mobile_app/provider/sales_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_snack_bar.dart';

class ProfileSettingsScreen extends StatefulWidget {
  final DsrRepProfile profile;
  final VoidCallback onToggleTheme;
  final bool isDarkMode;
  final VoidCallback onLogout;

  const ProfileSettingsScreen({
    super.key,
    required this.profile,
    required this.onToggleTheme,
    required this.isDarkMode,
    required this.onLogout,
  });

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  String _selectedFilter = 'Today';
  DateTimeRange? _selectedDateRange;

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _reportSectionKey = GlobalKey();

  bool _isLoadingKpis = false;
  double _totalRevenue = 0.0;
  int _completedBills = 0;
  double _totalCommission = 0.0;
  double _targetAmount = 50000.0;
  List<Map<String, dynamic>> _fetchedTransactions = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchSalesData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  final List<String> _filterOptions = [
    'Today',
    'Weekly',
    'Monthly',
    'Yearly',
    'Date Range',
  ];

  Future<void> _fetchSalesData() async {
    if (!mounted) return;
    setState(() {
      _isLoadingKpis = true;
    });

    try {
      final salesProvider = Provider.of<SalesProvider>(context, listen: false);

      DateTime now = DateTime.now();
      DateTime startDate;
      DateTime endDate = now;

      switch (_selectedFilter) {
        case 'Today':
          startDate = DateTime(now.year, now.month, now.day);
          _targetAmount = 50000.0;
          break;
        case 'Weekly':
          startDate = now.subtract(Duration(days: now.weekday - 1));
          startDate = DateTime(startDate.year, startDate.month, startDate.day);
          _targetAmount = 300000.0;
          break;
        case 'Monthly':
          startDate = DateTime(now.year, now.month, 1);
          endDate = DateTime(now.year, now.month + 1, 0);
          _targetAmount = 1200000.0;
          break;
        case 'Yearly':
          startDate = DateTime(now.year, 1, 1);
          endDate = DateTime(now.year, 12, 31);
          _targetAmount = 13000000.0;
          break;
        case 'Date Range':
          if (_selectedDateRange != null) {
            startDate = _selectedDateRange!.start;
            endDate = _selectedDateRange!.end;
          } else {
            startDate = DateTime(now.year, now.month, now.day);
          }
          _targetAmount = 200000.0;
          break;
        default:
          startDate = DateTime(now.year, now.month, now.day);
          _targetAmount = 50000.0;
      }

      final startStr = startDate.toIso8601String().split('T').first;
      final endStr = endDate.toIso8601String().split('T').first;

      final sales = await salesProvider.getSales(startDate: startStr, endDate: endStr);

      double revenue = 0.0;
      int bills = 0;
      List<Map<String, dynamic>> updatedTransactions = [];

      for (var sale in sales) {
        // Verify sale date falls strictly within [startDate, endDate] range
        final rawDateStr = (sale['sale_date'] ?? sale['created_at'])?.toString().split('T').first;
        if (rawDateStr != null && rawDateStr.isNotEmpty) {
          try {
            final saleDate = DateTime.parse(rawDateStr);
            final saleDay = DateTime(saleDate.year, saleDate.month, saleDate.day);
            final sDay = DateTime(startDate.year, startDate.month, startDate.day);
            final eDay = DateTime(endDate.year, endDate.month, endDate.day);

            if (saleDay.isBefore(sDay) || saleDay.isAfter(eDay)) {
              continue; // Skip sales outside selected filter date range
            }
          } catch (_) {}
        }

        final amount = (sale['paid_amount'] ?? sale['total_amount'] ?? 0.0) is num
            ? (sale['paid_amount'] ?? sale['total_amount'] ?? 0.0).toDouble()
            : double.tryParse((sale['paid_amount'] ?? sale['total_amount'] ?? '0.0').toString()) ?? 0.0;

        if (sale['status'] != 'CANCELLED') {
          revenue += amount;
          bills++;
        }

        String shopName = 'Shop ID: ${sale['shop_id'] ?? 'Unknown'}';
        if (sale['shop'] != null && sale['shop']['name'] != null) {
          shopName = sale['shop']['name'];
        }

        String timeStr = 'Unknown';
        if (sale['created_at'] != null) {
          try {
            final parsedDate = DateTime.parse(sale['created_at'].toString());
            timeStr = '${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}';
          } catch (_) {
            timeStr = sale['created_at'].toString().split('T').first;
          }
        }

        updatedTransactions.add({
          'shop': shopName,
          'time': timeStr,
          'items': 'Items: ${sale['items']?.length ?? 0}',
          'amount': 'LKR ${amount.toStringAsFixed(2)}',
          'payment': sale['payment_type'] ?? 'Unknown',
          'color': AppColors.emeraldSuccess,
        });
      }

      if (mounted) {
        setState(() {
          _totalRevenue = revenue;
          _completedBills = bills;
          _totalCommission = revenue * 0.05; // Dummy logic 5%
          _fetchedTransactions = updatedTransactions.take(15).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching KPIs: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingKpis = false;
        });
      }
    }
  }

  void _selectFilter(String filter) async {
    if (filter == 'Date Range') {
      final now = DateTime.now();
      final pickedRange = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2025, 1, 1),
        lastDate: DateTime.now(),
        initialDateRange: _selectedDateRange ??
            DateTimeRange(
              start: now.subtract(const Duration(days: 7)),
              end: now,
            ),
        builder: (context, child) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primaryOrange,
                brightness: isDark ? Brightness.dark : Brightness.light,
                primary: AppColors.primaryOrange,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedRange != null) {
        if (!mounted) return;
        setState(() {
          _selectedFilter = 'Date Range';
          _selectedDateRange = pickedRange;
        });
        AppSnackBar.showSuccess(
          context,
          message: 'Filtered sales report from ${_formatDate(pickedRange.start)} to ${_formatDate(pickedRange.end)}',
        );
        _fetchSalesData();
      }
    } else {
      setState(() {
        _selectedFilter = filter;
        _selectedDateRange = null;
      });
      AppSnackBar.showInfo(
        context,
        message: 'Sales data filtered for "$filter"',
      );
      _fetchSalesData();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Map<String, String> get _kpis {
    final double percentage = _targetAmount > 0 ? (_totalRevenue / _targetAmount * 100) : 0.0;
    String billsLabel = '$_completedBills Completed Bills';
    if (_selectedFilter == 'Date Range' && _selectedDateRange != null) {
      billsLabel = '$_completedBills Bills (${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)})';
    }

    return {
      'revenue': 'LKR ${_totalRevenue.toStringAsFixed(2)}',
      'bills': billsLabel,
      'commission': 'LKR ${_totalCommission.toStringAsFixed(2)}',
      'target': 'LKR ${_targetAmount.toStringAsFixed(2)} (${percentage.toStringAsFixed(0)}% Met)',
    };
  }

  void _showTargetModal() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sales Targets & Goals',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryOrange),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 12),
            _buildTargetProgressItem('Today Sales Revenue Target', 45000, 50000, AppColors.primaryOrange, isDark),
            const SizedBox(height: 12),
            _buildTargetProgressItem('Scratch Cards Sales Target', 480, 500, AppColors.cyanAccent, isDark),
            const SizedBox(height: 12),
            _buildTargetProgressItem('4G SIM Cards Activation Target', 28, 30, AppColors.emeraldSuccess, isDark),
            const SizedBox(height: 12),
            _buildTargetProgressItem('Easy Reload Revenue Target', 115000, 120000, AppColors.purpleAccent, isDark),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetProgressItem(String title, double current, double target, Color color, bool isDark) {
    final ratio = (current / target).clamp(0.0, 1.0);
    final percentage = (ratio * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkInput : AppColors.lightInput,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha((0.3 * 255).toInt())),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Text('$percentage%', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: color.withAlpha((0.15 * 255).toInt()),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Achieved: ${current.toStringAsFixed(0)}', style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub)),
              Text('Target: ${target.toStringAsFixed(0)}', style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub)),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _exportPdf() async {
    if (_fetchedTransactions.isEmpty) {
      AppSnackBar.showError(context, message: 'No sales data to export.');
      return;
    }

    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Sales Report - $_selectedFilter', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Text('Total Revenue: LKR ${_totalRevenue.toStringAsFixed(2)}'),
                pw.Text('Completed Bills: $_completedBills'),
                pw.SizedBox(height: 20),
                pw.TableHelper.fromTextArray(
                  context: context,
                  data: <List<String>>[
                    <String>['Shop', 'Time', 'Items', 'Amount', 'Payment'],
                    ..._fetchedTransactions.map((tx) => [
                          tx['shop'].toString(),
                          tx['time'].toString(),
                          tx['items'].toString(),
                          tx['amount'].toString(),
                          tx['payment'].toString(),
                        ]),
                  ],
                ),
              ],
            );
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File('${output.path}/sales_report.pdf');
      await file.writeAsBytes(await pdf.save());

      // ignore: deprecated_member_use
      await Share.shareXFiles([XFile(file.path)], text: 'Sales Report - $_selectedFilter');
    } catch (e) {
      if (mounted) AppSnackBar.showError(context, message: 'Failed to export PDF: $e');
    }
  }

  Future<void> _exportCsv() async {
    if (_fetchedTransactions.isEmpty) {
      AppSnackBar.showError(context, message: 'No sales data to export.');
      return;
    }

    try {
      List<List<dynamic>> rows = [
        ['Shop', 'Time', 'Items', 'Amount', 'Payment'],
      ];

      for (var tx in _fetchedTransactions) {
        rows.add([
          tx['shop'],
          tx['time'],
          tx['items'],
          tx['amount'],
          tx['payment'],
        ]);
      }

      String csvData = rows.map((row) => row.map((e) => '"${e.toString().replaceAll('"', '""')}"').join(',')).join('\n');

      final output = await getTemporaryDirectory();
      final file = File('${output.path}/sales_report.csv');
      await file.writeAsString(csvData);

      // ignore: deprecated_member_use
      await Share.shareXFiles([XFile(file.path)], text: 'Sales Report - $_selectedFilter');
    } catch (e) {
      if (mounted) AppSnackBar.showError(context, message: 'Failed to export CSV: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kpis = _kpis;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Quick Action Buttons Grid (Reports, Targets, Inventory, Commissions)
              const Text(
                'QUICK ACTIONS & MODULES:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryOrange, letterSpacing: 0.5),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        if (_reportSectionKey.currentContext != null) {
                          Scrollable.ensureVisible(
                            _reportSectionKey.currentContext!,
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeInOut,
                            alignment: 0.0,
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : AppColors.lightCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.cyanAccent.withAlpha((0.4 * 255).toInt())),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.cyanAccent.withAlpha((0.15 * 255).toInt()),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.bar_chart_rounded, color: AppColors.cyanAccent, size: 20),
                            ),
                            const SizedBox(height: 10),
                            const Text('Sales Reports', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 2),
                            Text('Audit & exports', style: TextStyle(fontSize: 10, color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 2. Targets Button
                  Expanded(
                    child: InkWell(
                      onTap: _showTargetModal,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : AppColors.lightCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.primaryOrange.withAlpha((0.4 * 255).toInt())),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryOrange.withAlpha((0.15 * 255).toInt()),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.track_changes, color: AppColors.primaryOrange, size: 20),
                            ),
                            const SizedBox(height: 10),
                            const Text('Sales Targets', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 2),
                            Text('Goal vs progress', style: TextStyle(fontSize: 10, color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [

                  const SizedBox(width: 12),

                ],
              ),
              const SizedBox(height: 20),

              // Sales Period Filter Options (Today, Weekly, Monthly, Yearly, Date Range)
              Row(
                key: _reportSectionKey,
                children: const [
                  Icon(Icons.filter_list, color: AppColors.primaryOrange, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'SALES TIME PERIOD FILTER:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryOrange, letterSpacing: 0.5),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filterOptions.map((option) {
                    final isSelected = _selectedFilter == option;
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (option == 'Date Range') ...[
                              const Icon(Icons.date_range, size: 14),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              option == 'Date Range' && _selectedDateRange != null
                                  ? '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}'
                                  : option,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : (isDark ? AppColors.darkTextMain : AppColors.lightTextMain),
                              ),
                            ),
                          ],
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primaryOrange,
                        backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? AppColors.primaryOrange : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          ),
                        ),
                        onSelected: (_) => _selectFilter(option),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // KPI Cards Row (Filtered Total Sales Revenue & Rep Commissions)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.lightCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL REVENUE ($_selectedFilter)',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _isLoadingKpis
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : Text(
                                  kpis['revenue']!,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primaryOrange,
                                  ),
                                ),
                          const SizedBox(height: 4),
                          Text(
                            kpis['bills']!,
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),

                ],
              ),
              const SizedBox(height: 16),

              // Export PDF / Excel CSV Buttons Row
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _exportPdf,
                      icon: const Icon(Icons.picture_as_pdf, size: 16),
                      label: const Text('Export PDF Report', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.roseDanger,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _exportCsv,
                      icon: const Icon(Icons.table_chart, size: 16),
                      label: const Text('Export Excel CSV', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emeraldSuccess,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Sales Transaction History Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sales History ($_selectedFilter)',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkInput : AppColors.lightInput,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          ),
                          child: Text(_selectedFilter, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(flex: 2, child: Text('TIME / SHOP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.darkTextSub))),
                        Expanded(flex: 2, child: Text('ITEMS SOLD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.darkTextSub))),
                        Expanded(child: Text('AMOUNT', textAlign: TextAlign.end, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.darkTextSub))),
                        Expanded(flex: 2, child: Text('PAYMENT', textAlign: TextAlign.end, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.darkTextSub))),
                      ],
                    ),
                    const Divider(height: 16),
                    _isLoadingKpis
                        ? const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator()))
                        : _fetchedTransactions.isEmpty
                            ? const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text('No sales found for this period.')))
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _fetchedTransactions.length,
                                separatorBuilder: (context, index) => Divider(
                                  height: 16,
                                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                ),
                                itemBuilder: (context, index) {
                                  final tx = _fetchedTransactions[index];
                                  return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(tx['shop'] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextMain : AppColors.lightTextMain)),
                                  const SizedBox(height: 2),
                                  Text(tx['time'] as String, style: const TextStyle(fontSize: 10, color: AppColors.darkTextSub)),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                tx['items'] as String,
                                style: const TextStyle(fontSize: 11, color: AppColors.darkTextSub),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                tx['amount'] as String,
                                textAlign: TextAlign.end,
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: tx['color'] as Color),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                tx['payment'] as String,
                                textAlign: TextAlign.end,
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: tx['color'] as Color),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Logout Buttonuser

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
