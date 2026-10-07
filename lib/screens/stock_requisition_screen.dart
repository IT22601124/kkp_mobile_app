import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';
import '../provider/item_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/request_stock_screen.dart';

class StockRequisitionScreen extends StatefulWidget {
  const StockRequisitionScreen({super.key});

  @override
  State<StockRequisitionScreen> createState() => _StockRequisitionScreenState();
}

class _StockRequisitionScreenState extends State<StockRequisitionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStockData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStockData() async {
    final user = context.read<AuthProvider>().user;
    final repId = user?.id ?? 7;
    final itemProvider = context.read<ItemProvider>();
    await Future.wait([
      itemProvider.getRepStocks(repId),
      itemProvider.getStockRequests(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.lightCard,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Stock & Requisitions Hub',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.darkYellow,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Manage Handheld Bag & Hub Orders',
                                style: TextStyle(fontSize: 8, color: AppColors.darkTextSub),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RequestStockScreen(),
                                ),
                              ).then((_) => _loadStockData());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.amberWarning,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: const Text('+ Request Stock', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Tab Bar
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(0),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: AppColors.darkYellow,
                        unselectedLabelColor: isDark ? AppColors.darkTextSub : AppColors.lightTextSub,
                        indicatorColor: AppColors.darkYellow,
                        tabs: const [
                          Tab(text: 'Handheld Stock Bag'),
                          Tab(text: 'Requisition History'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildHandheldStockTab(isDark),
              _buildRequisitionHistoryTab(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandheldStockTab(bool isDark) {
    return Consumer<ItemProvider>(
      builder: (context, itemProvider, _) {
        if (itemProvider.isLoading && itemProvider.listRepStocks.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.cyanAccent));
        }

        final stocks = itemProvider.listRepStocks;

        if (stocks.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 40, color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub),
                  const SizedBox(height: 12),
                  const Text('No stock records found for this rep.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 6),
                  const Text('Pull down to refresh or request warehouse stock.', style: TextStyle(fontSize: 12, color: AppColors.darkTextSub)),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadStockData,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: stocks.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            itemBuilder: (context, index) {
              final stock = stocks[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stock.itemName,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? AppColors.darkTextMain : AppColors.lightTextMain,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Code: ${stock.itemCode} • Category: ${stock.category}',
                            style: const TextStyle(fontSize: 11, color: AppColors.darkTextSub),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${stock.quantity} Units',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkYellow,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'LKR ${stock.unitPrice.toStringAsFixed(2)} / u',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkTextMain,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildRequisitionHistoryTab(bool isDark) {
    return Consumer<ItemProvider>(
      builder: (context, itemProvider, _) {
        final requests = itemProvider.listStockRequests;

        if (requests.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 40, color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub),
                  const SizedBox(height: 12),
                  const Text('No stock requisition requests submitted.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 6),
                  const Text('Tap "+ Request Stock" to submit an order.', style: TextStyle(fontSize: 12, color: AppColors.darkTextSub)),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadStockData,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              final reqCode = req['request_code'] ?? 'REQ-${req['id']}';
              final status = req['status'] ?? 'PENDING';
              final notes = req['notes'] ?? 'Stock Requisition';
              final items = req['items'] is List ? req['items'] as List : [];

              Color statusColor = AppColors.primaryOrange;
              if (status == 'APPROVED' || status == 'ISSUED') {
                statusColor = AppColors.emeraldSuccess;
              } else if (status == 'REJECTED') {
                statusColor = AppColors.roseDanger;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(0),

                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          reqCode,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextMain : AppColors.lightTextMain,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: statusColor.withOpacity(0.4)),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notes,
                      style: const TextStyle(fontSize: 12, color: AppColors.darkTextSub),
                    ),
                    const Divider(height: 16),
                    ...items.map<Widget>((itemLine) {
                      final itemObj = itemLine['item'] ?? {};
                      final itemName = itemObj['name'] ?? itemObj['item_name'] ?? 'Item #${itemLine['item_id']}';
                      final qty = itemLine['requested_quantity'] ?? itemLine['quantity'] ?? 0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('• $itemName', style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextMain : AppColors.lightTextMain)),
                            Text('$qty Units', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkYellow)),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
