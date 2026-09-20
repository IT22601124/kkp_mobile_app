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
    return ShopModel(
      id: json['id'] ?? 0,
      routeId: json['route_id'] ?? json['routeId'] ?? 1,
      shopCode: json['shop_code'] ?? json['shopCode'] ?? '',
      shopName: json['shop_name'] ?? json['shopName'] ?? '',
      ownerName: json['owner_name'] ?? json['ownerName'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      creditLimit: (json['credit_limit'] ?? json['creditLimit'] ?? 0.0).toDouble(),
      currentCreditBalance: (json['current_credit_balance'] ?? json['currentCreditBalance'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'GOOD',
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
