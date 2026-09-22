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
    return ItemModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      itemCode: json['item_code'] ?? json['itemCode'] ?? json['code'] ?? '',
      itemName: json['item_name'] ?? json['itemName'] ?? json['name'] ?? json['title'] ?? '',
      category: json['category'] ?? 'General',
      unitPrice: (json['unit_price'] ?? json['unitPrice'] ?? json['price'] ?? 0.0) is num
          ? (json['unit_price'] ?? json['unitPrice'] ?? json['price'] ?? 0.0).toDouble()
          : double.tryParse((json['unit_price'] ?? json['unitPrice'] ?? json['price'] ?? '0').toString()) ?? 0.0,
      stock: json['stock'] ?? json['van_stock'] ?? json['quantity'] ?? 0,
      unit: json['unit'] ?? 'unit',
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
