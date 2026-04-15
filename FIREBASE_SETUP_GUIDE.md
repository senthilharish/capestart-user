# CapeStart User - Flutter Firebase App Setup Guide

## Project Overview

A modern Flutter mobile application with Firebase Authentication and Cloud Firestore integration. Features a clean, minimal UI inspired by the Rapido app with bold yellow/black theme and rounded components.

## Features

✅ **Authentication System**
- Phone number based authentication (converted to email format)
- Firebase Authentication
- Password validation (minimum 6 characters)
- Password visibility toggle

✅ **User Management**
- User registration with username, phone, and password
- Automatic location detection using Geolocator
- User profile with all details stored in Firestore

✅ **UI/UX Design**
- Modern, clean interface inspired by Rapido
- Bold yellow (#FFD700) and black (#1A1A1A) color scheme
- Rounded text fields and large buttons
- Smooth transitions between screens
- Loading indicators and error messages

✅ **Architecture**
- MVC Pattern (Models, Views, Controllers, Services)
- Provider pattern for state management
- Clean separation of concerns
- Reusable components

---

## Project Structure

```
lib/
├── main.dart                           # App entry point
├── firebase_options.dart               # Firebase configuration (auto-generated)
├── constants/
│   └── app_constants.dart             # App theme and constants
├── models/
│   └── user_model.dart                # User data model
├── services/
│   └── auth_service.dart              # Firebase authentication service
├── controllers/
│   └── auth_controller.dart           # State management for auth
├── views/
│   ├── auth/
│   │   ├── login_page.dart            # Login screen
│   │   └── signup_page.dart           # Signup screen
│   └── home/
│       └── home_page.dart             # Home/Dashboard screen
```

---

## Setup Instructions

### 1. Firebase Project Setup

#### Step 1: Create a Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter project name (e.g., "CapeStart User")
4. Choose your preferred region
5. Click "Create project"

#### Step 2: Enable Firebase Services

**Authentication:**
1. Navigate to "Authentication" in the left sidebar
2. Click "Get started"
3. Select "Email/Password" provider
4. Enable it
5. Click "Save"

**Cloud Firestore:**
1. Navigate to "Firestore Database" in the left sidebar
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select your preferred region
5. Click "Create"

#### Step 3: Add Your App to Firebase

**For Android:**
1. In Firebase Console, click "Add app" → "Android"
2. Enter package name: `com.example.users`
3. Download `google-services.json`
4. Place it in `android/app/` directory

**For iOS:**
1. In Firebase Console, click "Add app" → "iOS"
2. Enter bundle ID: `com.example.users`
3. Download `GoogleService-Info.plist`
4. Open `ios/Runner.xcworkspace` with Xcode
5. Add the downloaded file to the project
6. Select "Runner" target, and ensure file is added to the target

**For Web:**
1. In Firebase Console, click "Add app" → "Web"
2. Copy the Firebase config object (you'll see the script tag)
3. Update `web/index.html` with the config

### 2. Flutter Setup

#### Step 1: Ensure Flutter is Installed
```bash
flutter --version
```

#### Step 2: Get Dependencies
```bash
cd d:\work\capestart-user
flutter pub get
```

#### Step 3: Run the App

**For Android:**
```bash
flutter run
```

**For iOS:**
```bash
flutter run -d ios
```

**For Web:**
```bash
flutter run -d web
```

---

## Phone Number to Email Conversion

The app converts phone numbers to email format for Firebase Authentication:

```
Phone: 9876543210
Email: 9876543210@user.com
```

**Validation Rules:**
- Phone number must be exactly 10 digits
- Only digits are considered (spaces, dashes, etc., are removed)
- Invalid phone numbers show an error message

---

## Firestore Database Structure

### Collection: `users`

Each document in the `users` collection has the following structure:

```json
{
  "uid": "firebase_user_id",
  "username": "john_doe",
  "phone": "9876543210",
  "email": "9876543210@user.com",
  "password": "encrypted_password",
  "location": {
    "latitude": 28.7041,
    "longitude": 77.1025,
    "address": "28.7041, 77.1025"
  },
  "createdAt": "2026-04-15T10:30:00.000Z"
}
```

### Firestore Rules (Test Mode)

For development/testing, use these rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
  }
}
```

For production, tighten the rules based on your requirements.

---

## Dependencies Used

```yaml
firebase_core: ^3.0.0          # Firebase initialization
firebase_auth: ^5.0.0          # Firebase Authentication
cloud_firestore: ^5.0.0        # Firebase Firestore
geolocator: ^11.0.0            # Location services
provider: ^6.0.0               # State management
intl: ^0.20.0                  # Internationalization/formatting
```

---

## Key Features Explained

### 1. Authentication Service (`services/auth_service.dart`)

**Phone to Email Conversion:**
```dart
String _phoneToEmail(String phone) {
  String cleanedPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
  return '$cleanedPhone@user.com';
}
```

**Signup Process:**
- Validates phone number
- Converts phone to email
- Creates Firebase Auth user
- Fetches user location
- Stores user data in Firestore

**Login Process:**
- Validates phone number
- Converts phone to email
- Authenticates with Firebase
- Retrieves user data from Firestore

### 2. State Management (`controllers/auth_controller.dart`)

Uses `ChangeNotifier` with Provider pattern for:
- User authentication state
- Loading indicators
- Error message handling
- Password visibility toggle
- Input validation

### 3. UI Design (`constants/app_constants.dart`)

**Color Scheme:**
- Primary: #FFD700 (Bold Yellow)
- Dark: #1A1A1A (Dark Black)
- Accent: #FF6B6B (Red)
- Light Gray: #F5F5F5
- Error: #E74C3C

**Typography:**
- Large heading: 28px bold
- Medium heading: 24px bold
- Body large: 16px
- Body medium: 14px
- Body small: 12px

**Border Radius:**
- Small: 8px
- Medium: 12px
- Large: 20px
- Button: 16px

---

## Permissions Required

### Android (`android/app/src/main/AndroidManifest.xml`)

Add these permissions for location:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS (`ios/Runner/Info.plist`)

Add these keys:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs your location to provide better services</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs your location to provide better services</string>
```

