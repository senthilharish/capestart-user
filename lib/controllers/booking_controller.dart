import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';
import '../services/ride_service.dart';

class BookingController extends ChangeNotifier {
  final BookingService _bookingService = BookingService();
  final RideService _rideService = RideService();

  List<BookingModel> _bookings = [];
  BookingModel? _selectedBooking;
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  List<BookingModel> get bookings => _bookings;
  BookingModel? get selectedBooking => _selectedBooking;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Create a new booking
  Future<BookingModel?> createBooking(
    String userId,
    String rideId,
    String driverId,
    int seatsBooked,
    double pricePerSeat,
    String? pickupLocation,
    String? dropoffLocation,
  ) async {
    try {
      _setLoading(true);
      _errorMessage = '';

      final totalPrice = seatsBooked * pricePerSeat;

      final booking = BookingModel(
        bookingId: '',
        userId: userId,
        rideId: rideId,
        driverId: driverId,
        seatsBooked: seatsBooked,
        pricePerSeat: pricePerSeat,
        totalPrice: totalPrice,
        isApproved: false,
        status: 'pending',
        bookedAt: DateTime.now(),
        pickupLocation: pickupLocation,
        dropoffLocation: dropoffLocation,
      );

      print('DEBUG: Creating booking with details: userId=$userId, rideId=$rideId, seats=$seatsBooked');

      final createdBooking = await _bookingService.createBooking(booking);

      print('DEBUG: Booking created successfully: ${createdBooking.bookingId}');
      
      // Update the ride's passenger count
      try {
        await _rideService.updatePassengerCount(rideId, seatsBooked);
        print('DEBUG: Passenger count updated for ride $rideId');
      } catch (e) {
        print('Warning: Failed to update passenger count: $e');
        // Don't fail the booking if passenger count update fails
      }
      
      _selectedBooking = createdBooking;
      _errorMessage = '';
      _setLoading(false);
      notifyListeners();
      return createdBooking;
    } catch (e) {
      print('ERROR: Exception during booking creation: $e');
      _errorMessage = 'Booking failed: ${e.toString()}';
      _setLoading(false);
      notifyListeners();
      return null;
    }
  }

  // Fetch all bookings for a user
  Future<void> fetchUserBookings(String userId) async {
    _setLoading(true);
    _errorMessage = '';

    try {
      _bookings = await _bookingService.getBookingsByUserId(userId);
      _setLoading(false);
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
    }
  }

  // Fetch bookings by status
  Future<void> fetchBookingsByStatus(String userId, String status) async {
    _setLoading(true);
    _errorMessage = '';

    try {
      _bookings =
          await _bookingService.getBookingsByUserAndStatus(userId, status);
      _setLoading(false);
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
    }
  }

  // Fetch a single booking
  Future<void> fetchBookingById(String bookingId) async {
    _setLoading(true);
    _errorMessage = '';

    try {
      _selectedBooking = await _bookingService.getBookingById(bookingId);
      _setLoading(false);
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
    }
  }

  // Get bookings for a specific ride
  Future<void> fetchRideBookings(String rideId) async {
    _setLoading(true);
    _errorMessage = '';

    try {
      _bookings = await _bookingService.getBookingsByRideId(rideId);
      _setLoading(false);
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
    }
  }

  // Approve booking (for driver)
  Future<bool> approveBooking(String bookingId) async {
    _setLoading(true);
    _errorMessage = '';

    try {
      await _bookingService.approveBooking(bookingId);

      // Update local list
      final index = _bookings.indexWhere((b) => b.bookingId == bookingId);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(
          isApproved: true,
          status: 'approved',
        );
      }

      // Update selected booking
      if (_selectedBooking?.bookingId == bookingId) {
        _selectedBooking = _selectedBooking!.copyWith(
          isApproved: true,
          status: 'approved',
        );
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Reject booking (for driver)
  Future<bool> rejectBooking(String bookingId) async {
    _setLoading(true);
    _errorMessage = '';

    try {
      await _bookingService.rejectBooking(bookingId);

      // Update local list
      final index = _bookings.indexWhere((b) => b.bookingId == bookingId);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(
          isApproved: false,
          status: 'rejected',
        );
      }

      // Update selected booking
      if (_selectedBooking?.bookingId == bookingId) {
        _selectedBooking = _selectedBooking!.copyWith(
          isApproved: false,
          status: 'rejected',
        );
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Cancel booking (for user)
  Future<bool> cancelBooking(String bookingId) async {
    _setLoading(true);
    _errorMessage = '';

    try {
      // Find the booking to get seatsBooked and rideId
      BookingModel? bookingToCancel;
      final index = _bookings.indexWhere((b) => b.bookingId == bookingId);
      if (index != -1) {
        bookingToCancel = _bookings[index];
      } else if (_selectedBooking?.bookingId == bookingId) {
        bookingToCancel = _selectedBooking;
      }

      await _bookingService.cancelBooking(bookingId);

      // Decrement the ride's passenger count if we found the booking
      if (bookingToCancel != null && bookingToCancel.rideId.isNotEmpty) {
        try {
          await _rideService.updatePassengerCount(
            bookingToCancel.rideId,
            -bookingToCancel.seatsBooked, // Negative to decrement
          );
        } catch (e) {
          print('Warning: Failed to update passenger count: $e');
          // Don't fail the cancellation if passenger count update fails
        }
      }

      // Update local list
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(
          status: 'cancelled',
        );
      }

      // Update selected booking
      if (_selectedBooking?.bookingId == bookingId) {
        _selectedBooking = _selectedBooking!.copyWith(
          status: 'cancelled',
        );
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Check if user already has a booking for this ride
  Future<BookingModel?> getUserBookingForRide(
    String userId,
    String rideId,
  ) async {
    _setLoading(true);
    _errorMessage = '';

    try {
      final booking =
          await _bookingService.getUserBookingForRide(userId, rideId);
      _setLoading(false);
      return booking;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return null;
    }
  }

  // Get total seats booked for a ride
  Future<int> getTotalBookedSeats(String rideId) async {
    _setLoading(true);
    _errorMessage = '';

    try {
      final totalSeats =
          await _bookingService.getTotalBookingsForRide(rideId);
      _setLoading(false);
      return totalSeats;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return 0;
    }
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearSelectedBooking() {
    _selectedBooking = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
