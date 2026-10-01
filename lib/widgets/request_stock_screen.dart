import 'package:flutter/material.dart';


class RequestStockScreen extends StatefulWidget {
  const RequestStockScreen({super.key});

  @override
  State<RequestStockScreen> createState() => _RequestStockScreenState();
}

class _RequestStockScreenState extends State<RequestStockScreen> {
  final List<Map<String, dynamic>> _requisitionLines = [];
  String _selectedUrgency = 'High Stock Out Demand on Dampola Route';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRepStockItems();
    });
  }

  Future<void> _loadRepStockItems() async {
    final user = context.read<AuthProvider>().user;
    final repId = user?.id ?? 7;
    final itemProvider = context.read<ItemProvider>();

    List<RepStockModel> stocks = itemProvider.listRepStocks;
    if (stocks.isEmpty) {
      stocks = await itemProvider.getRepStocks(repId);
    }

    if (mounted) {
      setState(() {
        _requisitionLines.clear();
        if (stocks.isNotEmpty) {
          for (var stock in stocks) {
            _requisitionLines.add({
              'item': '${stock.itemCode} - ${stock.itemName}',
              'qtyController': TextEditingController(text: '${stock.quantity}'),
            });
          }
        } else {
          // Fallback if rep has no current stock records
          _requisitionLines.addAll([
            {'item': 'CARD-100 - Hutch Rs. 100 Recharge Card', 'qtyController': TextEditingController(text: '250')},
            {'item': 'SIM-4G - Hutch 4G SIM Starter Pack', 'qtyController': TextEditingController(text: '50')},
          ]);
        }
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    for (var line in _requisitionLines) {
      if (line['qtyController'] is TextEditingController) {
        (line['qtyController'] as TextEditingController).dispose();
      }
    }
    super.dispose();
  }

  void _addItemLine() {
    setState(() {
      _requisitionLines.add({
        'item': 'RELOAD-EASY - Easy Reload Balance',
        'qtyController': TextEditingController(text: '100'),
      });
    });
  }

  void _removeItemLine(int index) {
    setState(() {
      if (_requisitionLines[index]['qtyController'] is TextEditingController) {
        (_requisitionLines[index]['qtyController'] as TextEditingController).dispose();
      }
      _requisitionLines.removeAt(index);
    });
  }

  void _submitRequisition() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Multi-Item Requisition Request successfully sent to Branch Hub!'),
        backgroundColor: AppColors.emeraldSuccess,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Request Warehouse Stock', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.cyanAccent))
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cyanAccent.withOpacity(0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cyanAccent.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Request Warehouse Multi-Item Stock',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.cyanAccent,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Build Multi-Item Requisition Order to Branch Hub',
                      style: TextStyle(fontSize: 12, color: AppColors.darkTextSub),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Requisition Lines List
              ...List.generate(_requisitionLines.length, (index) {
                final line = _requisitionLines[index];
                final controller = line['qtyController'] as TextEditingController;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
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
                            Text(
                              line['item'] as String,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isDark ? AppColors.darkTextMain : AppColors.lightTextMain,
                              ),
                            ),
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
                              controller: controller,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _removeItemLine(index),
                        icon: const Icon(Icons.delete_outline, color: AppColors.roseDanger),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),

              // Add Requisition Item Line Button
              OutlinedButton.icon(
                onPressed: _addItemLine,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Requisition Item Line', style: TextStyle(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.cyanAccent,
                  side: const BorderSide(color: AppColors.cyanAccent),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),

              // Requisition Urgency / Reason Dropdown
              const Text('Requisition Urgency / Reason', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkTextSub)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedUrgency,
                    isExpanded: true,
                    items: [
                      'High Stock Out Demand on Dampola Route',
                      'Regular Weekly Stock Replenishment',
                      'Special Event Promotion Stock',
                    ]
                        .map((u) => DropdownMenuItem(value: u, child: Text(u, style: const TextStyle(fontSize: 13))))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedUrgency = val);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitRequisition,
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
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
