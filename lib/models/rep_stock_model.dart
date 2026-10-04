class RepStockModel {
  final int id;
  final int repId;
  final int branchId;
  final int itemId;
  final int quantity;
  final int reservedQuantity;
  final double unitCost;
  final double unitPrice;
  final double totalValue;
  final String? batchNumber;
  final String status;
  
  // Flattened item info
  final String itemCode;
  final String itemName;
  final String category;
  final String unit;

  RepStockModel({
    required this.id,
    required this.repId,
    required this.branchId,
    required this.itemId,
    required this.quantity,
    required this.reservedQuantity,
    required this.unitCost,
    required this.unitPrice,
    required this.totalValue,
    this.batchNumber,
    required this.status,
    required this.itemCode,
    required this.itemName,
    required this.category,
    required this.unit,
  });

  factory RepStockModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString()) ?? 0;
    }

    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    final itemMap = json['item'] is Map ? json['item'] as Map<String, dynamic> : <String, dynamic>{};

    String categoryName = 'General';
    if (itemMap['category'] != null) {
      if (itemMap['category'] is Map && (itemMap['category'] as Map).containsKey('name')) {
        categoryName = (itemMap['category'] as Map)['name']?.toString() ?? 'General';
      } else if (itemMap['category'] is String) {
        categoryName = itemMap['category'] as String;
      }
    }

    final qty = parseInt(json['quantity']);
    final price = parseDouble(json['unit_price'] ?? itemMap['selling_price']);

    return RepStockModel(
      id: parseInt(json['id']),
      repId: parseInt(json['rep_id']),
      branchId: parseInt(json['branch_id']),
      itemId: parseInt(json['item_id'] ?? itemMap['id']),
      quantity: qty,
      reservedQuantity: parseInt(json['reserved_quantity']),
      unitCost: parseDouble(json['unit_cost'] ?? itemMap['purchase_price']),
      unitPrice: price,
      totalValue: parseDouble(json['total_value'] ?? (qty * price)),
      batchNumber: json['batch_number']?.toString(),
      status: json['status']?.toString() ?? 'ACTIVE',
      itemCode: itemMap['code']?.toString() ?? itemMap['item_code']?.toString() ?? 'ITEM-${json['item_id']}',
      itemName: itemMap['name']?.toString() ?? itemMap['item_name']?.toString() ?? 'Item #${json['item_id']}',
      category: categoryName,
      unit: itemMap['unit']?.toString() ?? 'unit',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rep_id': repId,
      'branch_id': branchId,
      'item_id': itemId,
      'quantity': quantity,
      'reserved_quantity': reservedQuantity,
      'unit_cost': unitCost,
      'unit_price': unitPrice,
      'total_value': totalValue,
      'batch_number': batchNumber,
      'status': status,
    };
  }
}
