import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dsr_models.dart';
import '../models/item_model.dart';
import '../provider/item_provider.dart';
import '../theme/app_theme.dart';

class InvoiceCreationScreen extends StatefulWidget {
  final Outlet? initialOutlet;

  const InvoiceCreationScreen({super.key, this.initialOutlet});

  @override
  State<InvoiceCreationScreen> createState() => _InvoiceCreationScreenState();
}

class _InvoiceCreationScreenState extends State<InvoiceCreationScreen> {
  Outlet? _selectedOutlet;
  String _productSearchQuery = '';
  final List<Map<String, dynamic>> _cartItems = [
    {
      'name': 'CARD-100 (Recharge Card)',
      'unitPrice': 96.00,
      'qty': 50,
      'unit': 'unit',
    },
    {
      'name': 'SIM-4G (4G SIM Pack)',
      'unitPrice': 250.00,
      'qty': 10,
      'unit': 'pack',
    },
  ];

  final List<Map<String, dynamic>> _catalogItems = [
    {
      'name': 'Hutch Rs. 100 Recharge Card',
      'code': 'CARD-100',
      'stock': '500 units',
      'price': 96.00,
    },
    {
      'name': 'Hutch Rs. 500 Super Card',
      'code': 'CARD-500',
      'stock': '430 units',
      'price': 480.00,
    },
    {
      'name': 'Hutch 4G SIM Starter Pack',
      'code': 'SIM-4G',
      'stock': '30 units',
      'price': 250.00,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedOutlet = widget.initialOutlet;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final itemProvider = Provider.of<ItemProvider>(context, listen: false);
      if (itemProvider.listItems.isEmpty) {
        itemProvider.getItems();
      }
    });
  }

  double get _totalBillPayable {
    return _cartItems.fold(0.0, (sum, item) => sum + ((item['unitPrice'] as double) * (item['qty'] as int)));
  }

  void _clearCart() {
    setState(() {
      _cartItems.clear();
    });
  }

  void _addToCart(String code, String name, double price, String unit) {
    setState(() {
      final index = _cartItems.indexWhere((item) =>
          (item['name'] as String).contains(code) || (item['name'] as String).contains(name));
      if (index >= 0) {
        _cartItems[index]['qty'] = (_cartItems[index]['qty'] as int) + 1;
      } else {
        _cartItems.add({
          'name': '$code ($name)',
          'unitPrice': price,
          'qty': 1,
          'unit': unit,
        });
      }
    });
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
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.lightCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _selectedOutlet != null ? '${_selectedOutlet!.shopName} (SH-${_selectedOutlet!.id})' : 'Shanika Communication (SH-1008)',
                            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                          ),
                          const Icon(Icons.arrow_drop_down, color: AppColors.primaryOrange),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.lightCard,
                        shape: BoxShape.circle,
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                      child: const Icon(Icons.close, size: 16),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 12),

              // Product Catalog Header
              const Text(
                'PRODUCT CATALOG (TAP ITEM TO SET QUANTITY):',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.cyanAccent, letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),
              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
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
                    color: isDark ? AppColors.darkTextMain : AppColors.lightTextMain,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Search product by name or code...',
                    hintStyle: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub,
                    ),
                    prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.cyanAccent),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                  final rawItems = itemProvider.listItems.isNotEmpty
                      ? itemProvider.listItems
                      : _catalogItems.map((e) => ItemModel(
                            id: 0,
                            itemCode: e['code'] as String,
                            itemName: e['name'] as String,
                            category: 'General',
                            unitPrice: e['price'] as double,
                            stock: int.tryParse((e['stock'] as String).split(' ').first) ?? 0,
                          )).toList();

                  final items = rawItems.where((catItem) {
                    final query = _productSearchQuery.toLowerCase().trim();
                    if (query.isEmpty) return true;
                    return catItem.itemName.toLowerCase().contains(query) ||
                        catItem.itemCode.toLowerCase().contains(query);
                  }).toList();

                  return SizedBox(
                    height: 140,
                    child: itemProvider.isLoading
                        ? const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange))
                        : items.isEmpty
                            ? Center(
                                child: Text(
                                  'No items found matching "$_productSearchQuery"',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub,
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
                                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(10),
                                      onTap: () => _addToCart(catItem.itemCode, catItem.itemName, catItem.unitPrice, catItem.unit),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    catItem.itemName,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 12,
                                                      color: isDark ? AppColors.darkTextMain : AppColors.lightTextMain,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: AppColors.cyanAccent.withValues(alpha: 0.12),
                                                          borderRadius: BorderRadius.circular(4),
                                                        ),
                                                        child: Text(
                                                          catItem.itemCode,
                                                          style: const TextStyle(fontSize: 10, color: AppColors.cyanAccent, fontWeight: FontWeight.bold),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        'Stock: ${catItem.stock} ${catItem.unit}',
                                                        style: TextStyle(fontSize: 10, color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub),
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
                                                    color: AppColors.primaryOrange.withValues(alpha: 0.15),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(Icons.add, size: 14, color: AppColors.primaryOrange),
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
                      const Icon(Icons.shopping_cart_outlined, size: 16, color: AppColors.primaryOrange),
                      const SizedBox(width: 6),
                      Text(
                        'POS CART ITEMS (${_cartItems.length} LINES):',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryOrange, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                  if (_cartItems.isNotEmpty)
                    GestureDetector(
                      onTap: _clearCart,
                      child: const Row(
                        children: [
                          Icon(Icons.delete_sweep_outlined, size: 14, color: AppColors.roseDanger),
                          SizedBox(width: 4),
                          Text(
                            'Clear Cart',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.roseDanger),
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
                            Icon(Icons.add_shopping_cart_outlined, size: 36, color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub),
                            const SizedBox(height: 8),
                            Text(
                              'Cart is empty. Tap products above to add to cart.',
                              style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          final cartItem = _cartItems[index];
                          final lineTotal = (cartItem['unitPrice'] as double) * (cartItem['qty'] as int);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCard : AppColors.lightCard,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cartItem['name'] as String,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: isDark ? AppColors.darkTextMain : AppColors.lightTextMain,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'LKR ${(cartItem['unitPrice'] as double).toStringAsFixed(2)} × ${cartItem['qty']} = LKR ${lineTotal.toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 11, color: AppColors.cyanAccent, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    // Quantity Stepper Controls
                                    Container(
                                      decoration: BoxDecoration(
                                        color: isDark ? AppColors.darkInput : AppColors.lightInput,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          InkWell(
                                            onTap: () => _updateCartQty(index, -1),
                                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                              child: Icon(Icons.remove, size: 14, color: AppColors.roseDanger),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                            child: Text(
                                              '${cartItem['qty']}',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () => _updateCartQty(index, 1),
                                            borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                              child: Icon(Icons.add, size: 14, color: AppColors.emeraldSuccess),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: () => _updateCartQty(index, -(cartItem['qty'] as int)),
                                      icon: const Icon(Icons.delete_outline, color: AppColors.roseDanger, size: 18),
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
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TOTAL BILL PAYABLE',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.darkTextSub),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'LKR ${_totalBillPayable.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Proceeding to Multi-Payment...'),
                            backgroundColor: AppColors.emeraldSuccess,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text(
                        'Proceed to Multi-Payment →',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
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
