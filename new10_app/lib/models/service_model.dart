class Service {
  final String id;
  final String name;
  final String description;
  final String category;
  final String? image1;
  final String? image2;
  final double rating;
  final int reviews;
  final int? vendorCount; // Number of vendors offering this service
  
  // New fields for vendor and listing info
  final String vendorId;
  final String vendorName; // Business name (e.g., "SLV Machineries")
  final String location; // District/Location
  final double? pricePerHour;
  final double? pricePerDay;
  final bool isOnline; // Vendor online status
  final String? emoji; // Emoji or icon identifier
  final String serviceType; // Type of service/equipment

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.image1,
    this.image2,
    this.rating = 0.0,
    this.reviews = 0,
    this.vendorCount,
    this.vendorId = '',
    this.vendorName = 'Vendor',
    this.location = 'Karnataka',
    this.pricePerHour,
    this.pricePerDay,
    this.isOnline = false,
    this.emoji,
    this.serviceType = 'Equipment',
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
      vendorCount: json['vendor_count'] ?? json['vendorCount'],
      vendorId: json['vendorId'] ?? json['vendor_id'] ?? '',
      vendorName: json['vendorName'] ?? json['vendor_name'] ?? 'Vendor',
      location: json['location'] ?? json['district'] ?? 'Karnataka',
      pricePerHour: json['pricePerHour'] != null ? (json['pricePerHour'] as num).toDouble() : null,
      pricePerDay: json['pricePerDay'] != null ? (json['pricePerDay'] as num).toDouble() : null,
      isOnline: json['isOnline'] ?? json['is_online'] ?? false,
      emoji: json['emoji'],
      serviceType: json['serviceType'] ?? json['service_type'] ?? 'Equipment',
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
      'vendor_count': vendorCount,
      'vendorId': vendorId,
      'vendorName': vendorName,
      'location': location,
      'pricePerHour': pricePerHour,
      'pricePerDay': pricePerDay,
      'isOnline': isOnline,
      'emoji': emoji,
      'serviceType': serviceType,
    };
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }
}
