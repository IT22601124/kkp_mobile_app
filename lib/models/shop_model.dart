class ShopModel {
  final int id;
  final int routeId;
  final String shopCode;
  final String shopName;
  final String ownerName;
  final String phone;
  final String address;
  final double latitude;
  final double longitude;
  final double creditLimit;
  final double currentCreditBalance;
  final String status;

  ShopModel({
    required this.id,
    required this.routeId,
    required this.shopCode,
    required this.shopName,
    required this.ownerName,
    required this.phone,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.creditLimit,
    required this.currentCreditBalance,
    required this.status,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString()) ?? 0;
    }

    return ShopModel(
      id: parseInt(json['id']),
      routeId: parseInt(json['route_id'] ?? json['routeId'] ?? 1),
      shopCode: json['shop_code']?.toString() ?? json['shopCode']?.toString() ?? '',
      shopName: json['shop_name']?.toString() ?? json['shopName']?.toString() ?? '',
      ownerName: json['owner_name']?.toString() ?? json['ownerName']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
      creditLimit: parseDouble(json['credit_limit'] ?? json['creditLimit']),
      currentCreditBalance: parseDouble(json['current_credit_balance'] ?? json['currentCreditBalance']),
      status: json['status']?.toString() ?? 'GOOD',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shop_name': shopName,
      'owner_name': ownerName,
      'phone': phone,
      'address': address,
      'route_id': routeId,
      'latitude': latitude,
      'longitude': longitude,
      'credit_limit': creditLimit,
    };
  }
}
