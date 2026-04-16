# Android Build Instructions - Quick Reference

## Prerequisites
- Android SDK (API 21-34)
- Gradle properly configured
- Flutter SDK installed
- Java Development Kit (JDK) 11+

## All Configured Permissions

### Manifest Permissions ✅
The following permissions are now configured in `android/app/src/main/AndroidManifest.xml`:

```
✅ ACCESS_FINE_LOCATION       - Precise location tracking
✅ ACCESS_COARSE_LOCATION     - Approximate location
✅ INTERNET                   - Network communication
✅ ACCESS_NETWORK_STATE       - Check network status
✅ CAMERA                     - Camera access
✅ READ_EXTERNAL_STORAGE      - Read files
✅ WRITE_EXTERNAL_STORAGE     - Write files
✅ READ_PHONE_STATE           - Device info
✅ BLUETOOTH                  - Bluetooth connectivity
✅ BLUETOOTH_ADMIN            - Bluetooth management
✅ ACCESS_BACKGROUND_LOCATION - Background location tracking
```

## Build Commands

### Option 1: APK Build (Release)
```bash
cd d:\work\capestart-user
flutter clean
flutter pub get
flutter build apk --release
```
**Output Location:** `build/app/outputs/flutter-apk/app-release.apk`

### Option 2: Bundle Build (Google Play)
```bash
flutter build appbundle --release
```
**Output Location:** `build/app/outputs/bundle/release/app-release.aab`

### Option 3: Debug Build
```bash
flutter run -v
```

### Option 4: Install and Run on Device
```bash
flutter run --release
```

## Build Configuration Files

### 1. AndroidManifest.xml ✅
**Location:** `android/app/src/main/AndroidManifest.xml`
**Status:** All permissions configured
**Features:**
- Location services (fine, coarse, background)
- Internet & network connectivity
- Camera access
- Storage access
- Phone state reading
- Bluetooth connectivity

### 2. build.gradle (App Level) ✅
**Location:** `android/app/build.gradle`
**Key Settings:**
- namespace: com.example.users
- compileSdk: Latest (API 34+)
- minSdk: API 21
- targetSdk: API 34

### 3. gradle.properties ✅
**Location:** `android/gradle.properties`
**Configuration:**
```properties
org.gradle.jvmargs=-Xmx4G -XX:MaxMetaspaceSize=2G
android.useAndroidX=true
android.enableJetifier=true
```

### 4. google-services.json ✅
**Location:** `android/app/google-services.json`
**Status:** Firebase configuration included
**Note:** Keep this file secure and don't commit sensitive keys

## Common Issues & Solutions

### Issue: "Gradle sync failed"
**Solution:**
```bash
flutter clean
flutter pub get
cd android
./gradlew clean
cd ..
flutter pub get
```

### Issue: "Permission Denied"
**Solution:**
- Run `flutter clean`
- Delete `android/.gradle` folder
- Run `flutter pub get` again

### Issue: "compileSdk version mismatch"
**Solution:**
- Update `android/app/build.gradle`:
```gradle
android {
    compileSdk = 34  // or latest API level
}
```

### Issue: "APK build fails with Firestore errors"
**Solution:**
- Ensure `google-services.json` is properly placed in `android/app/`
- Run `flutter clean` and rebuild

## Testing the Build

### Test APK Installation:
```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

### Check Permissions After Installation:
```bash
adb shell pm list permissions -g | grep -i "location\|camera\|storage"
```

### View App Logs:
```bash
adb logcat | grep "flutter"
```

## Signing Release APK

### Create Keystore (One-time):
```bash
keytool -genkey -v -keystore my-release-key.keystore -keyalg RSA -keysize 2048 -validity 10000 -alias my-key-alias
```

### Sign APK:
```bash
flutter build apk --release --split-per-abi
```

The app will use the signing key configured in your local properties.

## Deployment Checklist

- [ ] All permissions are declared in AndroidManifest.xml
- [ ] google-services.json is in android/app/
- [ ] Build is successful (flutter build apk --release)
- [ ] APK size is reasonable (< 100MB)
- [ ] All Firebase services are functional
- [ ] Location services are working
- [ ] No critical errors in logs
- [ ] Tested on Android 6.0+ device
- [ ] Privacy policy includes location tracking notice

## Useful Commands

```bash
# Clean everything
flutter clean && flutter pub get

# Build APK with verbose output
flutter build apk --release -v

# Check SDK versions
flutter doctor -v

# List installed devices
adb devices

# Clear app cache
adb shell pm clear com.example.users
```

## File Structure Overview

```
android/
├── app/
│   ├── build.gradle              ✅ Configured
│   ├── google-services.json      ✅ Firebase config
│   └── src/
│       └── main/
│           ├── AndroidManifest.xml    ✅ All permissions added
│           ├── java/
│           ├── kotlin/
│           └── res/
├── gradle/
│   └── wrapper/
├── build.gradle                  ✅ Configured
├── gradle.properties             ✅ Configured
└── local.properties              (Local SDK path)
```

## Next Steps

1. Run `flutter clean && flutter pub get`
2. Build APK: `flutter build apk --release`
3. Test on Android device: `flutter run --release`
4. Verify all features work (location, login, booking, etc.)
5. Deploy to Play Store as needed

## Support

For issues with:
- **Firebase:** Check google-services.json configuration
- **Location:** Verify geolocator permissions and device settings
- **Build:** Check gradle.properties and build.gradle
- **Runtime Permissions:** Test on Android 6.0+ device
