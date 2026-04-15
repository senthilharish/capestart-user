class RideModel {
  final String rideId;
  final String driverId;
  final String startAddress;
  final String destinationAddress;
  final double totalPrice;
  final String status; // 'pending', 'accepted', 'in_progress', 'completed', 'cancelled'
  final double? latitude;
  final double? longitude;
  final String? distance;
  final String? rideDuration;
  final double? additionalPrice;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int numberOfPassengers;
  final int numberOfPassengersAllocated;

  RideModel({
    required this.rideId,
    required this.driverId,
    required this.startAddress,
    required this.destinationAddress,
    required this.totalPrice,
    required this.status,
    required this.numberOfPassengers,
    required this.numberOfPassengersAllocated,
    this.latitude,
    this.longitude,
    this.distance,
    this.rideDuration,
    this.additionalPrice,
    required this.createdAt,
    this.completedAt,
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'rideId': rideId,
      'driverId': driverId,
      'startAddress': startAddress,
      'destinationAddress': destinationAddress,
      'totalPrice': totalPrice,
      'status': status,
      'numberOfPassengers': numberOfPassengers,
      'numberOfPassengersAllocated': numberOfPassengersAllocated,
      'latitude': latitude,
      'longitude': longitude,
      'distance': distance,
      'rideDuration': rideDuration,
      'additionalPrice': additionalPrice,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  // Create from Firestore document
  factory RideModel.fromJson(Map<String, dynamic> json) {
    return RideModel(
      rideId: json['rideId'] as String? ?? '',
      driverId: json['driverId'] as String? ?? '',
      startAddress: json['startAddress'] as String? ?? '',
      destinationAddress: json['destinationAddress'] as String? ?? '',
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'pending',
      numberOfPassengers: json['numberOfPassengers'] as int? ?? 0,
      numberOfPassengersAllocated: json['numberOfPassengersAllocated'] as int? ?? 4,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      distance: json['distance'] as String?,
      rideDuration: json['rideDuration'] as String?,
      additionalPrice: (json['additionalPrice'] as num?)?.toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  // Copy with method for updates
  RideModel copyWith({
    String? rideId,
    String? driverId,
    String? startAddress,
    String? destinationAddress,
    double? totalPrice,
    String? status,
    int? numberOfPassengers,
    int? numberOfPassengersAllocated,
    double? latitude,
    double? longitude,
    String? distance,
    String? rideDuration,
    double? additionalPrice,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return RideModel(
      rideId: rideId ?? this.rideId,
      driverId: driverId ?? this.driverId,
      startAddress: startAddress ?? this.startAddress,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      numberOfPassengers: numberOfPassengers ?? this.numberOfPassengers,
      numberOfPassengersAllocated: numberOfPassengersAllocated ?? this.numberOfPassengersAllocated,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distance: distance ?? this.distance,
      rideDuration: rideDuration ?? this.rideDuration,
      additionalPrice: additionalPrice ?? this.additionalPrice,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  // Helper methods
  bool get isActive => ['started','pending', 'accepted', 'in_progress'].contains(status);
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  @override
  String toString() => 'RideModel(rideId: $rideId, status: $status)';
}
