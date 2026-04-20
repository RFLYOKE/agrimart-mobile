/// Model untuk data user di admin panel (list & detail)
class AdminUserModel {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String role;
  final String status;
  final DateTime joinDate;
  final int transactionCount;

  AdminUserModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    required this.role,
    required this.status,
    required this.joinDate,
    required this.transactionCount,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
      status: json['status'],
      joinDate: DateTime.parse(json['joinDate']),
      transactionCount: json['transactionCount'] ?? 0,
    );
  }

  /// Label badge untuk role (display-friendly)
  String get roleLabel {
    switch (role) {
      case 'koperasi':
        return 'Koperasi';
      case 'konsumen':
        return 'Konsumen';
      case 'hotel_restoran':
        return 'Hotel/Restoran';
      case 'eksportir':
        return 'Eksportir';
      case 'admin':
        return 'Admin';
      default:
        return role;
    }
  }

  /// Inisial untuk avatar
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }
}
