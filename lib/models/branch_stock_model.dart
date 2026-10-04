class BranchStockModel {
  final int id;
  final int branchId;
  final int itemId;
  final int quantity;
  final double unitPrice;
  final String batchNumber;
  final String itemName;
  final String itemCode;
  final String branchName;

  BranchStockModel({
    required this.id,
    required this.branchId,
    required this.itemId,
    required this.quantity,
    required this.unitPrice,
    required this.batchNumber,
    required this.itemName,
    required this.itemCode,
    required this.branchName,
  });

  factory BranchStockModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString()) ?? 0;
    }

    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return (val as num).toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    final itemMap = json['item'] is Map ? json['item'] as Map<String, dynamic> : <String, dynamic>{};
    final branchMap = json['branch'] is Map ? json['branch'] as Map<String, dynamic> : <String, dynamic>{};

    return BranchStockModel(
      id: parseInt(json['id']),
      branchId: parseInt(json['branch_id'] ?? branchMap['id']),
      itemId: parseInt(json['item_id'] ?? itemMap['id']),
      quantity: parseInt(json['quantity']),
      unitPrice: parseDouble(json['unit_price'] ?? itemMap['selling_price']),
      batchNumber: json['batch_number']?.toString() ?? '',
      itemName: itemMap['name']?.toString() ?? itemMap['item_name']?.toString() ?? 'Item #${json['item_id']}',
      itemCode: itemMap['code']?.toString() ?? itemMap['item_code']?.toString() ?? 'CODE-${json['item_id']}',
      branchName: branchMap['branch_name']?.toString() ?? 'Branch Warehouse',
    );
  }
}
