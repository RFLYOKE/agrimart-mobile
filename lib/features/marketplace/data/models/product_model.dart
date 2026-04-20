class ProductModel {
  final String id;
  final String name;
  final String description;
  final num priceB2c;
  final num priceB2b;
  final int stock;
  final String category;
  final List<String> images;
  final String coopName;
  final num coopFreshRate;
  final List<String> coopCertifications;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.priceB2c,
    required this.priceB2b,
    required this.stock,
    required this.category,
    required this.images,
    required this.coopName,
    required this.coopFreshRate,
    required this.coopCertifications,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      priceB2c: json['price_b2c'] ?? 0,
      priceB2b: json['price_b2b'] ?? 0,
      stock: json['stock'] ?? 0,
      category: json['category'] ?? '',
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      coopName: json['coop_name'] ?? '',
      coopFreshRate: json['coop_fresh_rate'] ?? 0,
      coopCertifications: json['coop_certifications'] != null 
          ? List<String>.from(json['coop_certifications']) 
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price_b2c': priceB2c,
      'price_b2b': priceB2b,
      'stock': stock,
      'category': category,
      'images': images,
      'coop_name': coopName,
      'coop_fresh_rate': coopFreshRate,
      'coop_certifications': coopCertifications,
    };
  }
}
