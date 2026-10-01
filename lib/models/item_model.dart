class ItemModel {
  final int id;
  final String itemCode;
  final String itemName;
  final String category;
  final double unitPrice;
  final int stock;
  final String unit;

  ItemModel({
    required this.id,
    required this.itemCode,
    required this.itemName,
    required this.category,
    required this.unitPrice,
    required this.stock,
    this.unit = 'unit',
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
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

    // Extract category name safely
    String categoryName = 'General';
    if (json['category'] != null) {
      if (json['category'] is Map && (json['category'] as Map).containsKey('name')) {
        categoryName = (json['category'] as Map)['name']?.toString() ?? 'General';
      } else if (json['category'] is String) {
        categoryName = json['category'] as String;
      }
    }

    // Extract unit price safely
    final priceVal = json['selling_price'] ??
        json['unit_price'] ??
        json['unitPrice'] ??
        json['price'] ??
        json['purchase_price'] ??
        0.0;

    // Extract stock quantity safely
    final stockVal = json['stock_quantity'] ??
        json['stock'] ??
        json['van_stock'] ??
        json['quantity'] ??
        0;

    return ItemModel(
      id: parseInt(json['id']),
      itemCode: json['code']?.toString() ?? json['item_code']?.toString() ?? json['itemCode']?.toString() ?? '',
      itemName: json['name']?.toString() ?? json['item_name']?.toString() ?? json['itemName']?.toString() ?? json['title']?.toString() ?? '',
      category: categoryName,
      unitPrice: parseDouble(priceVal),
      stock: parseInt(stockVal),
      unit: json['unit']?.toString() ?? 'unit',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_code': itemCode,
      'item_name': itemName,
      'category': category,
      'unit_price': unitPrice,
      'stock': stock,
      'unit': unit,
    };
  }
}
