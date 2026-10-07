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
  final List<Map<String, dynamic>> _requisitionCart = [];
  String _selectedUrgency = 'High Stock Out Demand on Dampola Route';
  bool _isLoading = true;
  String _searchQuery = '';

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
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openQuantitySelector(BranchStockModel item) {
    int existingIdx = _requisitionCart.indexWhere((c) => c['itemId'] == item.itemId);
    int currentQty = existingIdx != -1 ? (_requisitionCart[existingIdx]['requestedQty'] as int) : 10;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        int selectedQty = currentQty;
        return StatefulBuilder(
          builder: (context, setModalState) {
            final lineTotal = selectedQty * item.unitPrice;

            return Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.itemName,
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? AppColors.darkTextMain : AppColors.lightTextMain,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Code: ${item.itemCode} • Hub Stock: ${item.quantity} u',
                            style: const TextStyle(fontSize: 12, color: AppColors.amberWarning, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(height: 20),

                  // Unit Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Unit Selling Price:', style: TextStyle(fontSize: 13, color: AppColors.darkTextSub)),
                      Text('LKR ${item.unitPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.emeraldSuccess)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Quantity Selector with - and +
                  const Text('Select Requisition Quantity:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkTextSub)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          if (selectedQty > 1) {
                            setModalState(() => selectedQty--);
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkInput : AppColors.lightInput,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.amberWarning.withOpacity(0.5)),
                          ),
                          child: const Icon(Icons.remove, size: 20, color: AppColors.amberWarning),
                        ),
                      ),
                      Container(
                        width: 100,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkBg : AppColors.lightBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.amberWarning),
                        ),
                        child: Text(
                          '$selectedQty',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.amberWarning),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setModalState(() => selectedQty++);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkInput : AppColors.lightInput,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.amberWarning.withOpacity(0.5)),
                          ),
                          child: const Icon(Icons.add, size: 20, color: AppColors.amberWarning),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Quick Quantity Preset Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [10, 25, 50, 100, 250].map((preset) {
                      return OutlinedButton(
                        onPressed: () {
                          setModalState(() => selectedQty = preset);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          side: BorderSide(color: selectedQty == preset ? AppColors.amberWarning : (isDark ? AppColors.darkBorder : AppColors.lightBorder)),
                          backgroundColor: selectedQty == preset ? AppColors.amberWarning.withOpacity(0.15) : null,
                        ),
                        child: Text('+$preset', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: selectedQty == preset ? AppColors.amberWarning : (isDark ? AppColors.darkTextMain : AppColors.lightTextMain))),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Total Line Subtotal & Add Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Line Estimated Value:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      Text(
                        'LKR ${lineTotal.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.amberWarning),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _addToCart(item, selectedQty);
                      },
                      icon: const Icon(Icons.add_shopping_cart, size: 18),
                      label: Text(
                        existingIdx != -1 ? 'Update Item Quantity in Requisition' : 'Add Item to Requisition Order',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.amberWarning,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
  }

  void _addToCart(BranchStockModel item, int quantity) {
    setState(() {
      int idx = _requisitionCart.indexWhere((c) => c['itemId'] == item.itemId);
      if (idx != -1) {
        _requisitionCart[idx]['requestedQty'] = quantity;
      } else {
        _requisitionCart.add({
          'itemId': item.itemId,
          'itemCode': item.itemCode,
          'itemName': item.itemName,
          'availableQty': item.quantity,
          'unitPrice': item.unitPrice,
          'requestedQty': quantity,
        });
      }
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      _requisitionCart.removeAt(index);
    });
  }

  double get _totalEstimatedValue {
    double total = 0.0;
    for (var line in _requisitionCart) {
      total += (line['requestedQty'] as int) * (line['unitPrice'] as double);
    }
    return total;
  }

  int get _totalItemUnits {
    int total = 0;
    for (var line in _requisitionCart) {
      total += line['requestedQty'] as int;
    }
    return total;
  }

  Future<void> _submitRequisition() async {
    if (_requisitionCart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item to your requisition order'), backgroundColor: AppColors.roseDanger),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final List<Map<String, dynamic>> itemsPayload = [];
      for (var line in _requisitionCart) {
        itemsPayload.add({
          'item_id': line['itemId'],
          'quantity': line['requestedQty'],
        });
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
    final itemProvider = context.watch<ItemProvider>();
    final branchStocks = itemProvider.listBranchStocks.where((b) {
      return b.itemName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          b.itemCode.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Choose Warehouse Item:', style: TextStyle(fontSize: 14)),
                        Text('${branchStocks.length} Available Items', style: const TextStyle(fontSize: 12, color: AppColors.amberWarning)),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Search Box
                    TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: const InputDecoration(
                        isDense: true,
                        hintText: 'Search warehouse stock catalog by name or code...',
                        hintStyle: TextStyle(fontSize: 12),
                        prefixIcon: Icon(Icons.search, size: 18, color: AppColors.darkTextSub),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Warehouse Item Cards Grid / Horizontal Selector
                    if (branchStocks.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : AppColors.lightCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                        child: const Text('No warehouse stock items available.', style: TextStyle(fontSize: 12, color: AppColors.darkTextSub)),
                      )
                    else
                      SizedBox(
                        height: 110,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: branchStocks.length,
                          itemBuilder: (context, index) {
                            final bs = branchStocks[index];
                            final isInCart = _requisitionCart.any((c) => c['itemId'] == bs.itemId);

                            return GestureDetector(
                              onTap: () => _openQuantitySelector(bs),
                              child: Container(
                                width: 150,
                                margin: const EdgeInsets.only(right: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isInCart ? AppColors.amberWarning : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                    width: isInCart ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          bs.itemName,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: isDark ? AppColors.darkTextMain : AppColors.lightTextMain,
                                          ),
                                        ),
                                        Text(
                                          bs.itemCode,
                                          style: const TextStyle(fontSize: 10, color: AppColors.darkTextSub),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${bs.quantity} u',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.amberWarning),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: AppColors.darkYellow.withOpacity(0.15),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            isInCart ? Icons.check : Icons.add,
                                            size: 14,
                                            color: AppColors.amberWarning,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 20),

                    // 2. Selected Requisition Cart List Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Requisition Order Cart:', style: TextStyle(fontSize: 14)),
                        Text('${_requisitionCart.length} Selected Line Items', style: const TextStyle(fontSize: 11, color: AppColors.emeraldSuccess, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (_requisitionCart.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : AppColors.lightCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.add_shopping_cart, size: 36, color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub),
                            const SizedBox(height: 8),
                            const Text('Your requisition cart is empty.', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            const Text('Tap an item from the warehouse catalog above to add it to your order.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppColors.darkTextSub)),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _requisitionCart.length,
                        itemBuilder: (context, index) {
                          final line = _requisitionCart[index];
                          final qty = line['requestedQty'] as int;
                          final unitPrice = line['unitPrice'] as double;
                          final subtotal = qty * unitPrice;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCard : AppColors.lightCard,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${line['itemCode']} - ${line['itemName']}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isDark ? AppColors.darkTextMain : AppColors.lightTextMain,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'LKR ${unitPrice.toStringAsFixed(2)} × $qty = LKR ${subtotal.toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 11, color: AppColors.emeraldSuccess, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Quantity Adjustment Controls
                                Row(
                                  children: [
                                    IconButton(
                                      constraints: const BoxConstraints(),
                                      padding: const EdgeInsets.all(4),
                                      icon: const Icon(Icons.remove_circle_outline, color: AppColors.amberWarning, size: 20),
                                      onPressed: () {
                                        setState(() {
                                          if (qty > 1) {
                                            line['requestedQty'] = qty - 1;
                                          } else {
                                            _removeFromCart(index);
                                          }
                                        });
                                      },
                                    ),
                                    Text('$qty', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                    IconButton(
                                      constraints: const BoxConstraints(),
                                      padding: const EdgeInsets.all(4),
                                      icon: const Icon(Icons.add_circle_outline, color: AppColors.amberWarning, size: 20),
                                      onPressed: () {
                                        setState(() {
                                          line['requestedQty'] = qty + 1;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                IconButton(
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(4),
                                  icon: const Icon(Icons.delete_outline, color: AppColors.roseDanger, size: 20),
                                  onPressed: () => _removeFromCart(index),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 18),

                    // Urgency Dropdown
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
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          border: Border(top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Units: $_totalItemUnits (${_requisitionCart.length} lines)',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkTextSub),
                ),
                Text(
                  'LKR ${_totalEstimatedValue.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.emeraldSuccess),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _requisitionCart.isEmpty ? null : _submitRequisition,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.amberWarning,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  'Send Requisition Request to Hub',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
