class Service {
  final String id;
  final String name;
  final String description;
  final String category;
  final String? image1;
  final String? image2;
  final double rating;
  final int reviews;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.image1,
    this.image2,
    this.rating = 0.0,
    this.reviews = 0,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Service',
      description: json['description'] ?? '',
      category: json['category'] ?? 'Equipment',
      image1: json['image1'],
      image2: json['image2'],
      rating: (json['rating'] ?? 0).toDouble(),
      reviews: json['reviews'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'image1': image1,
      'image2': image2,
      'rating': rating,
      'reviews': reviews,
    };
  }
}
