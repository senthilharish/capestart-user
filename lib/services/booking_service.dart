import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new booking
  Future<BookingModel> createBooking(BookingModel booking) async {
    try {
      final docRef = _firestore.collection('bookings').doc();
      final bookingWithId = booking.copyWith(bookingId: docRef.id);

      await docRef.set(bookingWithId.toJson());
      return bookingWithId;
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  // Get booking by ID
  Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      final doc = await _firestore.collection('bookings').doc(bookingId).get();

      if (doc.exists && doc.data() != null) {
        return BookingModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch booking: $e');
    }
  }

  // Get all bookings by user ID
  Future<List<BookingModel>> getBookingsByUserId(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .orderBy('bookedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => BookingModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch user bookings: $e');
    }
  }

  // Get all bookings by ride ID
  Future<List<BookingModel>> getBookingsByRideId(String rideId) async {
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('rideId', isEqualTo: rideId)
          .get();

      return snapshot.docs
          .map((doc) => BookingModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch ride bookings: $e');
    }
  }

  // Get bookings by user and status
  Future<List<BookingModel>> getBookingsByUserAndStatus(
    String userId,
    String status,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: status)
          .orderBy('bookedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => BookingModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch bookings: $e');
    }
  }

  // Update booking status
  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': newStatus,
      });
    } catch (e) {
      throw Exception('Failed to update booking status: $e');
    }
  }

  // Approve booking
  Future<void> approveBooking(String bookingId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'isApproved': true,
        'status': 'approved',
        'approvedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to approve booking: $e');
    }
  }

  // Reject booking
  Future<void> rejectBooking(String bookingId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'isApproved': false,
        'status': 'rejected',
      });
    } catch (e) {
      throw Exception('Failed to reject booking: $e');
    }
  }

  // Cancel booking
  Future<void> cancelBooking(String bookingId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': 'cancelled',
      });
    } catch (e) {
      throw Exception('Failed to cancel booking: $e');
    }
  }

  // Delete booking
  Future<void> deleteBooking(String bookingId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).delete();
    } catch (e) {
      throw Exception('Failed to delete booking: $e');
    }
  }

  // Stream for real-time bookings by user
  Stream<List<BookingModel>> streamUserBookings(String userId) {
    try {
      return _firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .orderBy('bookedAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => BookingModel.fromJson(doc.data()))
            .toList();
      });
    } catch (e) {
      throw Exception('Failed to stream bookings: $e');
    }
  }

  // Stream for real-time bookings by ride
  Stream<List<BookingModel>> streamRideBookings(String rideId) {
    try {
      return _firestore
          .collection('bookings')
          .where('rideId', isEqualTo: rideId)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => BookingModel.fromJson(doc.data()))
            .toList();
      });
    } catch (e) {
      throw Exception('Failed to stream ride bookings: $e');
    }
  }

  // Get total bookings for a ride
  Future<int> getTotalBookingsForRide(String rideId) async {
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('rideId', isEqualTo: rideId)
          .where('status', isEqualTo: 'approved')
          .get();

      int totalSeats = 0;
      for (var doc in snapshot.docs) {
        totalSeats += doc['seatsBooked'] as int? ?? 0;
      }
      return totalSeats;
    } catch (e) {
      throw Exception('Failed to get total bookings: $e');
    }
  }

  // Check if user already booked this ride
  Future<BookingModel?> getUserBookingForRide(
    String userId,
    String rideId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .where('rideId', isEqualTo: rideId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return BookingModel.fromJson(snapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      throw Exception('Failed to check user booking: $e');
    }
  }
}
