class DsrRepProfile {
  final int id;
  final int userId;
  final String repCode;
  final int? branchId;
  final int? assignedRouteId;
  final double basicSalary;
  final double bikeAllowance;
  final double fuelAllowance;
  final String dsrStatus;
  final String name;
  final String phone;
  final String branchName;
  final String activeRoute;

  DsrRepProfile({
    this.id = 0,
    this.userId = 0,
    required this.repCode,
    this.branchId,
    this.assignedRouteId,
    this.basicSalary = 0.0,
    this.bikeAllowance = 0.0,
    this.fuelAllowance = 0.0,
    this.dsrStatus = 'ACTIVE',
    required this.name,
    required this.phone,
    required this.branchName,
    required this.activeRoute,
  });

  factory DsrRepProfile.fromJson(Map<String, dynamic> json, {String? defaultName, String? defaultPhone}) {
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

    // Branch object mapping
    String branchNameStr = 'Main Warehouse';
    if (json['branch'] != null && json['branch'] is Map) {
      final bMap = json['branch'] as Map;
      branchNameStr = bMap['name']?.toString() ?? bMap['branch_name']?.toString() ?? 'Main Warehouse';
    } else if (json['branch_name'] != null) {
      branchNameStr = json['branch_name'].toString();
    }

    // Route object mapping
    String routeNameStr = 'General Route';
    if (json['route'] != null && json['route'] is Map) {
      final rMap = json['route'] as Map;
      routeNameStr = rMap['route_name']?.toString() ?? rMap['name']?.toString() ?? 'General Route';
    } else if (json['active_route'] != null) {
      routeNameStr = json['active_route'].toString();
    }

    return DsrRepProfile(
      id: parseInt(json['id']),
      userId: parseInt(json['user_id'] ?? json['userId']),
      repCode: json['rep_code']?.toString() ?? json['repCode']?.toString() ?? 'REP-001',
      branchId: json['branch_id'] != null ? parseInt(json['branch_id']) : null,
      assignedRouteId: json['assigned_route_id'] != null ? parseInt(json['assigned_route_id']) : null,
      basicSalary: parseDouble(json['basic_salary'] ?? json['basicSalary']),
      bikeAllowance: parseDouble(json['bike_allowance'] ?? json['bikeAllowance']),
      fuelAllowance: parseDouble(json['fuel_allowance'] ?? json['fuelAllowance']),
      dsrStatus: json['dsr_status']?.toString() ?? json['status']?.toString() ?? 'ACTIVE',
      name: json['name']?.toString() ?? defaultName ?? 'DSR Rep',
      phone: json['phone']?.toString() ?? defaultPhone ?? '0787450360',
      branchName: branchNameStr,
      activeRoute: routeNameStr,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'rep_code': repCode,
      'branch_id': branchId,
      'assigned_route_id': assignedRouteId,
      'basic_salary': basicSalary,
      'bike_allowance': bikeAllowance,
      'fuel_allowance': fuelAllowance,
      'dsr_status': dsrStatus,
      'name': name,
      'phone': phone,
      'branch_name': branchName,
      'active_route': activeRoute,
    };
  }
}
