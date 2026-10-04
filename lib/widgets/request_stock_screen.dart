import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../dio/dio_client.dart';
import '../models/branch_stock_model.dart';
import '../provider/item_provider.dart';
import '../theme/app_theme.dart';

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
      _loadBranchStockItems();
    });
  }

  Future<void> _loadBranchStockItems() async {
    final itemProvider = context.read<ItemProvider>();
    await itemProvider.getBranchStocks();
    List<BranchStockModel> branchStocks = itemProvider.listBranchStocks;

    if (mounted) {
      setState(() {
        _requisitionLines.clear();
        if (branchStocks.isNotEmpty) {
          for (var bs in branchStocks.take(3)) {
            _requisitionLines.add({
              'itemId': bs.itemId,
              'itemCode': bs.itemCode,
              'itemName': bs.itemName,
              'availableQty': bs.quantity,
              'qtyController': TextEditingController(text: '${bs.quantity > 50 ? 50 : bs.quantity}'),
            });
          }
        } else {
          _requisitionLines.add({
            'itemId': 1,
            'itemCode': 'HUT-SIM-001',
            'itemName': 'SIM Card 4G',
            'availableQty': 150,
            'qtyController': TextEditingController(text: '50'),
          });
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
    final itemProvider = context.read<ItemProvider>();
    final branchStocks = itemProvider.listBranchStocks;

    if (branchStocks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No branch warehouse stock available')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
          title: const Text('Select Branch Stock Item', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: branchStocks.length,
              separatorBuilder: (context, index) => Divider(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              itemBuilder: (context, index) {
                final bs = branchStocks[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(bs.itemName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? AppColors.darkTextMain : AppColors.lightTextMain)),
                  subtitle: Text('Code: ${bs.itemCode} • Hub Stock: ${bs.quantity} units', style: const TextStyle(fontSize: 11, color: AppColors.cyanAccent)),
                  trailing: Text('LKR ${bs.unitPrice.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.emeraldSuccess, fontWeight: FontWeight.bold, fontSize: 13)),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _requisitionLines.add({
                        'itemId': bs.itemId,
                        'itemCode': bs.itemCode,
                        'itemName': bs.itemName,
                        'availableQty': bs.quantity,
                        'qtyController': TextEditingController(text: '50'),
                      });
                    });
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _removeItemLine(int index) {
    setState(() {
      if (_requisitionLines[index]['qtyController'] is TextEditingController) {
        (_requisitionLines[index]['qtyController'] as TextEditingController).dispose();
      }
      _requisitionLines.removeAt(index);
    });
  }

  Future<void> _submitRequisition() async {
    setState(() => _isLoading = true);
    try {
      final List<Map<String, dynamic>> itemsPayload = [];
      for (var line in _requisitionLines) {
        final itemId = line['itemId'] as int?;
        final qtyText = (line['qtyController'] as TextEditingController).text;
        final qty = int.tryParse(qtyText) ?? 0;
        if (itemId != null && qty > 0) {
          itemsPayload.add({
            'item_id': itemId,
            'quantity': qty,
          });
        }
      }

      if (itemsPayload.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one item with valid quantity'), backgroundColor: AppColors.roseDanger),
        );
        setState(() => _isLoading = false);
        return;
      }

      final dioClient = DioClient();
      final response = await dioClient.post('stock-requests', data: {
        'items': itemsPayload,
        'notes': _selectedUrgency,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Multi-Item Requisition Request successfully sent to Branch Hub!'),
              backgroundColor: AppColors.emeraldSuccess,
            ),
          );
        }
      } else {
        throw Exception('Failed with status ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error submitting stock requisition: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit requisition: ${e.toString()}'),
            backgroundColor: AppColors.roseDanger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
                      'Build Multi-Item Requisition Order to Branch Warehouse Hub',
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
                final itemText = '${line['itemCode']} - ${line['itemName']}';
                final availableQty = line['availableQty'] ?? 0;

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
                              itemText,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isDark ? AppColors.darkTextMain : AppColors.lightTextMain,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Warehouse Stock: $availableQty units available',
                              style: const TextStyle(fontSize: 11, color: AppColors.cyanAccent, fontWeight: FontWeight.w600),
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
