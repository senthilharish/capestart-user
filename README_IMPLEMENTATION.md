# CapeStart User - Firebase Flutter App

A modern Flutter mobile application featuring Firebase Authentication, Cloud Firestore integration, and a clean UI inspired by the Rapido app.

## 🎯 Features

### Authentication
- 📱 Phone number-based authentication (converted to email)
- 🔐 Secure password validation (minimum 6 characters)
- 👁️ Password visibility toggle
- ✅ Real-time input validation

### User Management
- 📝 User registration with username, phone, and password
- 📍 Automatic location detection
- 💾 Cloud Firestore data storage
- 👤 User profile with complete details

### UI/UX Design
- 🎨 Modern, minimal interface inspired by Rapido
- 🌟 Bold yellow (#FFD700) and black (#1A1A1A) color scheme
- ⭕ Rounded components and smooth transitions
- 📱 Responsive design for all screen sizes
- ⏳ Loading indicators and error handling

### Architecture
- 🏗️ MVC Pattern (Models, Views, Controllers, Services)
- 🔄 Provider state management
- 🧩 Reusable components
- 🎯 Clean separation of concerns

---

## 📸 App Screenshots

### Login Screen
- Phone number input field
- Password input with visibility toggle
- "Forgot Password" link
- Sign up navigation
- Yellow bold theme

### Signup Screen
- Username input
- Phone number input
- Password input with toggle
- Sign up button with loading state
- Login navigation

### Home Screen
- Welcome message with username
- User info card with gradient
- Account information section
- Location details
- Logout button

---

## 🚀 Getting Started

### Prerequisites
- Flutter 3.6.1 or higher
- Dart 3.6.1 or higher
- Android Studio or Xcode (for iOS)
- Firebase account

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/senthilharish/capestart-user.git
   cd capestart-user
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Setup Firebase:**
   - Follow the [FIREBASE_SETUP_GUIDE.md](./FIREBASE_SETUP_GUIDE.md)
   - Download and configure `google-services.json` for Android
   - Download and configure `GoogleService-Info.plist` for iOS

4. **Run the app:**
   ```bash
   flutter run
   ```

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point with Firebase init
├── firebase_options.dart        # Firebase configuration
├── constants/
│   └── app_constants.dart      # Theme and app constants
├── models/
│   └── user_model.dart         # User data model
├── services/
│   └── auth_service.dart       # Firebase auth service
├── controllers/
│   └── auth_controller.dart    # State management
└── views/
    ├── auth/
    │   ├── login_page.dart     # Login screen
    │   └── signup_page.dart    # Signup screen
    └── home/
        └── home_page.dart      # Home/dashboard
```

---

## 🔑 Key Implementation Details

### Phone to Email Conversion

The app converts phone numbers to email format for Firebase Authentication:

```dart
Phone: 9876543210
Email: 9876543210@user.com
```

**Validation:**
- Must be exactly 10 digits
- Special characters are removed
- Invalid entries show error messages

### Authentication Flow

```
Signup:
1. Validate inputs (username, phone, password)
2. Convert phone to email format
3. Create Firebase Auth user
4. Fetch user location
5. Store user data in Firestore
6. Navigate to home

Login:
1. Validate phone and password
2. Convert phone to email
3. Authenticate with Firebase
4. Fetch user data from Firestore
5. Navigate to home

Logout:
1. Sign out from Firebase
2. Clear user data
3. Navigate to login
```

### Firestore Database

**Collection:** `users`

**Document Structure:**
```json
{
  "uid": "firebase_user_id",
  "username": "john_doe",
  "phone": "9876543210",
  "email": "9876543210@user.com",
  "password": "password_hash",
  "location": {
    "latitude": 28.7041,
    "longitude": 77.1025,
    "address": "28.7041, 77.1025"
  },
  "createdAt": "2026-04-15T10:30:00.000Z"
}
```

---

## 🎨 Design System

### Colors
| Purpose | Color | Hex |
|---------|-------|-----|
| Primary | Bold Yellow | #FFD700 |
| Dark | Black | #1A1A1A |
| Accent | Red | #FF6B6B |
| Light Background | Light Gray | #F5F5F5 |
| Text | Dark Gray | #333333 |
| Error | Red | #E74C3C |
| Success | Green | #27AE60 |

### Typography
- **Heading (Large):** 28px, Bold
- **Heading (Medium):** 24px, Bold
- **Body (Large):** 16px
- **Body (Medium):** 14px
- **Body (Small):** 12px

### Border Radius
- **Small:** 8px
- **Medium:** 12px
- **Large:** 20px
- **Button:** 16px

### Spacing (Padding/Margin)
- **Small:** 8px
- **Medium:** 16px
- **Large:** 24px

---

## 📦 Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| firebase_core | ^3.0.0 | Firebase initialization |
| firebase_auth | ^5.0.0 | Authentication |
| cloud_firestore | ^5.0.0 | Database |
| geolocator | ^11.0.0 | Location services |
| provider | ^6.0.0 | State management |
| intl | ^0.20.0 | Date/time formatting |

---

## 🔐 Security

### Current Implementation
⚠️ **Note:** Passwords are currently stored in Firestore for demonstration purposes.

### Production Recommendations
1. ❌ **Do NOT store passwords** in Firestore
2. ✅ Use Firebase Authentication's password management
3. ✅ Implement proper Security Rules
4. ✅ Use Firebase Admin SDK for sensitive operations
5. ✅ Enable HTTPS only
6. ✅ Implement rate limiting
7. ✅ Add data encryption

### Firestore Security Rules (Test Mode)
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

---

## 📋 Permissions Required

### Android
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs your location for better services</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs your location for better services</string>
```

---

## 🧪 Testing

### Test Account
- **Username:** test_user
- **Phone:** 9876543210
- **Password:** Test@123

### Test Scenarios

1. **Signup Flow:**
   - Open app → Click "Sign Up"
   - Enter username, phone (10 digits), password
   - Grant location permission
   - Verify user created in Firestore

2. **Login Flow:**
   - Enter phone (10 digits)
   - Enter password
   - Verify user details on home screen

3. **Validation Tests:**
   - Enter invalid phone (less than 10 digits)
   - Enter weak password (less than 6 chars)
   - Try duplicate phone number

4. **Location Tests:**
   - Allow location access
   - Check location displayed on home
   - Deny location and verify fallback

---

## 🐛 Troubleshooting

### Firebase Configuration Issues
**Problem:** `java.io.IOException: Missing google-services.json`

**Solution:**
1. Download `google-services.json` from Firebase Console
2. Place in `android/app/`
3. Run `flutter clean && flutter pub get`

### Authentication Errors
**Problem:** Sign up fails

**Solution:**
- Verify Firebase Authentication is enabled
- Check phone number is exactly 10 digits
- Ensure password is at least 6 characters
- Check internet connection

### Location Permissions
**Problem:** Location not detected

**Solution:**
- Grant permission in app settings
- Restart the app
- The app will work with "Location not available" message

### Build Errors
**Problem:** Dependency conflicts

**Solution:**
```bash
flutter clean
flutter pub get
flutter pub upgrade
flutter run
```

---

## 📚 API Reference

### AuthController Methods

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

// Check current user and load data
Future<void> checkCurrentUser()

// Toggle password field visibility
void togglePasswordVisibility()

// Clear error messages
void clearErrorMessage()
```

### AuthService Methods

```dart
// Validate phone number (10 digits)
bool isValidPhoneNumber(String phone)

// Get user's current location
Future<Map<String, dynamic>> _getUserLocation()

// Convert phone to email
String _phoneToEmail(String phone)
```

---

## 📞 Phone Number Validation

The app enforces strict phone number validation:

```dart
// Valid: 9876543210
// Invalid: 98765432 (too short)
// Invalid: 98765432100 (too long)
// Invalid: 987-654-3210 (contains special chars, but digits are extracted)
// Valid: 987-654-3210 (after removing dashes: 9876543210)
```

---

## 🔄 State Management

The app uses **Provider** pattern for state management:

```dart
// Access auth controller
final authController = context.read<AuthController>();

// Listen to changes
Consumer<AuthController>(
  builder: (context, authController, _) {
    return Text(authController.currentUser?.username ?? 'Guest');
  },
)
```

---

## 🌐 Platform Support

- ✅ Android (API 21+)
- ✅ iOS (11.0+)
- ✅ Web (Chrome, Firefox, Safari)
- ✅ Windows
- ✅ macOS
- ✅ Linux

---

## 📱 Device Compatibility

- Minimum Android Version: API 21 (Android 5.0)
- Minimum iOS Version: 11.0
- Screen sizes: Phone (all), Tablet (in progress)
- Portrait and Landscape modes supported

---

## 🎓 Learning Resources

- [Firebase for Flutter](https://firebase.flutter.dev/)
- [Flutter Documentation](https://flutter.dev/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [Geolocator Package](https://pub.dev/packages/geolocator)
- [Cloud Firestore](https://cloud.google.com/firestore/docs)

---

## 📝 License

This project is provided as-is for educational and development purposes.

---

## 👨‍💻 Author

**Senthil Harish**

GitHub: [@senthilharish](https://github.com/senthilharish)

---

## 🙌 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

## 📝 Changelog

### Version 1.0.0 (April 15, 2026)
- ✨ Initial release
- 🔐 Firebase Authentication with phone-based login
- 📍 Location detection integration
- 💾 Cloud Firestore data storage
- 🎨 Rapido-inspired UI design
- 📱 MVC architecture implementation
- 🔄 Provider state management

---

## 🚀 Future Enhancements

- [ ] Phone number verification via OTP
- [ ] Email verification
- [ ] Forgot password functionality
- [ ] Social login (Google, Apple)
- [ ] User profile editing
- [ ] Profile picture upload
- [ ] Push notifications
- [ ] Dark mode
- [ ] Multi-language support
- [ ] Offline capability
- [ ] User search/discovery
- [ ] In-app messaging

---

## ⚡ Performance Tips

- The app uses lazy loading for user data
- Images are cached efficiently
- State management prevents unnecessary rebuilds
- Firestore queries are optimized with proper indexing
- Location requests have a 10-second timeout

---

## 📞 Support

For issues, questions, or suggestions:
1. Check [FIREBASE_SETUP_GUIDE.md](./FIREBASE_SETUP_GUIDE.md)
2. Check troubleshooting section above
3. Create an issue on GitHub
4. Contact the author

---

**Last Updated:** April 15, 2026  
**Version:** 1.0.0
