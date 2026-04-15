import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ride_model.dart';
import '../models/driver_model.dart';

class RideService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection names
  static const String _ridesCollection = 'rides';
  static const String _driversCollection = 'drivers';

  // Fetch all rides from Firestore
  Future<List<RideModel>> getAllRides() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection(_ridesCollection).get();

      return snapshot.docs
          .map((doc) => RideModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw 'Failed to fetch rides: ${e.toString()}';
    }
  }

  // Fetch rides by status
  Future<List<RideModel>> getRidesByStatus(String status) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection(_ridesCollection)
          .where('status', isEqualTo: status)
          .get();

      return snapshot.docs
          .map((doc) => RideModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw 'Failed to fetch rides by status: ${e.toString()}';
    }
  }

  // Fetch rides by driver ID
  Future<List<RideModel>> getRidesByDriver(String driverId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection(_ridesCollection)
          .where('driverId', isEqualTo: driverId)
          .get();

      return snapshot.docs
          .map((doc) => RideModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw 'Failed to fetch driver rides: ${e.toString()}';
    }
  }

  // Fetch single ride by ID
  Future<RideModel?> getRideById(String rideId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection(_ridesCollection).doc(rideId).get();

      if (snapshot.exists && snapshot.data() != null) {
        return RideModel.fromJson(snapshot.data()!);
      }
      return null;
    } catch (e) {
      throw 'Failed to fetch ride: ${e.toString()}';
    }
  }

  // Create a new ride
  Future<RideModel> createRide(RideModel ride) async {
    try {
      final docRef = _firestore.collection(_ridesCollection).doc(ride.rideId);
      await docRef.set(ride.toJson());
      return ride;
    } catch (e) {
      throw 'Failed to create ride: ${e.toString()}';
    }
  }

  // Update ride
  Future<void> updateRide(RideModel ride) async {
    try {
      await _firestore
          .collection(_ridesCollection)
          .doc(ride.rideId)
          .update(ride.toJson());
    } catch (e) {
      throw 'Failed to update ride: ${e.toString()}';
    }
  }

  // Update ride status
  Future<void> updateRideStatus(String rideId, String newStatus) async {
    try {
      await _firestore
          .collection(_ridesCollection)
          .doc(rideId)
          .update({'status': newStatus});
    } catch (e) {
      throw 'Failed to update ride status: ${e.toString()}';
    }
  }

  // Delete ride
  Future<void> deleteRide(String rideId) async {
    try {
      await _firestore.collection(_ridesCollection).doc(rideId).delete();
    } catch (e) {
      throw 'Failed to delete ride: ${e.toString()}';
    }
  }

  // Update passenger count (increment/decrement)
  Future<void> updatePassengerCount(String rideId, int seatCount) async {
    try {
      await _firestore
          .collection(_ridesCollection)
          .doc(rideId)
          .update({
            'numberOfPassengers': FieldValue.increment(seatCount),
          });
    } catch (e) {
      throw 'Failed to update passenger count: ${e.toString()}';
    }
  }

  // Fetch driver details
  Future<DriverModel?> getDriverById(String driverId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection(_driversCollection).doc(driverId).get();

      if (snapshot.exists && snapshot.data() != null) {
        return DriverModel.fromJson(snapshot.data()!);
      }
      return null;
    } catch (e) {
      throw 'Failed to fetch driver: ${e.toString()}';
    }
  }

  // Fetch all drivers
  Future<List<DriverModel>> getAllDrivers() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection(_driversCollection).get();

      return snapshot.docs
          .map((doc) => DriverModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw 'Failed to fetch drivers: ${e.toString()}';
    }
  }

  // Fetch online drivers
  Future<List<DriverModel>> getOnlineDrivers() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection(_driversCollection)
          .where('isOnline', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => DriverModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw 'Failed to fetch online drivers: ${e.toString()}';
    }
  }

  // Create driver
  Future<DriverModel> createDriver(DriverModel driver) async {
    try {
      await _firestore
          .collection(_driversCollection)
          .doc(driver.driverId)
          .set(driver.toJson());
      return driver;
    } catch (e) {
      throw 'Failed to create driver: ${e.toString()}';
    }
  }

  // Update driver
  Future<void> updateDriver(DriverModel driver) async {
    try {
      await _firestore
          .collection(_driversCollection)
          .doc(driver.driverId)
          .update(driver.toJson());
    } catch (e) {
      throw 'Failed to update driver: ${e.toString()}';
    }
  }

  // Update driver location
  Future<void> updateDriverLocation(
    String driverId,
    double latitude,
    double longitude,
  ) async {
    try {
      await _firestore.collection(_driversCollection).doc(driverId).update({
        'currentLatitude': latitude,
        'currentLongitude': longitude,
      });
    } catch (e) {
      throw 'Failed to update driver location: ${e.toString()}';
    }
  }

  // Listen to rides in real-time
  Stream<List<RideModel>> streamRides() {
    return _firestore.collection(_ridesCollection).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => RideModel.fromJson(doc.data()))
              .toList(),
        );
  }

  // Listen to specific ride in real-time
  Stream<RideModel?> streamRideById(String rideId) {
    return _firestore
        .collection(_ridesCollection)
        .doc(rideId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return RideModel.fromJson(snapshot.data()!);
      }
      return null;
    });
  }

  // Listen to driver in real-time
  Stream<DriverModel?> streamDriverById(String driverId) {
    return _firestore
        .collection(_driversCollection)
        .doc(driverId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return DriverModel.fromJson(snapshot.data()!);
      }
      return null;
    });
  }

  // Repair rides that are missing passenger capacity data
  Future<void> repairMissingPassengerData() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection(_ridesCollection).get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final numberOfPassengersAllocated =
            data['numberOfPassengersAllocated'] as int?;
        final numberOfPassengers = data['numberOfPassengers'] as int?;

        // If either field is missing or invalid, update the document
        if (numberOfPassengersAllocated == null ||
            numberOfPassengersAllocated <= 0 ||
            numberOfPassengers == null) {
          print(
              'Repairing ride ${doc.id}: allocated=${numberOfPassengersAllocated ?? 'null'}, passengers=${numberOfPassengers ?? 'null'}');
          
          await _firestore
              .collection(_ridesCollection)
              .doc(doc.id)
              .update({
            'numberOfPassengersAllocated':
                numberOfPassengersAllocated ?? 4, // Default to 4 seats
            'numberOfPassengers': numberOfPassengers ?? 0, // Default to 0 booked
          });
        }
      }
      print('Repair completed');
    } catch (e) {
      print('Failed to repair rides: ${e.toString()}');
    }
  }
}