---

## Testing the App

### Test Account

Create a test account using the signup page:
- **Username:** test_user
- **Phone:** 9876543210
- **Password:** Test@123

### Test Credentials

Login with:
- **Phone:** 9876543210
- **Password:** Test@123

### Firestore Verification

1. Open Firebase Console
2. Navigate to Firestore Database
3. Check the `users` collection
4. Verify the document with UID contains all user data

---

## Common Issues & Solutions

### Issue: "java.io.IOException: Missing google-services.json"

**Solution:**
1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/` directory
3. Run `flutter clean` and `flutter pub get`

### Issue: "PlatformException: Sign up failed"

**Solution:**
1. Check Firebase Authentication is enabled
2. Verify phone number is 10 digits
3. Ensure password is at least 6 characters

### Issue: Location permission denied

**Solution:**
1. Grant location permission in app settings
2. The app will still work with location as "Unable to fetch location"
3. For testing, you can use mock location or emulator features

### Issue: "No module named firebase"

**Solution:**
1. Run `flutter pub get` again
2. Run `flutter clean`
3. Run `flutter pub get` and `flutter run`

---

## Security Notes

⚠️ **Important:** The current implementation stores passwords in Firestore. For production:

1. **DO NOT store passwords** in Firestore
2. Use Firebase Auth's built-in password management
3. Implement Firebase Security Rules properly
4. Use Firebase Admin SDK for sensitive operations
5. Never commit `google-services.json` to public repositories

---

## Production Checklist

- [ ] Enable Firebase Security Rules
- [ ] Remove password storage from Firestore
- [ ] Implement password reset functionality
- [ ] Add email verification
- [ ] Implement phone number verification (Firebase Phone Auth)
- [ ] Set up proper error handling
- [ ] Add comprehensive logging
- [ ] Implement rate limiting
- [ ] Add user data encryption
- [ ] Test on real devices
- [ ] Implement app signing for Android
- [ ] Set up CI/CD pipeline

---

## API Reference

### AuthController

```dart
// Sign up a new user
Future<bool> signup({
  required String username,
  required String phone,
  required String password,
})

// Login existing user
Future<bool> login({
  required String phone,
  required String password,
})

// Logout current user
Future<void> logout()

// Check current logged-in user
Future<void> checkCurrentUser()

// Toggle password visibility
void togglePasswordVisibility()

// Clear error messages
void clearErrorMessage()
```

### AuthService

```dart
// Validate phone number (10 digits only)
bool isValidPhoneNumber(String phone)

// Convert phone to email format
String _phoneToEmail(String phone)

// Get user's current location
Future<Map<String, dynamic>> _getUserLocation()
```

---

## Support & Documentation

- **Firebase Documentation:** https://firebase.flutter.dev/
- **Flutter Documentation:** https://flutter.dev/docs
- **Provider Package:** https://pub.dev/packages/provider
- **Geolocator Package:** https://pub.dev/packages/geolocator

---

## License

This project is provided as-is for educational and development purposes.

---

## Version

- **App Version:** 1.0.0
- **Flutter SDK:** 3.6.1+
- **Dart SDK:** 3.6.1+

---

**Last Updated:** April 15, 2026
