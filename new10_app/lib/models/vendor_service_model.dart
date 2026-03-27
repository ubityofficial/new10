class VendorService {
  final String id;
  final String vendorId;
  final String? vendorName;
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
  final int? numReviews;
  final String createdAt;

  VendorService({
    required this.id,
    required this.vendorId,
    this.vendorName,
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
    this.numReviews,
    required this.createdAt,
  });

  // Convert from JSON
  factory VendorService.fromJson(Map<String, dynamic> json) {
    return VendorService(
      id: json['id'] ?? '',
      vendorId: json['vendor_id'] ?? json['vendorId'] ?? '',
      vendorName: json['vendor_name'] ?? json['vendorName'],
      serviceId: json['service_id'] ?? json['serviceId'] ?? '',
      serviceName: json['service_name'] ?? json['serviceName'] ?? '',
      emoji: json['emoji'] ?? json['service_emoji'],
      image: json['image'],
      pricing: (json['pricing'] ?? 0).toDouble(),
      pricingUnit: json['pricing_unit'] ?? json['pricingUnit'] ?? 'per day',
      location: json['location'] ?? '',
      availability: json['availability'] ?? 'available',
      startTime: json['start_time'] ?? json['startTime'],
      endTime: json['end_time'] ?? json['endTime'],
      isOnline: json['is_online'] ?? json['isOnline'] ?? true,
      rating: json['rating'] != null ? (json['rating']).toDouble() : json['service_rating']?.toDouble(),
      numReviews: json['num_reviews'] ?? json['numReviews'],
      createdAt: json['created_at'] ?? json['createdAt'] ?? DateTime.now().toString(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor_id': vendorId,
      'vendor_name': vendorName,
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
      'rating': rating ?? 0.0,
      'num_reviews': numReviews ?? 0,
      'created_at': createdAt,
    };
  }

  // Copy with modifications
  VendorService copyWith({
    String? id,
    String? vendorId,
    String? vendorName,
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
    int? numReviews,
    String? createdAt,
  }) {
    return VendorService(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
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
      numReviews: numReviews ?? this.numReviews,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Format pricing for display (e.g., "₹500/hour")
  String get formattedPrice {
    final unitLabel = pricingUnit.contains('hour')
        ? '/hour'
        : pricingUnit.contains('day')
            ? '/day'
            : '/${pricingUnit.toLowerCase()}';
    return '₹${pricing.toStringAsFixed(0)}$unitLabel';
  }

  /// Get availability status text
  String get availabilityText {
    switch (availability.toLowerCase()) {
      case 'available':
        return '✓ Available';
      case 'limited':
        return '⚠ Limited';
      case 'unavailable':
        return '✗ Unavailable';
      default:
        return availability;
    }
  }
}

