import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kkp_rep_mobile_app/provider/sales_provider.dart';
import 'package:kkp_rep_mobile_app/widgets/app_snack_bar.dart';
import '../models/dsr_models.dart';
import '../models/item_model.dart';
import '../models/shop_model.dart';
import '../provider/auth_provider.dart';
import '../provider/bank_account_provider.dart';
import '../provider/item_provider.dart';
import '../provider/shop_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/location_status_chip.dart';

class InvoiceCreationScreen extends StatefulWidget {
  final Outlet? initialOutlet;

  const InvoiceCreationScreen({super.key, this.initialOutlet});

  @override
  State<InvoiceCreationScreen> createState() => _InvoiceCreationScreenState();
}

class _InvoiceCreationScreenState extends State<InvoiceCreationScreen> {
  ShopModel? _selectedShop;
  String _productSearchQuery = '';
  final List<Map<String, dynamic>> _cartItems = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialOutlet != null) {
      _selectedShop = ShopModel(
        id: widget.initialOutlet!.id,
        routeId: 1,
        shopCode: 'SH-${widget.initialOutlet!.id}',
        shopName: widget.initialOutlet!.shopName,
        ownerName: widget.initialOutlet!.ownerName,
        phone: widget.initialOutlet!.phone,
        address: widget.initialOutlet!.address,
        latitude: 0,
        longitude: 0,
        creditLimit: 0,
        currentCreditBalance: widget.initialOutlet!.outstandingBalance,
        status: 'GOOD',
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final shopProvider = Provider.of<ShopProvider>(context, listen: false);
      final itemProvider = Provider.of<ItemProvider>(context, listen: false);

      if (shopProvider.listShops.isEmpty) {
        int? routeId = authProvider.user?.repProfile?.assignedRouteId;
        shopProvider.getShopsByRoute(routeId: routeId).catchError((_) {
          if (mounted) {
            AppSnackBar.showError(
              context,
              title: 'No Route Assigned',
              message: 'You are not assigned to a route, please contact admin',
            );
          }
          return <ShopModel>[];
        });
      }

      int repId =
          authProvider.user?.id ??
          authProvider.user?.repProfile?.userId ??
          authProvider.user?.repProfile?.id ??
          0;
      if (repId <= 0) {
        if (authProvider.user == null) {
          authProvider.checkSavedToken().then((_) {
            final id =
                authProvider.user?.id ??
                authProvider.user?.repProfile?.userId ??
                authProvider.user?.repProfile?.id ??
                0;
            if (id > 0) itemProvider.getRepStocks(id);
          });
        } else if (authProvider.user?.repProfile == null) {
          authProvider.fetchRepMe().then((_) {
            final id =
                authProvider.user?.id ??
                authProvider.user?.repProfile?.userId ??
                authProvider.user?.repProfile?.id ??
                0;
            if (id > 0) itemProvider.getRepStocks(id);
          });
        }
      } else {
        itemProvider.getRepStocks(repId);
      }

      if (itemProvider.listItems.isEmpty) {
        itemProvider.getItems();
      }

      final bankAccountProvider = Provider.of<BankAccountProvider>(
        context,
        listen: false,
      );
      bankAccountProvider.getBankAccounts();
    });
  }

  double get _totalBillPayable {
    return _cartItems.fold(
      0.0,
      (sum, item) =>
          sum + ((item['unitPrice'] as double) * (item['qty'] as int)),
    );
  }

  void _clearCart() {
    setState(() {
      _cartItems.clear();
    });
  }

  void _openQuantityDialog(ItemModel item) {
    final existingIdx = _cartItems.indexWhere(
      (c) =>
          (c['code'] != null && c['code'] == item.itemCode) ||
          (c['name'] as String).contains(item.itemCode) ||
          (c['name'] as String).contains(item.itemName),
    );

    final int initialQty = existingIdx != -1
        ? (_cartItems[existingIdx]['qty'] as int)
        : 1;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final TextEditingController qtyController = TextEditingController(
      text: initialQty.toString(),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        int currentQty = initialQty;

        return StatefulBuilder(
          builder: (context, setModalState) {
            final lineTotal = currentQty * item.unitPrice;

            void updateQty(int newQty) {
              if (newQty < 0) newQty = 0;
              if (newQty > item.stock) {
                newQty = item.stock;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Cannot exceed available stock (${item.stock} ${item.unit})'),
                    backgroundColor: AppColors.roseDanger,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
              setModalState(() {
                currentQty = newQty;
                qtyController.text = newQty.toString();
              });
            }

            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.itemName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.darkTextMain
                                    : AppColors.lightTextMain,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Code: ${item.itemCode} â€¢ Stock: ${item.stock} ${item.unit}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.amberWarning,
                                fontWeight: FontWeight.w600,
                              ),
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
                  const Divider(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Unit Price: LKR ${item.unitPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.darkTextSub
                              : AppColors.lightTextSub,
                        ),
                      ),
                      Text(
                        'Subtotal: LKR ${lineTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.emeraldSuccess,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Select / Enter Quantity:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.amberWarning,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          if (currentQty > 0) updateQty(currentQty - 1);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkInput
                                : AppColors.lightInput,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                            ),
                          ),
                          child: const Icon(
                            Icons.remove,
                            size: 20,
                            color: AppColors.roseDanger,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: qtyController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.darkTextMain
                                : AppColors.lightTextMain,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: (val) {
                            final parsed = int.tryParse(val);
                            if (parsed != null && parsed >= 0) {
                              int validQty = parsed;
                              if (validQty > item.stock) {
                                validQty = item.stock;
                                qtyController.text = validQty.toString();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Cannot exceed available stock (${item.stock} ${item.unit})'),
                                    backgroundColor: AppColors.roseDanger,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                              setModalState(() {
                                currentQty = validQty;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: () => updateQty(currentQty + 1),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkInput
                                : AppColors.lightInput,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                            ),
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 20,
                            color: AppColors.emeraldSuccess,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [1, 5, 10, 25, 50, 100].map((preset) {
                      final isSelected = currentQty == preset;
                      return ChoiceChip(
                        label: Text('+$preset'),
                        selected: isSelected,
                        selectedColor: AppColors.primaryOrange,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                    ? AppColors.darkTextMain
                                    : AppColors.lightTextMain),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) => updateQty(preset),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        if (currentQty > item.stock) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Cannot exceed available stock (${item.stock} ${item.unit})'),
                              backgroundColor: AppColors.roseDanger,
                            ),
                          );
                          return;
                        }
                        setState(() {
                          if (existingIdx != -1) {
                            if (currentQty <= 0) {
                              _cartItems.removeAt(existingIdx);
                            } else {
                              _cartItems[existingIdx]['qty'] = currentQty;
                              _cartItems[existingIdx]['stock'] = item.stock;
                            }
                          } else if (currentQty > 0) {
                            _cartItems.add({
                              'id': item.id,
                              'code': item.itemCode,
                              'itemName': item.itemName,
                              'name': '${item.itemCode} (${item.itemName})',
                              'unitPrice': item.unitPrice,
                              'qty': currentQty,
                              'unit': item.unit,
                              'stock': item.stock,
                            });
                          }
                        });
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        existingIdx != -1
                            ? (currentQty <= 0
                                  ? 'Remove from Cart'
                                  : 'Update Quantity in Cart')
                            : 'Add to Cart ($currentQty ${item.unit})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
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

  void _updateCartQty(int index, int delta) {
    setState(() {
      final newQty = (_cartItems[index]['qty'] as int) + delta;
      if (newQty <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index]['qty'] = newQty;
      }
    });
  }

  void _openPaymentBottomSheet() {
    if (_selectedShop == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a shop first'),
          backgroundColor: AppColors.roseDanger,
        ),
      );
      return;
    }

    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cart is empty. Add products before proceeding.'),
          backgroundColor: AppColors.roseDanger,
        ),
      );
      return;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    String paymentType = 'CASH';
    final double subtotal = _totalBillPayable;
    final discountController = TextEditingController(text: '0.00');
    final taxController = TextEditingController(text: '0.00');
    final paidAmountController = TextEditingController(
      text: subtotal.toStringAsFixed(2),
    );
    final bankRefController = TextEditingController();
    final notesController = TextEditingController();
    int? selectedBankAccountId;
    XFile? selectedSlipFile;
    String? selectedSlipBase64;

    List<Map<String, dynamic>> splitPayments = [
      {
        'payment_type': 'CASH',
        'amount_controller': TextEditingController(
          text: subtotal.toStringAsFixed(2),
        ),
        'reference_number': '',
        'bank_account_id': null,
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final bankAccountProvider = Provider.of<BankAccountProvider>(
              context,
              listen: false,
            );

            Future<void> pickSlipImage(ImageSource source) async {
              try {
                final picker = ImagePicker();
                final picked = await picker.pickImage(
                  source: source,
                  maxWidth: 1600,
                  maxHeight: 1600,
                  imageQuality: 85,
                );
                if (picked != null) {
                  final bytes = await picked.readAsBytes();
                  final ext = picked.path.split('.').last.toLowerCase();
                  final mime = (ext == 'png') ? 'image/png' : 'image/jpeg';
                  final b64 = 'data:$mime;base64,${base64Encode(bytes)}';
                  setModalState(() {
                    selectedSlipFile = picked;
                    selectedSlipBase64 = b64;
                  });
                }
              } catch (e) {
                debugPrint('Error picking slip image: $e');
              }
            }

            if (selectedBankAccountId == null &&
                bankAccountProvider.listBankAccounts.isNotEmpty) {
              selectedBankAccountId =
                  bankAccountProvider.selectedBankAccount?.id ??
                  bankAccountProvider.listBankAccounts.first.id;
            }

            final double discount =
                double.tryParse(discountController.text) ?? 0.0;
            final double tax = double.tryParse(taxController.text) ?? 0.0;
            final double totalAmount = (subtotal - discount + tax).clamp(
              0.0,
              double.infinity,
            );

            double paidAmount = 0.0;
            List<Map<String, dynamic>>? paymentsPayload;

            if (paymentType == 'SPLIT') {
              paidAmount = 0.0;
              paymentsPayload = [];
              for (var sp in splitPayments) {
                double amt =
                    double.tryParse(sp['amount_controller'].text) ?? 0.0;
                String pType = sp['payment_type'];
                if (pType != 'CREDIT') {
                  paidAmount += amt;
                }
                paymentsPayload.add({
                  'payment_type': pType,
                  'amount': amt,
                  if ((sp['reference_number'] as String).isNotEmpty)
                    'reference_number': sp['reference_number'],
                  if (pType == 'ONLINE' && sp['bank_account_id'] != null)
                    'bank_account_id': sp['bank_account_id'],
                });
              }
            } else {
              paidAmount = double.tryParse(paidAmountController.text) ?? 0.0;
            }

            final double dueAmount = (totalAmount - paidAmount).clamp(
              0.0,
              double.infinity,
            );

            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
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
                            const Text(
                              'Sale Checkout & Payment',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Shop: ${_selectedShop!.shopName}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.primaryOrange,
                                fontWeight: FontWeight.w600,
                              ),
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

                    const Text(
                      'Select Payment Type:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.amberWarning,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children:
                          [
                            {'type': 'CASH', 'label': 'CASH'},
                            {'type': 'CREDIT', 'label': 'CREDIT'},
                            {'type': 'CHEQUE', 'label': 'CHEQUE'},
                            {'type': 'ONLINE', 'label': 'BANK TRF'},
                            {'type': 'SPLIT', 'label': 'SPLIT'},
                          ].map((opt) {
                            final type = opt['type']!;
                            final label = opt['label']!;
                            final isSelected = paymentType == type;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    paymentType = type;
                                    if (type == 'CREDIT') {
                                      paidAmountController.text = '0.00';
                                    } else if (type != 'SPLIT') {
                                      paidAmountController.text = totalAmount
                                          .toStringAsFixed(2);
                                    }
                                  });
                                  if ((type == 'ONLINE' || type == 'SPLIT') &&
                                      bankAccountProvider
                                          .listBankAccounts
                                          .isEmpty) {
                                    bankAccountProvider.getBankAccounts();
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 2,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primaryOrange
                                        : (isDark
                                              ? AppColors.darkInput
                                              : AppColors.lightInput),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primaryOrange
                                          : (isDark
                                                ? AppColors.darkBorder
                                                : AppColors.lightBorder),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.white
                                            : (isDark
                                                  ? AppColors.darkTextMain
                                                  : AppColors.lightTextMain),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkInput
                            : AppColors.lightInput,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Subtotal:',
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                'LKR ${subtotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Payable:',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'LKR ${totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryOrange,
                                ),
                              ),
                            ],
                          ),
                          if (dueAmount > 0) ...[
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Credit / Due Balance:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.roseDanger,
                                  ),
                                ),
                                Text(
                                  'LKR ${dueAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.roseDanger,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    if (paymentType == 'SPLIT') ...[
                      () {
                        double totalSplitAllocated = 0.0;
                        for (var sp in splitPayments) {
                          double amt =
                              double.tryParse(sp['amount_controller'].text) ??
                              0.0;
                          if (sp['payment_type'] != 'CREDIT') {
                            totalSplitAllocated += amt;
                          }
                        }
                        final double remainingToAllocate =
                            totalAmount - totalSplitAllocated;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Allocation Status Banner
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: (remainingToAllocate.abs() < 0.01)
                                    ? AppColors.emeraldSuccess.withOpacity(0.12)
                                    : (remainingToAllocate > 0
                                          ? AppColors.amberWarning.withOpacity(
                                              0.15,
                                            )
                                          : AppColors.roseDanger.withOpacity(
                                              0.15,
                                            )),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: (remainingToAllocate.abs() < 0.01)
                                      ? AppColors.emeraldSuccess
                                      : (remainingToAllocate > 0
                                            ? AppColors.amberWarning
                                            : AppColors.roseDanger),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    (remainingToAllocate.abs() < 0.01)
                                        ? Icons.check_circle_outline
                                        : (remainingToAllocate > 0
                                              ? Icons.info_outline
                                              : Icons.error_outline),
                                    size: 18,
                                    color: (remainingToAllocate.abs() < 0.01)
                                        ? AppColors.emeraldSuccess
                                        : (remainingToAllocate > 0
                                              ? AppColors.amberWarning
                                              : AppColors.roseDanger),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      (remainingToAllocate.abs() < 0.01)
                                          ? '100% Allocated (LKR ${totalAmount.toStringAsFixed(2)})'
                                          : (remainingToAllocate > 0
                                                ? 'Remaining Unallocated: LKR ${remainingToAllocate.toStringAsFixed(2)}'
                                                : 'Overallocated by LKR ${(-remainingToAllocate).toStringAsFixed(2)}'),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            (remainingToAllocate.abs() < 0.01)
                                            ? AppColors.emeraldSuccess
                                            : (remainingToAllocate > 0
                                                  ? AppColors.amberWarning
                                                  : AppColors.roseDanger),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Split Payment Rows
                            ...splitPayments.asMap().entries.map((entry) {
                              int idx = entry.key;
                              var sp = entry.value;
                              final String currentPType =
                                  sp['payment_type'] ?? 'CASH';

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkCard
                                      : AppColors.lightCard,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.darkBorder
                                        : AppColors.lightBorder,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? AppColors.darkInput
                                                : AppColors.lightInput,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: isDark
                                                  ? AppColors.darkBorder
                                                  : AppColors.lightBorder,
                                            ),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              value:
                                                  [
                                                    'CASH',
                                                    'CHEQUE',
                                                    'ONLINE',
                                                    'CARD',
                                                    'CREDIT',
                                                  ].contains(currentPType)
                                                  ? currentPType
                                                  : 'CASH',
                                              dropdownColor: isDark
                                                  ? AppColors.darkCard
                                                  : AppColors.lightCard,
                                              isDense: true,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: isDark
                                                    ? AppColors.darkTextMain
                                                    : AppColors.lightTextMain,
                                              ),
                                              items:
                                                  [
                                                    {
                                                      'type': 'CASH',
                                                      'label': '💵 CASH',
                                                    },
                                                    {
                                                      'type': 'CHEQUE',
                                                      'label': '📄 CHEQUE',
                                                    },
                                                    {
                                                      'type': 'ONLINE',
                                                      'label': '📱 ONLINE',
                                                    },
                                                    {
                                                      'type': 'CARD',
                                                      'label': '💳 CARD',
                                                    },
                                                    {
                                                      'type': 'CREDIT',
                                                      'label': '📝 CREDIT',
                                                    },
                                                  ].map((item) {
                                                    return DropdownMenuItem<
                                                      String
                                                    >(
                                                      value: item['type'],
                                                      child: Text(
                                                        item['label']!,
                                                      ),
                                                    );
                                                  }).toList(),
                                              onChanged: (val) {
                                                if (val != null) {
                                                  setModalState(() {
                                                    sp['payment_type'] = val;
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: TextField(
                                            controller: sp['amount_controller'],
                                            keyboardType:
                                                const TextInputType.numberWithOptions(
                                                  decimal: true,
                                                ),
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            decoration: InputDecoration(
                                              labelText: 'Amount (LKR)',
                                              isDense: true,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 10,
                                                  ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            onChanged: (_) =>
                                                setModalState(() {}),
                                          ),
                                        ),
                                        if (splitPayments.length > 1) ...[
                                          const SizedBox(width: 4),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: AppColors.roseDanger,
                                              size: 20,
                                            ),
                                            onPressed: () => setModalState(
                                              () => splitPayments.removeAt(idx),
                                            ),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                        ],
                                      ],
                                    ),

                                    // Option to auto-fill remaining balance into this row
                                    if (remainingToAllocate > 0.01) ...[
                                      const SizedBox(height: 6),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: InkWell(
                                          onTap: () {
                                            final double currentAmt =
                                                double.tryParse(
                                                  sp['amount_controller'].text,
                                                ) ??
                                                0.0;
                                            final double newAmt =
                                                currentAmt +
                                                remainingToAllocate;
                                            setModalState(() {
                                              sp['amount_controller'].text =
                                                  newAmt.toStringAsFixed(2);
                                            });
                                          },
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryOrange
                                                  .withOpacity(0.12),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '+ Add remaining LKR ${remainingToAllocate.toStringAsFixed(2)} here',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primaryOrange,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],

                                    // Reference & Bank Account input for CHEQUE, ONLINE, or CARD
                                    if ([
                                      'CHEQUE',
                                      'ONLINE',
                                      'CARD',
                                    ].contains(currentPType)) ...[
                                      const SizedBox(height: 8),
                                      if (currentPType == 'ONLINE') ...[
                                        Consumer<BankAccountProvider>(
                                          builder: (context, bankProvider, _) {
                                            final accounts =
                                                bankProvider.listBankAccounts;
                                            final currentBankId =
                                                sp['bank_account_id'] ??
                                                selectedBankAccountId;
                                            return DropdownButtonFormField<int>(
                                              value: currentBankId,
                                              isExpanded: true,
                                              decoration: InputDecoration(
                                                labelText:
                                                    'Select Agent Bank Account',
                                                isDense: true,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 8,
                                                    ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              items: accounts.map((acc) {
                                                return DropdownMenuItem<int>(
                                                  value: acc.id,
                                                  child: Text(
                                                    '${acc.bankName} (${acc.accountNumber})',
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (val) {
                                                if (val != null) {
                                                  setModalState(() {
                                                    sp['bank_account_id'] = val;
                                                  });
                                                }
                                              },
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                      TextField(
                                        style: const TextStyle(fontSize: 12),
                                        decoration: InputDecoration(
                                          labelText: currentPType == 'CHEQUE'
                                              ? 'Cheque Number / Bank Name'
                                              : (currentPType == 'ONLINE'
                                                    ? 'Bank Transfer Ref No.'
                                                    : 'Card Ref / Terminal ID'),
                                          hintText: currentPType == 'CHEQUE'
                                              ? 'e.g. CHQ-884021'
                                              : 'e.g. TXN-994012',
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 8,
                                              ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        onChanged: (val) =>
                                            sp['reference_number'] = val,
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }),

                            // Add Payment Row Button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${splitPayments.length} payment mode(s)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? AppColors.darkTextSub
                                        : AppColors.lightTextSub,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    final double defaultAmt =
                                        remainingToAllocate > 0
                                        ? remainingToAllocate
                                        : 0.0;
                                    setModalState(() {
                                      splitPayments.add({
                                        'payment_type': 'CHEQUE',
                                        'amount_controller':
                                            TextEditingController(
                                              text: defaultAmt.toStringAsFixed(
                                                2,
                                              ),
                                            ),
                                        'reference_number': '',
                                        'bank_account_id': null,
                                      });
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryOrange,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text(
                                    'Add Payment Mode',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                          ],
                        );
                      }(),
                    ] else ...[
                      // Dedicated Agent Bank Account selector card for Bank Transfer
                      if (paymentType == 'ONLINE') ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkInput
                                : AppColors.lightInput,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primaryOrange.withValues(
                                alpha: 0.6,
                              ),
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.account_balance,
                                    color: AppColors.primaryOrange,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Select Agent Bank Account',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryOrange,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryOrange.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Required',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryOrange,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Consumer<BankAccountProvider>(
                                builder: (context, bankProvider, _) {
                                  final accounts =
                                      bankProvider.listBankAccounts;

                                  if (bankProvider.isLoading) {
                                    return const SizedBox(
                                      height: 48,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: AppColors.primaryOrange,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    );
                                  }

                                  if (accounts.isEmpty) {
                                    return Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppColors.amberWarning
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: AppColors.amberWarning
                                              .withValues(alpha: 0.5),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.info_outline,
                                            color: AppColors.amberWarning,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          const Expanded(
                                            child: Text(
                                              'No bank accounts loaded.',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: AppColors.amberWarning,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () =>
                                                bankProvider.getBankAccounts(),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              child: Text(
                                                'Reload',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color:
                                                      AppColors.primaryOrange,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  final validSelectedId =
                                      accounts.any(
                                        (b) => b.id == selectedBankAccountId,
                                      )
                                      ? selectedBankAccountId
                                      : accounts.first.id;

                                  return DropdownButtonFormField<int>(
                                    value: validSelectedId,
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      labelText: 'Receiving Bank Account',
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 10,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    items: accounts.map((acc) {
                                      return DropdownMenuItem<int>(
                                        value: acc.id,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '${acc.bankName} - ${acc.accountNumber}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (acc.isDefault)
                                              Container(
                                                margin: const EdgeInsets.only(
                                                  left: 4,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 4,
                                                      vertical: 1,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppColors
                                                      .emeraldSuccess
                                                      .withValues(alpha: 0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: const Text(
                                                  'DEFAULT',
                                                  style: TextStyle(
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors
                                                        .emeraldSuccess,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setModalState(() {
                                          selectedBankAccountId = val;
                                        });
                                      }
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              // Account Detail Card
                              () {
                                final matched = bankAccountProvider
                                    .listBankAccounts
                                    .where(
                                      (b) => b.id == selectedBankAccountId,
                                    );
                                if (matched.isNotEmpty) {
                                  final b = matched.first;
                                  return Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(8),
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.darkCard
                                          : AppColors.lightCard,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isDark
                                            ? AppColors.darkBorder
                                            : AppColors.lightBorder,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Account Name: ${b.accountName}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Branch: ${b.branchName}',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: isDark
                                                    ? AppColors.darkTextSub
                                                    : AppColors.lightTextSub,
                                              ),
                                            ),
                                            Text(
                                              'A/C: ${b.accountNumber}',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primaryOrange,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              }(),
                              TextField(
                                controller: bankRefController,
                                style: const TextStyle(fontSize: 12),
                                decoration: InputDecoration(
                                  labelText: 'Bank Transfer Ref / Slip Number',
                                  hintText: 'e.g. TXN-998841 / Slip Ref',
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 10,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkCard.withOpacity(0.5)
                                      : Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: selectedSlipFile != null
                                        ? AppColors.emeraldSuccess.withOpacity(
                                            0.6,
                                          )
                                        : (isDark
                                              ? AppColors.darkBorder
                                              : AppColors.lightBorder),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.receipt_long,
                                              size: 16,
                                              color: selectedSlipFile != null
                                                  ? AppColors.emeraldSuccess
                                                  : AppColors.primaryOrange,
                                            ),
                                            const SizedBox(width: 6),
                                            const Text(
                                              'Bank Clip / Slip Receipt Photo',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (selectedSlipFile != null)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.emeraldSuccess
                                                  .withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.check_circle,
                                                  size: 10,
                                                  color:
                                                      AppColors.emeraldSuccess,
                                                ),
                                                SizedBox(width: 3),
                                                Text(
                                                  'ATTACHED',
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors
                                                        .emeraldSuccess,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (selectedSlipFile != null) ...[
                                      Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            child: Image.file(
                                              File(selectedSlipFile!.path),
                                              width: 55,
                                              height: 55,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  selectedSlipFile!.name,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                const Text(
                                                  'Ready to record with sale',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    InkWell(
                                                      onTap: () =>
                                                          pickSlipImage(
                                                            ImageSource.camera,
                                                          ),
                                                      child: const Row(
                                                        children: [
                                                          Icon(
                                                            Icons.camera_alt,
                                                            size: 12,
                                                            color: AppColors
                                                                .primaryOrange,
                                                          ),
                                                          SizedBox(width: 3),
                                                          Text(
                                                            'Retake',
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              color: AppColors
                                                                  .primaryOrange,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 14),
                                                    InkWell(
                                                      onTap: () {
                                                        setModalState(() {
                                                          selectedSlipFile =
                                                              null;
                                                          selectedSlipBase64 =
                                                              null;
                                                        });
                                                      },
                                                      child: const Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .delete_outline,
                                                            size: 12,
                                                            color: AppColors
                                                                .roseDanger,
                                                          ),
                                                          SizedBox(width: 3),
                                                          Text(
                                                            'Remove',
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              color: AppColors
                                                                  .roseDanger,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ] else ...[
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: () => pickSlipImage(
                                                ImageSource.camera,
                                              ),
                                              icon: const Icon(
                                                Icons.camera_alt,
                                                size: 14,
                                                color: AppColors.primaryOrange,
                                              ),
                                              label: const Text(
                                                'Take Photo',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color:
                                                      AppColors.primaryOrange,
                                                ),
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                side: const BorderSide(
                                                  color:
                                                      AppColors.primaryOrange,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: () => pickSlipImage(
                                                ImageSource.gallery,
                                              ),
                                              icon: Icon(
                                                Icons.photo_library,
                                                size: 14,
                                                color: isDark
                                                    ? AppColors.darkTextMain
                                                    : AppColors.lightTextMain,
                                              ),
                                              label: Text(
                                                'Upload Slip',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: isDark
                                                      ? AppColors.darkTextMain
                                                      : AppColors.lightTextMain,
                                                ),
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                side: BorderSide(
                                                  color: isDark
                                                      ? AppColors.darkBorder
                                                      : AppColors.lightBorder,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Paid Amount (LKR):',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                TextField(
                                  controller: paidAmountController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 10,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onChanged: (_) => setModalState(() {}),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Discount (LKR):',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                TextField(
                                  controller: discountController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 10,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onChanged: (_) => setModalState(() {}),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],

                    const Text(
                      'Sale Notes (Optional):',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: notesController,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Add transaction note...',
                        hintStyle: const TextStyle(fontSize: 11),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Consumer<SalesProvider>(
                      builder: (context, salesProvider, _) {
                        return SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: salesProvider.isLoading
                                ? null
                                : () async {
                                    if (paymentType == 'ONLINE' &&
                                        (selectedBankAccountId == null ||
                                            selectedBankAccountId == 0)) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Please select an agent bank account for the bank transfer.',
                                          ),
                                          backgroundColor: AppColors.roseDanger,
                                        ),
                                      );
                                      return;
                                    }

                                    if (paidAmount < 0 ||
                                        paidAmount > totalAmount) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Payment must be between zero and the invoice total.',
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    final itemsPayload = _cartItems.map((c) {
                                      return {
                                        'item_id': c['id'],
                                        'quantity': c['qty'] as int,
                                        'unit_price': c['unitPrice'] as double,
                                        'discount': 0.0,
                                      };
                                    }).toList();

                                    try {
                                      final result = await salesProvider
                                          .createSale(
                                            shopId: _selectedShop!.id,
                                            paymentType: paymentType,
                                            bankAccountId:
                                                paymentType == 'ONLINE'
                                                ? selectedBankAccountId
                                                : null,
                                            referenceNumber:
                                                paymentType == 'ONLINE'
                                                ? bankRefController.text
                                                : null,
                                            bankSlip: paymentType == 'ONLINE'
                                                ? selectedSlipBase64
                                                : null,
                                            discount: discount,
                                            tax: tax,
                                            paidAmount: paidAmount,
                                            notes: notesController.text,
                                            items: itemsPayload,
                                            payments: paymentsPayload,
                                          );

                                      if (result != null) {
                                        if (ctx.mounted) Navigator.pop(ctx);
                                        final saleCode =
                                            result['sale_code'] ??
                                            'SALE-COMPLETED';
                                        if (context.mounted) {
                                          String? bankInfo;
                                          if (paymentType == 'ONLINE' &&
                                              selectedBankAccountId != null) {
                                            final matched = bankAccountProvider
                                                .listBankAccounts
                                                .where(
                                                  (b) =>
                                                      b.id ==
                                                      selectedBankAccountId,
                                                );
                                            if (matched.isNotEmpty) {
                                              bankInfo =
                                                  '${matched.first.bankName} (${matched.first.accountNumber})';
                                            }
                                          }
                                          _showSaleSuccessDialog(
                                            saleCode,
                                            totalAmount,
                                            paidAmount,
                                            paymentType == 'ONLINE'
                                                ? 'BANK TRANSFER'
                                                : paymentType,
                                            bankInfo: bankInfo,
                                            refNo: paymentType == 'ONLINE'
                                                ? bankRefController.text
                                                : null,
                                          );
                                          _clearCart();
                                          final repId = context
                                              .read<AuthProvider>()
                                              .user
                                              ?.id;
                                          if (repId != null) {
                                            await context
                                                .read<ItemProvider>()
                                                .getRepStocks(repId);
                                          }
                                          if (context.mounted) {
                                            await context
                                                .read<ShopProvider>()
                                                .getTodayVisitedShops();
                                          }
                                        }
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Failed to record sale: $e',
                                            ),
                                            backgroundColor:
                                                AppColors.roseDanger,
                                          ),
                                        );
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryOrange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: salesProvider.isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  )
                                : Text(
                                    'Confirm & Record Sale (LKR ${totalAmount.toStringAsFixed(2)})',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _shareToWhatsApp(
    String saleCode,
    double total,
    double paid,
    String paymentType,
  ) async {
    final shopName = _selectedShop?.shopName ?? "Customer";
    final phone = _selectedShop?.phone;

    final message =
        '''
*Invoice Receipt*
Shop: $shopName
Transaction Code: $saleCode
Total Amount: LKR ${total.toStringAsFixed(2)}
Paid Amount: LKR ${paid.toStringAsFixed(2)}
Payment Method: $paymentType

Thank you for your business!
''';

    String? formattedPhone;
    if (phone != null && phone.isNotEmpty) {
      String cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
      if (cleanPhone.startsWith('0') && cleanPhone.length == 10) {
        cleanPhone = '94${cleanPhone.substring(1)}';
      } else if (!cleanPhone.startsWith('94') && cleanPhone.length == 9) {
        cleanPhone = '94$cleanPhone';
      }
      formattedPhone = cleanPhone;
    }

    Uri uri;
    if (formattedPhone != null) {
      uri = Uri.parse(
        'whatsapp://send?phone=$formattedPhone&text=${Uri.encodeComponent(message)}',
      );
    } else {
      uri = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(message)}');
    }

    try {
      bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        if (mounted)
          AppSnackBar.showError(
            context,
            message: 'Could not launch WhatsApp. Is it installed?',
          );
      }
    } catch (e) {
      if (mounted)
        AppSnackBar.showError(context, message: 'Failed to open WhatsApp');
    }
  }

  void _showSaleSuccessDialog(
    String saleCode,
    double total,
    double paid,
    String paymentType, {
    String? bankInfo,
    String? refNo,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
            title: const Text(
              'Sale Receipt',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.receipt_long,
                    size: 64,
                    color: Colors.black87,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _selectedShop?.shopName ?? "Customer",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_selectedShop?.phone != null &&
                      _selectedShop!.phone.isNotEmpty)
                    Text(
                      _selectedShop!.phone,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  const SizedBox(height: 32),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildReceiptRow('Receipt No', saleCode, isBold: true),
                        const SizedBox(height: 12),
                        _buildReceiptRow('Payment Method', paymentType),
                        if (bankInfo != null && bankInfo.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _buildReceiptRow('Bank', bankInfo),
                        ],
                        if (refNo != null && refNo.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _buildReceiptRow('Ref No', refNo),
                        ],
                        const SizedBox(height: 12),
                        _buildReceiptRow(
                          'Date & Time',
                          '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Divider(color: Colors.grey, thickness: 1),
                        ),
                        _buildReceiptRow(
                          'Total Amount',
                          'LKR ${total.toStringAsFixed(2)}',
                          isBold: true,
                          isLarge: true,
                        ),
                        const SizedBox(height: 8),
                        _buildReceiptRow(
                          'Paid Amount',
                          'LKR ${paid.toStringAsFixed(2)}',
                        ),
                        const SizedBox(height: 8),
                        _buildReceiptRow(
                          'Balance Due',
                          'LKR ${(total - paid).clamp(0.0, double.infinity).toStringAsFixed(2)}',
                          isHighlight: true,
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  const Text(
                    'Thank you for your business!',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // WhatsApp Share Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _shareToWhatsApp(saleCode, total, paid, paymentType),
                      icon: const Icon(Icons.chat, color: Colors.white),
                      label: const Text(
                        'Share to WhatsApp',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF25D366,
                        ), // WhatsApp Brand Color
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(
    String label,
    String value, {
    bool isBold = false,
    bool isLarge = false,
    bool isHighlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isLarge ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: isLarge ? 18 : 14,
              fontWeight: (isBold || isHighlight)
                  ? FontWeight.w900
                  : FontWeight.bold,
              color: isHighlight ? AppColors.roseDanger : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Consumer<ShopProvider>(
                      builder: (context, shopProvider, _) {
                        final shops = shopProvider.listShops;

                        if (_selectedShop == null && shops.isNotEmpty) {
                          _selectedShop = shops.first;
                        } else if (_selectedShop != null && shops.isNotEmpty) {
                          final matchIndex = shops.indexWhere(
                            (s) =>
                                s.id == _selectedShop!.id ||
                                s.shopName == _selectedShop!.shopName,
                          );
                          if (matchIndex != -1) {
                            _selectedShop = shops[matchIndex];
                          }
                        }

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkCard
                                : AppColors.lightCard,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<ShopModel>(
                              value:
                                  (shops.isNotEmpty &&
                                      _selectedShop != null &&
                                      shops.contains(_selectedShop))
                                  ? _selectedShop
                                  : null,
                              hint: Text(
                                _selectedShop != null
                                    ? '${_selectedShop!.shopName} (${_selectedShop!.shopCode.isNotEmpty ? _selectedShop!.shopCode : "SH-${_selectedShop!.id}"})'
                                    : (shopProvider.isLoading
                                          ? 'Loading shops...'
                                          : 'Select Shop'),
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                  color: isDark
                                      ? AppColors.darkTextMain
                                      : AppColors.lightTextMain,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              isExpanded: true,
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: AppColors.primaryOrange,
                              ),
                              dropdownColor: isDark
                                  ? AppColors.darkCard
                                  : AppColors.lightCard,
                              items: shops.map((ShopModel shop) {
                                return DropdownMenuItem<ShopModel>(
                                  value: shop,
                                  child: Text(
                                    '${shop.shopName} (${shop.shopCode.isNotEmpty ? shop.shopCode : "SH-${shop.id}"})',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? AppColors.darkTextMain
                                          : AppColors.lightTextMain,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (ShopModel? newShop) {
                                if (newShop != null) {
                                  setState(() {
                                    _selectedShop = newShop;
                                  });
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _selectedShop = null;
                      });
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkCard
                            : AppColors.lightCard,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                      ),
                      child: const Icon(Icons.close, size: 16),
                    ),
                  ),
                ],
              ),

              if (_selectedShop != null) ...[
                const SizedBox(height: 8),
                LocationStatusChip(
                  shopLat: _selectedShop!.latitude,
                  shopLng: _selectedShop!.longitude,
                ),
              ],

              const SizedBox(height: 12),

              // Product Catalog Header
              const Text(
                'HANDHELD STOCK CATALOG (TAP ITEM TO SET QUANTITY):',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.amberWarning,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                child: TextField(
                  onChanged: (val) {
                    setState(() {
                      _productSearchQuery = val;
                    });
                  },
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.darkTextMain
                        : AppColors.lightTextMain,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Search product by name or code...',
                    hintStyle: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSub
                          : AppColors.lightTextSub,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      size: 18,
                      color: AppColors.cyanAccent,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Product Catalog ListView
              Consumer<ItemProvider>(
                builder: (context, itemProvider, _) {
                  final List<ItemModel> rawItems = itemProvider.listRepStocks
                      .where((s) => s.quantity > 0)
                      .map(
                        (s) => ItemModel(
                          id: s.itemId != 0 ? s.itemId : s.id,
                          itemCode: s.itemCode,
                          itemName: s.itemName,
                          category: 'Handheld Stock',
                          unitPrice: s.unitPrice,
                          unit: s.unit,
                          stock: s.quantity,
                        ),
                      )
                      .toList();

                  final items = rawItems.where((catItem) {
                    final query = _productSearchQuery.toLowerCase().trim();
                    if (query.isEmpty) return true;
                    return catItem.itemName.toLowerCase().contains(query) ||
                        catItem.itemCode.toLowerCase().contains(query);
                  }).toList();

                  return SizedBox(
                    height: 140,
                    child: itemProvider.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryOrange,
                            ),
                          )
                        : items.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.inventory_2_outlined,
                                    size: 28,
                                    color: AppColors.darkTextSub,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _productSearchQuery.isNotEmpty
                                        ? 'No handled stock items found matching "$_productSearchQuery"'
                                        : 'No handheld stock available for sale. Please request stock from warehouse.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.darkTextSub
                                          : AppColors.lightTextSub,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final catItem = items[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkCard
                                      : AppColors.lightCard,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.darkBorder
                                        : AppColors.lightBorder,
                                  ),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () => _openQuantityDialog(catItem),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                catItem.itemName,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                  color: isDark
                                                      ? AppColors.darkTextMain
                                                      : AppColors.lightTextMain,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: AppColors
                                                          .amberWarning
                                                          .withValues(
                                                            alpha: 0.12,
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      catItem.itemCode,
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                        color: AppColors
                                                            .amberWarning,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Stock: ${catItem.stock} ${catItem.unit}',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: isDark
                                                          ? AppColors
                                                                .darkTextSub
                                                          : AppColors
                                                                .lightTextSub,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'LKR ${catItem.unitPrice.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: AppColors.emeraldSuccess,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryOrange
                                                    .withValues(alpha: 0.15),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.add,
                                                size: 14,
                                                color: AppColors.primaryOrange,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // POS Cart Items Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.shopping_cart_outlined,
                        size: 16,
                        color: AppColors.primaryOrange,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'POS CART ITEMS (${_cartItems.length} LINES):',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryOrange,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  if (_cartItems.isNotEmpty)
                    GestureDetector(
                      onTap: _clearCart,
                      child: const Row(
                        children: [
                          Icon(
                            Icons.delete_sweep_outlined,
                            size: 14,
                            color: AppColors.roseDanger,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Clear Cart',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.roseDanger,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Cart Items List
              Expanded(
                child: _cartItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_shopping_cart_outlined,
                              size: 36,
                              color: isDark
                                  ? AppColors.darkTextSub
                                  : AppColors.lightTextSub,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Cart is empty. Tap products above to add to cart.',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.darkTextSub
                                    : AppColors.lightTextSub,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          final cartItem = _cartItems[index];
                          final lineTotal =
                              (cartItem['unitPrice'] as double) *
                              (cartItem['qty'] as int);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkCard
                                  : AppColors.lightCard,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primaryOrange.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      final itemCode =
                                          (cartItem['code'] ?? '') as String;
                                      final itemName =
                                          (cartItem['itemName'] ??
                                                  cartItem['name'] ??
                                                  '')
                                              as String;
                                      final unitPrice =
                                          (cartItem['unitPrice'] as double);
                                      final unit =
                                          (cartItem['unit'] ?? 'unit')
                                              as String;

                                      _openQuantityDialog(
                                        ItemModel(
                                          id: 0,
                                          itemCode: itemCode.isNotEmpty
                                              ? itemCode
                                              : 'ITEM',
                                          itemName: itemName,
                                          category: 'General',
                                          unitPrice: unitPrice,
                                          unit: unit,
                                          stock: 999,
                                        ),
                                      );
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cartItem['name'] as String,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: isDark
                                                ? AppColors.darkTextMain
                                                : AppColors.lightTextMain,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'LKR ${(cartItem['unitPrice'] as double).toStringAsFixed(2)} Ã— ${cartItem['qty']} = LKR ${lineTotal.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.amberWarning,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    // Quantity Stepper Controls
                                    Container(
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? AppColors.darkInput
                                            : AppColors.lightInput,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          InkWell(
                                            onTap: () =>
                                                _updateCartQty(index, -1),
                                            borderRadius:
                                                const BorderRadius.horizontal(
                                                  left: Radius.circular(8),
                                                ),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 6,
                                              ),
                                              child: Icon(
                                                Icons.remove,
                                                size: 14,
                                                color: AppColors.roseDanger,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                            child: Text(
                                              '${cartItem['qty']}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () =>
                                                _updateCartQty(index, 1),
                                            borderRadius:
                                                const BorderRadius.horizontal(
                                                  right: Radius.circular(8),
                                                ),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 6,
                                              ),
                                              child: Icon(
                                                Icons.add,
                                                size: 14,
                                                color: AppColors.emeraldSuccess,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: () => _updateCartQty(
                                        index,
                                        -(cartItem['qty'] as int),
                                      ),
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: AppColors.roseDanger,
                                        size: 18,
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              // Footer Total & Proceed Button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TOTAL BILL PAYABLE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkTextSub,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'LKR ${_totalBillPayable.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: _openPaymentBottomSheet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        '      Checkout    ',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
