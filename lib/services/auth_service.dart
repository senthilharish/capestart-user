import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Convert phone number to email format
  String _phoneToEmail(String phone) {
    // Remove any non-digit characters
    String cleanedPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    return '$cleanedPhone@user.com';
  }

  // Validate phone number
  bool isValidPhoneNumber(String phone) {
    final phoneRegex = RegExp(r'^\d{10}$');
    return phoneRegex.hasMatch(phone.replaceAll(RegExp(r'[^\d]'), ''));
  }

  // Get current user location
  Future<Map<String, dynamic>> _getUserLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        final newPermission = await Geolocator.requestPermission();
        if (newPermission == LocationPermission.denied) {
          return {
            'latitude': 0.0,
            'longitude': 0.0,
            'address': 'Location permission denied',
          };
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return {
          'latitude': 0.0,
          'longitude': 0.0,
          'address': 'Location permission denied permanently',
        };
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'address': '${position.latitude}, ${position.longitude}',
      };
    } catch (e) {
      return {
        'latitude': 0.0,
        'longitude': 0.0,
        'address': 'Unable to fetch location',
      };
    }
  }

  // Sign up with username and phone
  Future<UserModel?> signup({
    required String username,
    required String phone,
    required String password,
  }) async {
    try {
      final email = _phoneToEmail(phone);

      // Create user with Firebase Auth
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get user location
      final location = await _getUserLocation();

      // Create user model
      final user = UserModel(
        uid: userCredential.user!.uid,
        username: username,
        phone: phone,
        email: email,
        password: password,
        location: location,
        createdAt: DateTime.now(),
      );

      // Store in Firestore
      await _firestore.collection('users').doc(user.uid).set(user.toJson());

      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred: ${e.toString()}';
    }
  }

  // Login with phone and password
  Future<UserModel?> login({
    required String phone,
    required String password,
  }) async {
    try {
      final email = _phoneToEmail(phone);

      // Sign in with Firebase Auth
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch user data from Firestore
      final docSnapshot = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (docSnapshot.exists) {
        return UserModel.fromJson(docSnapshot.data() as Map<String, dynamic>);
      }

      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred: ${e.toString()}';
    }
  }

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) return null;

      final docSnapshot =
          await _firestore.collection('users').doc(currentUser.uid).get();

      if (docSnapshot.exists) {
        return UserModel.fromJson(docSnapshot.data() as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      throw 'Failed to fetch current user: ${e.toString()}';
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw 'Failed to logout: ${e.toString()}';
    }
  }

  // Check if user is logged in
  bool isUserLoggedIn() {
    return _firebaseAuth.currentUser != null;
  }

  // Get current Firebase user
  User? get currentFirebaseUser => _firebaseAuth.currentUser;

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'This phone number is already registered.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'User not found. Please sign up first.';
      case 'wrong-password':
        return 'Incorrect password.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}
