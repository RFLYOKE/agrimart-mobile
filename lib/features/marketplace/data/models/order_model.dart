class OrderModel {
  final String id;
  final num total;
  final String status;
  final List<dynamic> items;
  final Map<String, dynamic> address;
  final String paymentMethod;
  final String? snapToken;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.total,
    required this.status,
    required this.items,
    required this.address,
    required this.paymentMethod,
    this.snapToken,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      total: json['total'] ?? 0,
      status: json['status'] ?? 'pending',
      items: json['items'] ?? [],
      address: json['address'] ?? {},
      paymentMethod: json['payment_method'] ?? '',
      snapToken: json['snap_token'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'total': total,
      'status': status,
      'items': items,
      'address': address,
      'payment_method': paymentMethod,
      'snap_token': snapToken,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
