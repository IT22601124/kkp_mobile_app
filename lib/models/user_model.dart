import 'package:kkp_rep_mobile_app/models/dsr_rep_profile.dart';

class UserModel {
  int id;
  String name;
  String email;
  String phone;
  String role;
  DsrRepProfile? repProfile;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.role = 'DSR_REP',
    this.repProfile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final dsrProfileJson = json['dsr_profile'] ?? json['dsrProfile'] ?? json['rep_profile'] ?? json['repProfile'];
    final nameVal = json['name']?.toString() ?? '';
    final phoneVal = json['phone']?.toString() ?? '';

    DsrRepProfile? profile;
    if (dsrProfileJson is Map) {
      profile = DsrRepProfile.fromJson(
        Map<String, dynamic>.from(dsrProfileJson),
        defaultName: nameVal,
        defaultPhone: phoneVal,
      );
    }

    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: nameVal,
      email: json['email']?.toString() ?? '',
      phone: phoneVal,
      role: json['role']?.toString() ?? json['user_type']?.toString() ?? 'DSR_REP',
      repProfile: profile,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'dsr_profile': repProfile?.toJson(),
    };
  }
}
