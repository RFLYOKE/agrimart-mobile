class ConsultantModel {
  final String id;
  final String name;
  final String expertise;
  final num rating;
  final String bio;
  final String photoUrl;
  final List<String> availableSlots;
  final num price;

  ConsultantModel({
    required this.id,
    required this.name,
    required this.expertise,
    required this.rating,
    required this.bio,
    required this.photoUrl,
    required this.availableSlots,
    required this.price,
  });

  factory ConsultantModel.fromJson(Map<String, dynamic> json) {
    return ConsultantModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      expertise: json['expertise'] ?? '',
      rating: json['rating'] ?? 5.0,
      bio: json['bio'] ?? '',
      photoUrl: json['photo_url'] ?? '',
      price: json['price'] ?? 0,
      availableSlots: json['available_slots'] != null 
          ? List<String>.from(json['available_slots']) 
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'expertise': expertise,
      'rating': rating,
      'bio': bio,
      'photo_url': photoUrl,
      'price': price,
      'available_slots': availableSlots,
    };
  }
}
