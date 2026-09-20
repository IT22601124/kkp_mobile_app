import 'package:flutter/material.dart';
import '../models/dsr_models.dart';
import '../theme/app_theme.dart';

class InvoiceCreationScreen extends StatefulWidget {
  final Outlet? initialOutlet;

  const InvoiceCreationScreen({super.key, this.initialOutlet});

  @override
  State<InvoiceCreationScreen> createState() => _InvoiceCreationScreenState();
}

class _InvoiceCreationScreenState extends State<InvoiceCreationScreen> {
  Outlet? _selectedOutlet;
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
  }

  double get _totalBillPayable {
    return _cartItems.fold(0.0, (sum, item) => sum + ((item['unitPrice'] as double) * (item['qty'] as int)));
  }

  void _clearCart() {
    setState(() {
      _cartItems.clear();
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
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '⚡ HUTCH ENTERPRISE POS TERMINAL',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryOrange,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _selectedOutlet?.shopName ?? 'Shanika Communication',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      shape: BoxShape.circle,
                      border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Shop Selector Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedOutlet != null ? '${_selectedOutlet!.shopName} (SH-${_selectedOutlet!.id})' : 'Shanika Communication (SH-1008)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const Icon(Icons.arrow_drop_down, color: AppColors.primaryOrange),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search item name or code (CARD-100, 4G, Reload...)',
                  prefixIcon: const Icon(Icons.search, color: AppColors.cyanAccent, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                ),
              ),
              const SizedBox(height: 16),

              // Product Catalog Header
              const Text(
                'PRODUCT CATALOG (TAP ITEM TO SET QUANTITY):',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.cyanAccent, letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),

              // Product Catalog ListView
              SizedBox(
                height: 180,
                child: ListView.builder(
                  itemCount: _catalogItems.length,
                  itemBuilder: (context, index) {
                    final catItem = _catalogItems[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.lightCard,
                        borderRadius: BorderRadius.circular(14),
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
                                  catItem['name'] as String,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isDark ? AppColors.darkTextMain : AppColors.lightTextMain,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Code: ${catItem['code']} | Stock: ${catItem['stock']}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.cyanAccent),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '+ LKR ${catItem['price'].toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.emeraldSuccess,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // POS Cart Items Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'POS CART ITEMS (2 LINES):',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryOrange, letterSpacing: 0.5),
                  ),
                  GestureDetector(
                    onTap: _clearCart,
                    child: const Text(
                      'Clear Cart',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.roseDanger),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Cart Items List
              Expanded(
                child: ListView.builder(
                  itemCount: _cartItems.length,
                  itemBuilder: (context, index) {
                    final cartItem = _cartItems[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.lightCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primaryOrange.withOpacity(0.4)),
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
                                  'LKR ${cartItem['unitPrice'].toStringAsFixed(2)} / ${cartItem['unit']}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.cyanAccent),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 70,
                                height: 36,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkInput : AppColors.lightInput,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    '${cartItem['qty']}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _cartItems.removeAt(index);
                                  });
                                },
                                icon: const Icon(Icons.delete_outline, color: AppColors.roseDanger, size: 20),
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
