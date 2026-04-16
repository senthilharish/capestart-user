# Android Permissions Setup Guide

## Overview
This document outlines all the permissions configured for the CapeStart User Android build.

## AndroidManifest.xml Permissions

### 1. Location Permissions
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```
**Purpose:** Used by Geolocator plugin to track user location for ride booking and driver tracking
**Runtime Permission Required:** Yes (Android 6.0+)

### 2. Internet Permissions
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```
**Purpose:** Required for Firebase authentication and Firestore database connectivity
**Runtime Permission Required:** No (system permission)

### 3. Camera Permission
```xml
<uses-permission android:name="android.permission.CAMERA" />
```
**Purpose:** For future profile picture uploads or document verification
**Runtime Permission Required:** Yes (Android 6.0+)

### 4. Storage Permissions
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```
**Purpose:** For caching, document storage, or image uploads
**Runtime Permission Required:** Yes (Android 6.0+)

### 5. Phone State Permission
```xml
<uses-permission android:name="android.permission.READ_PHONE_STATE" />
```
**Purpose:** To get device identifiers for analytics or crash reporting
**Runtime Permission Required:** Yes (Android 6.0+)

### 6. Bluetooth Permissions
```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
```
**Purpose:** For future Bluetooth connectivity features
**Runtime Permission Required:** Yes (Android 6.0+)

## Runtime Permissions Implementation

For Android 6.0+ (API level 23+), runtime permissions must be requested from users at runtime:

### Location Permission Example:
```dart
import 'package:geolocator/geolocator.dart';

Future<void> requestLocationPermission() async {
  final status = await Geolocator.requestPermission();
  if (status == LocationPermission.denied) {
    // Permission denied
  } else if (status == LocationPermission.deniedForever) {
    // Open app settings
    openAppSettings();
  }
}
```

### Camera Permission Example:
```dart
import 'package:permission_handler/permission_handler.dart';

Future<void> requestCameraPermission() async {
  final status = await Permission.camera.request();
  if (status.isDenied) {
    // Permission denied
  } else if (status.isPermanentlyDenied) {
    // Open app settings
    openAppSettings();
  }
}
```

## Build Configuration

### compileSdk and targetSdk
- **Current Target:** Flutter default (usually Android 14 / API 34)
- **Minimum SDK:** Flutter default (usually Android 5.0 / API 21)

Update in `android/app/build.gradle`:
```gradle
android {
    compileSdk = flutter.compileSdkVersion  // Currently API 34
    
    defaultConfig {
        minSdk = flutter.minSdkVersion      // Currently API 21
        targetSdk = flutter.targetSdkVersion // Currently API 34
    }
}
```

## Gradle Configuration

### Key Settings in android/gradle.properties:
```properties
org.gradle.jvmargs=-Xmx4G -XX:MaxMetaspaceSize=2G -XX:+HeapDumpOnOutOfMemoryError
android.useAndroidX=true
android.enableJetifier=true
```

These settings:
- Allocate 4GB JVM memory for faster builds
- Enable AndroidX support (required for modern dependencies)
- Enable Jetifier for legacy library compatibility

## Building for Android

### Clean Build (Recommended)
```bash
flutter clean
flutter pub get
flutter build apk --release
```

### Incremental Build
```bash
flutter build apk --release
```

### Debug Build (for testing)
```bash
flutter run
```

## Testing Permissions

### Check Current Permissions:
```dart
import 'package:geolocator/geolocator.dart';

Future<void> checkPermissions() async {
  final status = await Geolocator.checkPermission();
  print('Location Permission: $status');
}
```

### Request Specific Permissions:
Update `android/app/src/main/AndroidManifest.xml` and build. The system will prompt users for permission on first use.

## Important Notes

1. **Location Services:** Ensure location services are enabled on the device
2. **Background Location:** Only available if the app has foreground location permission first
3. **Runtime Permissions:** Always check permission status before using a feature
4. **Privacy Policy:** Include information about location tracking in your app's privacy policy
5. **Firebase:** Requires INTERNET permission (already included)

## Troubleshooting

### Build Fails with Permission Errors:
- Run `flutter clean && flutter pub get`
- Verify `android/app/src/main/AndroidManifest.xml` has correct syntax
- Check `android/app/build.gradle` for proper configuration

### Permissions Not Requested at Runtime:
- Ensure your app code explicitly requests permissions using permission handler
- Test on Android 6.0+ device or emulator

### Geolocator Issues:
- Verify both FINE and COARSE location permissions are granted
- Check device location settings are enabled
- Ensure background location permission for tracking features

## File Locations

- **Manifest:** `android/app/src/main/AndroidManifest.xml`
- **Build Config:** `android/app/build.gradle`
- **Gradle Properties:** `android/gradle.properties`
- **Root Build:** `android/build.gradle`
