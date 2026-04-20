import 'consultant_model.dart';
import 'message_model.dart';

class SessionModel {
  final String id;
  final ConsultantModel consultant;
  final String status;
  final int durationMin;
  final DateTime startedAt;
  final List<MessageModel> messages;

  SessionModel({
    required this.id,
    required this.consultant,
    required this.status,
    required this.durationMin,
    required this.startedAt,
    required this.messages,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] ?? '',
      consultant: ConsultantModel.fromJson(json['consultant'] ?? {}),
      status: json['status'] ?? 'active',
      durationMin: json['duration_min'] ?? 30,
      startedAt: json['started_at'] != null 
          ? DateTime.parse(json['started_at']) 
          : DateTime.now(),
      messages: json['messages'] != null 
          ? (json['messages'] as List).map((e) => MessageModel.fromJson(e)).toList() 
          : [],
    );
  }

  SessionModel copyWith({
    String? id,
    ConsultantModel? consultant,
    String? status,
    int? durationMin,
    DateTime? startedAt,
    List<MessageModel>? messages,
  }) {
    return SessionModel(
      id: id ?? this.id,
      consultant: consultant ?? this.consultant,
      status: status ?? this.status,
      durationMin: durationMin ?? this.durationMin,
      startedAt: startedAt ?? this.startedAt,
      messages: messages ?? this.messages,
    );
  }
}
