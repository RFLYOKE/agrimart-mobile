/// Model untuk koperasi pending verifikasi
class PendingCoopModel {
  final String id;
  final String name;
  final String sector;
  final String location;
  final String? description;
  final String certStatus;
  final CoopUserInfo user;
  final List<CoopDocument> documents;

  PendingCoopModel({
    required this.id,
    required this.name,
    required this.sector,
    required this.location,
    this.description,
    required this.certStatus,
    required this.user,
    required this.documents,
  });

  factory PendingCoopModel.fromJson(Map<String, dynamic> json) {
    return PendingCoopModel(
      id: json['id'],
      name: json['name'],
      sector: json['sector'],
      location: json['location'],
      description: json['description'],
      certStatus: json['certStatus'],
      user: CoopUserInfo.fromJson(json['user']),
      documents: (json['documents'] as List<dynamic>?)
              ?.map((d) => CoopDocument.fromJson(d))
              .toList() ??
          [],
    );
  }
}

class CoopUserInfo {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final DateTime createdAt;

  CoopUserInfo({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    required this.createdAt,
  });

  factory CoopUserInfo.fromJson(Map<String, dynamic> json) {
    return CoopUserInfo(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class CoopDocument {
  final String id;
  final String type;
  final String docUrl;
  final String status;

  CoopDocument({
    required this.id,
    required this.type,
    required this.docUrl,
    required this.status,
  });

  factory CoopDocument.fromJson(Map<String, dynamic> json) {
    return CoopDocument(
      id: json['id'],
      type: json['type'],
      docUrl: json['doc_url'],
      status: json['status'],
    );
  }
}
