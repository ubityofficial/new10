class VendorService {
  final String id;
  final String vendorId;
  final String serviceId;
  final String serviceName;
  final String? emoji;
  final String? image;
  final double pricing;
  final String pricingUnit; // 'per day', 'per hour', 'per unit'
  final String location;
  final String availability; // 'available', 'unavailable', 'limited'
  final String? startTime;
  final String? endTime;
  final bool isOnline;
  final double? rating;
  final String createdAt;

  VendorService({
    required this.id,
    required this.vendorId,
    required this.serviceId,
    required this.serviceName,
    this.emoji,
    this.image,
    required this.pricing,
    this.pricingUnit = 'per day',
    required this.location,
    this.availability = 'available',
    this.startTime,
    this.endTime,
    this.isOnline = true,
    this.rating,
    required this.createdAt,
  });

  // Convert from JSON
  factory VendorService.fromJson(Map<String, dynamic> json) {
    return VendorService(
      id: json['id'] ?? '',
      vendorId: json['vendor_id'] ?? json['vendorId'] ?? '',
      serviceId: json['service_id'] ?? json['serviceId'] ?? '',
      serviceName: json['service_name'] ?? json['serviceName'] ?? '',
      emoji: json['emoji'],
      image: json['image'],
      pricing: (json['pricing'] ?? 0).toDouble(),
      pricingUnit: json['pricing_unit'] ?? json['pricingUnit'] ?? 'per day',
      location: json['location'] ?? '',
      availability: json['availability'] ?? 'available',
      startTime: json['start_time'] ?? json['startTime'],
      endTime: json['end_time'] ?? json['endTime'],
      isOnline: json['is_online'] ?? json['isOnline'] ?? true,
      rating: json['rating'] != null ? (json['rating']).toDouble() : null,
      createdAt: json['created_at'] ?? json['createdAt'] ?? DateTime.now().toString(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor_id': vendorId,
      'service_id': serviceId,
      'service_name': serviceName,
      'emoji': emoji,
      'image': image,
      'pricing': pricing,
      'pricing_unit': pricingUnit,
      'location': location,
      'availability': availability,
      'start_time': startTime,
      'end_time': endTime,
      'is_online': isOnline,
      'rating': rating,
      'created_at': createdAt,
    };
  }

  // Copy with modifications
  VendorService copyWith({
    String? id,
    String? vendorId,
    String? serviceId,
    String? serviceName,
    String? emoji,
    String? image,
    double? pricing,
    String? pricingUnit,
    String? location,
    String? availability,
    String? startTime,
    String? endTime,
    bool? isOnline,
    double? rating,
    String? createdAt,
  }) {
    return VendorService(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      emoji: emoji ?? this.emoji,
      image: image ?? this.image,
      pricing: pricing ?? this.pricing,
      pricingUnit: pricingUnit ?? this.pricingUnit,
      location: location ?? this.location,
      availability: availability ?? this.availability,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isOnline: isOnline ?? this.isOnline,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
