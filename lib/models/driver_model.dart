class DriverModel {
  final String driverId;
  final String name;
  final String phone;
  final String email;
  final String? profileImageUrl;
  final double? rating;
  final int? totalRides;
  final String vehicleModel;
  final String licensePlate;
  final double? currentLatitude;
  final double? currentLongitude;
  final bool isOnline;
  final DateTime createdAt;

  DriverModel({
    required this.driverId,
    required this.name,
    required this.phone,
    required this.email,
    this.profileImageUrl,
    this.rating,
    this.totalRides,
    required this.vehicleModel,
    required this.licensePlate,
    this.currentLatitude,
    this.currentLongitude,
    required this.isOnline,
    required this.createdAt,
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'driverId': driverId,
      'name': name,
      'phone': phone,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'rating': rating,
      'totalRides': totalRides,
      'vehicleModel': vehicleModel,
      'licensePlate': licensePlate,
      'currentLatitude': currentLatitude,
      'currentLongitude': currentLongitude,
      'isOnline': isOnline,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from Firestore document
  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      driverId: json['driverId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      profileImageUrl: json['profileImageUrl'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      totalRides: json['totalRides'] as int?,
      vehicleModel: json['vehicleModel'] as String? ?? '',
      licensePlate: json['licensePlate'] as String? ?? '',
      currentLatitude: (json['currentLatitude'] as num?)?.toDouble(),
      currentLongitude: (json['currentLongitude'] as num?)?.toDouble(),
      isOnline: json['isOnline'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  // Copy with method for updates
  DriverModel copyWith({
    String? driverId,
    String? name,
    String? phone,
    String? email,
    String? profileImageUrl,
    double? rating,
    int? totalRides,
    String? vehicleModel,
    String? licensePlate,
    double? currentLatitude,
    double? currentLongitude,
    bool? isOnline,
    DateTime? createdAt,
  }) {
    return DriverModel(
      driverId: driverId ?? this.driverId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      rating: rating ?? this.rating,
      totalRides: totalRides ?? this.totalRides,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      licensePlate: licensePlate ?? this.licensePlate,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      isOnline: isOnline ?? this.isOnline,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'DriverModel(driverId: $driverId, name: $name)';
}
