enum UserRole {
  koperasi,
  konsumen,
  hotelRestoran,
  eksportir,
  admin
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final UserRole role;
  final String status;
  final bool phoneVerified;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    required this.status,
    this.phoneVerified = false,
  });

  bool get isKoperasi => role == UserRole.koperasi;
  bool get isKonsumen => role == UserRole.konsumen;
  bool get isHotel => role == UserRole.hotelRestoran;
  bool get isEksportir => role == UserRole.eksportir;
  bool get isAdmin => role == UserRole.admin;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      role: _parseRole(json['role']),
      status: json['status'] ?? 'active',
      phoneVerified: json['phone_verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': _roleToString(role),
      'status': status,
      'phone_verified': phoneVerified,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    String? status,
    bool? phoneVerified,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      status: status ?? this.status,
      phoneVerified: phoneVerified ?? this.phoneVerified,
    );
  }

  static UserRole _parseRole(String? roleStr) {
    switch (roleStr) {
      case 'koperasi':
        return UserRole.koperasi;
      case 'hotel_restoran':
        return UserRole.hotelRestoran;
      case 'eksportir':
        return UserRole.eksportir;
      case 'admin':
        return UserRole.admin;
      case 'konsumen':
      default:
        return UserRole.konsumen;
    }
  }

  static String _roleToString(UserRole role) {
    switch (role) {
      case UserRole.koperasi:
        return 'koperasi';
      case UserRole.hotelRestoran:
        return 'hotel_restoran';
      case UserRole.eksportir:
        return 'eksportir';
      case UserRole.admin:
        return 'admin';
      case UserRole.konsumen:
        return 'konsumen';
    }
  }
}
