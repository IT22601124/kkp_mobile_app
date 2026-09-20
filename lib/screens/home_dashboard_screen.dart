import 'package:flutter/material.dart';
import '../models/dsr_models.dart';
import '../theme/app_theme.dart';
import '../widgets/register_shop_bottom_sheet.dart';

class HomeDashboardScreen extends StatelessWidget {
  final DsrRepProfile profile;
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final Function(int) onNavigateTab;

  const HomeDashboardScreen({
    super.key,
    required this.profile,
    required this.isDarkMode,
    required this.onToggleTheme,
    required this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 2. Sales Revenue KPI Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TODAY SALES REVENUE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '90% Target',
                        style: TextStyle(
                          color: AppColors.primaryOrange,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'LKR 45,000.00',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryOrange,
                  ),
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: 0.9,
                    minHeight: 8,
                    backgroundColor: isDark ? AppColors.darkInput : AppColors.lightInput,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryOrange),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Achieved: LKR 45,000',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub,
                      ),
                    ),
                    Text(
                      'Target: LKR 50,000',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Register Shop & Request Stock Action Cards
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => RegisterShopBottomSheet.show(context),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.emeraldSuccess.withOpacity(0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.emeraldSuccess.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.storefront, color: AppColors.emeraldSuccess, size: 24),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Register Shop',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '+ Add Retail Outlet',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => _showRequestStockBottomSheet(context),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cyanAccent.withOpacity(0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.cyanAccent.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.inventory_2_outlined, color: AppColors.cyanAccent, size: 24),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Request Stock',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Multi-Item Hub Request',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 4. Handheld Stock Balance
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Handheld Stock Balance',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () => onNavigateTab(1),
                child: const Row(
                  children: [
                    Text(
                      'View Stock Bag',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.cyanAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 14, color: AppColors.cyanAccent),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStockCard('CARDS', '500', isDark),
              const SizedBox(width: 10),
              _buildStockCard('4G SIMS', '30', isDark),
              const SizedBox(width: 10),
              _buildStockCard('RELOAD', '117.1K', isDark, isPrimary: true),
            ],
          ),
          const SizedBox(height: 24),

          // 5. Route Outlets (4 Shops)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Route Outlets (4 Shops)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.emeraldSuccess.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '2 Visited',
                  style: TextStyle(
                    color: AppColors.emeraldSuccess,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildOutletCard(
            context,
            name: 'Saman Stores',
            code: 'SH-1002',
            address: 'Main Street, Dampola',
            saleInfo: 'Sale: LKR 12,500 | Cash Paid',
            status: 'Visited',
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _buildOutletCard(
            context,
            name: 'Lanka Traders',
            code: 'SH-1004',
            address: 'Market Place',
            saleInfo: 'Sale: LKR 8,400 | Cash Paid',
            status: 'Visited',
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _buildOutletCard(
            context,
            name: 'Shanika Communication',
            code: 'SH-1008',
            address: 'Bus Stand Junction',
            saleInfo: 'Credit Outstanding: LKR 14,000',
            isCreditWarning: true,
            showPosButton: true,
            isDark: isDark,
            onPosTap: () => onNavigateTab(3),
          ),
          const SizedBox(height: 10),
          _buildOutletCard(
            context,
            name: 'Kandy Mini Mart',
            code: 'SH-1010',
            address: 'Temple Road',
            saleInfo: 'Pending Visit',
            isDark: isDark,
          ),
          const SizedBox(height: 80), // Padding for bottom nav / FAB
        ],
      ),
    );
  }

  Widget _buildStockCard(String title, String value, bool isDark, {bool isPrimary = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primaryOrange.withOpacity(0.15) : (isDark ? AppColors.darkCard : AppColors.lightCard),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isPrimary ? AppColors.primaryOrange : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isPrimary ? AppColors.primaryOrange : (isDark ? AppColors.darkTextSub : AppColors.lightTextSub),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isPrimary ? AppColors.primaryOrange : (isDark ? AppColors.darkTextMain : AppColors.lightTextMain),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutletCard(
    BuildContext context, {
    required String name,
    required String code,
    required String address,
    required String saleInfo,
    String? status,
    bool isCreditWarning = false,
    bool showPosButton = false,
    required bool isDark,
    VoidCallback? onPosTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextMain : AppColors.lightTextMain,
                  ),
                ),
              ),
              if (status == 'Visited')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.emeraldSuccess.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check, size: 12, color: AppColors.emeraldSuccess),
                      SizedBox(width: 4),
                      Text(
                        'Visited',
                        style: TextStyle(
                          color: AppColors.emeraldSuccess,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              else if (showPosButton)
                ElevatedButton.icon(
                  onPressed: onPosTap,
                  icon: const Icon(Icons.point_of_sale, size: 14),
                  label: const Text('POS Terminal', style: TextStyle(fontSize: 11)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Code: $code | $address',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            saleInfo,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isCreditWarning ? AppColors.roseDanger : AppColors.emeraldSuccess,
            ),
          ),
        ],
      ),
    );
  }

  void _showRequestStockBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateSheet) {
          final List<Map<String, dynamic>> requisitionLines = [
            {'item': 'CARD-100 - Hutch Rs. 100...', 'qty': '250'},
            {'item': 'SIM-4G - Hutch 4G SIM S...', 'qty': '50'},
          ];
          String selectedUrgency = 'High Stock Out Demand on Dampola Route';

          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Request Warehouse Multi-Item Stock',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.cyanAccent,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Build Multi-Item Requisition Order to Branch Hub',
                    style: TextStyle(fontSize: 12, color: AppColors.darkTextSub),
                  ),
                  const SizedBox(height: 20),
                  ...requisitionLines.map((line) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkInput : AppColors.lightInput,
                          borderRadius: BorderRadius.circular(14),
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
                                  Text(line['item']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
                                    controller: TextEditingController(text: line['qty']),
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setStateSheet(() {
                                  requisitionLines.remove(line);
                                });
                              },
                              icon: const Icon(Icons.delete_outline, color: AppColors.roseDanger),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () {
                      setStateSheet(() {
                        requisitionLines.add({'item': 'RELOAD-EASY - Easy Reload Balance', 'qty': '100'});
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.cyanAccent,
                      side: const BorderSide(color: AppColors.cyanAccent),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Center(child: Text('+ Add Requisition Item Line', style: TextStyle(fontWeight: FontWeight.bold))),
                  ),
                  const SizedBox(height: 16),
                  const Text('Requisition Urgency / Reason', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkTextSub)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkInput : AppColors.lightInput,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedUrgency,
                        isExpanded: true,
                        items: ['High Stock Out Demand on Dampola Route', 'Regular Weekly Stock Replenishment', 'Special Event Promotion Stock']
                            .map((u) => DropdownMenuItem(value: u, child: Text(u, style: const TextStyle(fontSize: 13))))
                            .toList(),
                        onChanged: (val) {
                          setStateSheet(() {
                            selectedUrgency = val!;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Multi-Item Requisition Request successfully sent to Branch Hub!'),
                            backgroundColor: AppColors.emeraldSuccess,
                          ),
                        );
                      },
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
