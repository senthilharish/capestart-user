  class BookingModel {
    final String bookingId;
    final String userId;
    final String rideId;
    final String driverId;
    final int seatsBooked;
    final double pricePerSeat;
    final double totalPrice;
    final bool isApproved;
    final String status; // pending, approved, rejected, cancelled
    final DateTime bookedAt;
    final DateTime? approvedAt;
    final String? pickupLocation;
    final String? dropoffLocation;

    BookingModel({
      required this.bookingId,
      required this.userId,
      required this.rideId,
      required this.driverId,
      required this.seatsBooked,
      required this.pricePerSeat,
      required this.totalPrice,
      required this.isApproved,
      required this.status,
      required this.bookedAt,
      this.approvedAt,
      this.pickupLocation,
      this.dropoffLocation,
    });

    // Convert to JSON for Firestore
    Map<String, dynamic> toJson() {
      return {
        'bookingId': bookingId,
        'userId': userId,
        'rideId': rideId,
        'driverId': driverId,
        'seatsBooked': seatsBooked,
        'pricePerSeat': pricePerSeat,
        'totalPrice': totalPrice,
        'isApproved': isApproved,
        'status': status,
        'bookedAt': bookedAt.toIso8601String(),
        'approvedAt': approvedAt?.toIso8601String(),
        'pickupLocation': pickupLocation,
        'dropoffLocation': dropoffLocation,
      };
    }

    // Create from JSON/Firestore
    factory BookingModel.fromJson(Map<String, dynamic> json) {
      return BookingModel(
        bookingId: json['bookingId'] ?? '',
        userId: json['userId'] ?? '',
        rideId: json['rideId'] ?? '',
        driverId: json['driverId'] ?? '',
        seatsBooked: json['seatsBooked'] ?? 1,
        pricePerSeat: (json['pricePerSeat'] ?? 0).toDouble(),
        totalPrice: (json['totalPrice'] ?? 0).toDouble(),
        isApproved: json['isApproved'] ?? false,
        status: json['status'] ?? 'pending',
        bookedAt: json['bookedAt'] != null
            ? DateTime.parse(json['bookedAt'])
            : DateTime.now(),
        approvedAt: json['approvedAt'] != null
            ? DateTime.parse(json['approvedAt'])
            : null,
        pickupLocation: json['pickupLocation'],
        dropoffLocation: json['dropoffLocation'],
      );
    }

    // Copy with method for creating modified copies
    BookingModel copyWith({
      String? bookingId,
      String? userId,
      String? rideId,
      String? driverId,
      int? seatsBooked,
      double? pricePerSeat,
      double? totalPrice,
      bool? isApproved,
      String? status,
      DateTime? bookedAt,
      DateTime? approvedAt,
      String? pickupLocation,
      String? dropoffLocation,
    }) {
      return BookingModel(
        bookingId: bookingId ?? this.bookingId,
        userId: userId ?? this.userId,
        rideId: rideId ?? this.rideId,
        driverId: driverId ?? this.driverId,
        seatsBooked: seatsBooked ?? this.seatsBooked,
        pricePerSeat: pricePerSeat ?? this.pricePerSeat,
        totalPrice: totalPrice ?? this.totalPrice,
        isApproved: isApproved ?? this.isApproved,
        status: status ?? this.status,
        bookedAt: bookedAt ?? this.bookedAt,
        approvedAt: approvedAt ?? this.approvedAt,
        pickupLocation: pickupLocation ?? this.pickupLocation,
        dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      );
    }

    // Helper properties
    bool get isPending => status == 'pending';
    bool get isApprovedStatus => status == 'approved' && isApproved;
    bool get isRejected => status == 'rejected';
    bool get isCancelled => status == 'cancelled';

    @override
    String toString() {
      return 'BookingModel(bookingId: $bookingId, rideId: $rideId, userId: $userId, status: $status, isApproved: $isApproved)';
    }
  }
