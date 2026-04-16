import 'package:flutter/material.dart';
import '../models/ride_model.dart';
import '../models/driver_model.dart';
import '../services/ride_service.dart';

class RideController extends ChangeNotifier {
  final RideService _rideService = RideService();

  List<RideModel> _rides = [];
  List<DriverModel> _drivers = [];
  RideModel? _selectedRide;
  DriverModel? _selectedDriver;
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  List<RideModel> get rides => _rides;
  List<DriverModel> get drivers => _drivers;
  RideModel? get selectedRide => _selectedRide;
  DriverModel? get selectedDriver => _selectedDriver;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Fetch all rides
  Future<void> fetchAllRides() async {
    try {
      _setLoading(true);
      _errorMessage = '';
      _rides = await _rideService.getAllRides();
      _errorMessage = '';
      _setLoading(false);
    } catch (e) {
      print('ERROR: Failed to fetch all rides: $e');
      _errorMessage = e.toString();
      _setLoading(false);
    }
  }

  // Fetch rides by status
  Future<void> fetchRidesByStatus(String status) async {
    _setLoading(true);
    _errorMessage = '';

    try {
      _rides = await _rideService.getRidesByStatus(status);
      _setLoading(false);
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
    }
  }

  // Fetch rides by driver
  Future<void> fetchRidesByDriver(String driverId) async {
    _setLoading(true);
    _errorMessage = '';

    try {
      _rides = await _rideService.getRidesByDriver(driverId);
      _setLoading(false);
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
    }
  }

  // Fetch single ride and driver
  Future<void> fetchRideDetails(String rideId) async {
    _setLoading(true);
    _errorMessage = '';

    try {
      _selectedRide = await _rideService.getRideById(rideId);

      if (_selectedRide != null) {
        _selectedDriver =
            await _rideService.getDriverById(_selectedRide!.driverId);
      }

      _setLoading(false);
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
    }
  }

  // Create ride
  Future<bool> createRide(RideModel ride) async {
    _setLoading(true);
    _errorMessage = '';

    try {
      await _rideService.createRide(ride);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Update ride status
  Future<bool> updateRideStatus(String rideId, String newStatus) async {
    _setLoading(true);
    _errorMessage = '';

    try {
      await _rideService.updateRideStatus(rideId, newStatus);

      // Update local list
      final index = _rides.indexWhere((r) => r.rideId == rideId);
      if (index != -1) {
        _rides[index] = _rides[index].copyWith(status: newStatus);
      }

      // Update selected ride
      if (_selectedRide?.rideId == rideId) {
        _selectedRide = _selectedRide!.copyWith(status: newStatus);
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Delete ride
  Future<bool> deleteRide(String rideId) async {
    _setLoading(true);
    _errorMessage = '';

    try {
      await _rideService.deleteRide(rideId);

      _rides.removeWhere((r) => r.rideId == rideId);

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Fetch driver details
  Future<void> fetchDriver(String driverId) async {
    _setLoading(true);
    _errorMessage = '';

    try {
      _selectedDriver = await _rideService.getDriverById(driverId);
      _setLoading(false);
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
    }
  }

  // Fetch all drivers
  Future<void> fetchAllDrivers() async {
    _setLoading(true);
    _errorMessage = '';

    try {
      _drivers = await _rideService.getAllDrivers();
      _setLoading(false);
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
    }
  }

  // Fetch online drivers
  Future<void> fetchOnlineDrivers() async {
    _setLoading(true);
    _errorMessage = '';

    try {
      _drivers = await _rideService.getOnlineDrivers();
      _setLoading(false);
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearSelectedRide() {
    _selectedRide = null;
    _selectedDriver = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Repair missing passenger data in Firestore
  Future<void> repairPassengerData() async {
    _setLoading(true);
    try {
      await _rideService.repairMissingPassengerData();
      _setLoading(false);
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
    }
  }
}
