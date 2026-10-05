class RouteModel {
  final int id;
  final int branchId;
  final String routeName;
  final String routeCode;
  final String? description;
  final int totalShopsCount;

  RouteModel({
    required this.id,
    required this.branchId,
    required this.routeName,
    required this.routeCode,
    this.description,
    this.totalShopsCount = 0,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString()) ?? 0;
    }

    return RouteModel(
      id: parseInt(json['id']),
      branchId: parseInt(json['branch_id'] ?? json['branchId']),
      routeName: json['route_name']?.toString() ?? json['routeName']?.toString() ?? 'Route #${json['id']}',
      routeCode: json['route_code']?.toString() ?? json['routeCode']?.toString() ?? 'RTE-${json['id']}',
      description: json['description']?.toString(),
      totalShopsCount: parseInt(json['total_shops_count'] ?? json['totalShopsCount']),
    );
  }

  String get displayName => '$routeName ($routeCode)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouteModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
