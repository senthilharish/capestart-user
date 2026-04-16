# Android Build - Out of Memory Fix

## Error Description
```
../../runtime/vm/zone.cc: 96: error: Out of memory.
Failed to update packages.
Exit Code: -1073740791
```

## Root Cause
The Dart VM or Java/Gradle process is running out of available memory during the build process.

## Solutions Applied ✅

### 1. Increased JVM Memory (gradle.properties)
Updated settings:
```properties
# Old: 4GB JVM, 2GB Metaspace
org.gradle.jvmargs=-Xmx4G -XX:MaxMetaspaceSize=2G

# New: 8GB JVM, 3GB Metaspace (better for large projects)
org.gradle.jvmargs=-Xmx8G -XX:MaxMetaspaceSize=3G -XX:+HeapDumpOnOutOfMemoryError
```

### 2. Enabled Gradle Optimizations
```properties
# Parallel execution
org.gradle.parallel=true

# Build cache
org.gradle.caching=true

# Worker threads
org.gradle.workers.max=8
```

### 3. Split APK per Architecture
Build command optimized:
```bash
flutter build apk --split-per-abi --release
```

This creates:
- `app-arm64-v8a-release.apk` (64-bit, recommended)
- `app-armeabi-v7a-release.apk` (32-bit, older devices)

Much smaller files = less memory needed during build!

## Quick Fix Steps

### Option 1: Use the Batch Script (Windows)
```cmd
cd d:\work\capestart-user
build_apk.bat
```

This script:
1. Cleans previous builds
2. Gets dependencies
3. Builds with split-per-abi
4. Shows helpful error messages

### Option 2: Manual Build (Recommended)
```bash
cd d:\work\capestart-user

# Step 1: Clean
flutter clean

# Step 2: Get dependencies
flutter pub get

# Step 3: Build with split-per-abi
flutter build apk --split-per-abi --release
```

### Option 3: Build Single APK (if split fails)
```bash
flutter build apk --release
```

**Note:** This may use more memory but works on some systems.

## System Requirements

### Minimum
- RAM: 8GB
- Free Disk: 10GB
- Java: JDK 11+

### Recommended
- RAM: 16GB+
- Free Disk: 20GB+
- Java: JDK 17

## Memory Check Commands

### Check Available Memory
```bash
# Windows - using PowerShell
Get-ComputerInfo | Select CsSystemType, CsTotalPhysicalMemory
```

### Check Running Processes
```bash
# Windows Task Manager (Ctrl+Shift+Esc)
# Look for:
# - java.exe (Gradle)
# - dart.exe or dart SDK processes
# - Android SDK build tools
```

### Free Up Memory
```bash
# Close unnecessary applications
# Restart your computer
# Disable antivirus temporarily (if it's scanning files)
```

## gradle.properties Configuration

### Current Settings (Updated)
```properties
# Memory allocation - INCREASED
org.gradle.jvmargs=-Xmx8G -XX:MaxMetaspaceSize=3G -XX:+HeapDumpOnOutOfMemoryError

# Android X and Jetifier
android.useAndroidX=true
android.enableJetifier=true

# Performance optimizations
org.gradle.parallel=true
org.gradle.caching=true
org.gradle.workers.max=8
```

### If 8GB Still Fails
Try reducing slightly:
```properties
org.gradle.jvmargs=-Xmx6G -XX:MaxMetaspaceSize=2G
org.gradle.workers.max=4
```

## File Locations

```
Android configuration files:
- android/gradle.properties          ✅ UPDATED - Memory settings
- android/app/build.gradle           ✅ OK
- android/build.gradle               ✅ OK
- android/app/src/main/AndroidManifest.xml ✅ OK with all permissions
```

## Build Output Locations

After successful build, find APKs at:
```
build/app/outputs/flutter-apk/
├── app-arm64-v8a-release.apk       (Recommended - 64-bit)
├── app-armeabi-v7a-release.apk     (32-bit - legacy support)
└── app-release.apk                 (Universal - if --split-per-abi not used)
```

## Testing the Build

### Install on Device
```bash
# For 64-bit devices (most modern)
adb install -r build/app/outputs/flutter-apk/app-arm64-v8a-release.apk

# For 32-bit devices (older)
adb install -r build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
```

### Check Device Architecture
```bash
adb shell getprop ro.product.cpu.abi
```

Output: `arm64-v8a` (64-bit) or `armeabi-v7a` (32-bit)

## Troubleshooting Matrix

| Error | Cause | Solution |
|-------|-------|----------|
| Out of memory | Not enough RAM | Increase JVM memory, use --split-per-abi |
| Gradle sync failed | Gradle cache corrupted | Run `flutter clean`, delete `android/.gradle` |
| compileSdk mismatch | SDK not installed | Install Android SDK API level 34+ |
| Build canceled | Process killed | Free up RAM, close other apps |
| Firestore errors | google-services.json missing | Ensure file exists in android/app/ |

## Advanced: Custom JVM Settings

### For 16GB+ RAM Systems
```properties
org.gradle.jvmargs=-Xmx12G -XX:MaxMetaspaceSize=4G
org.gradle.parallel=true
org.gradle.caching=true
org.gradle.workers.max=12
```

### For 8GB RAM Systems
```properties
org.gradle.jvmargs=-Xmx6G -XX:MaxMetaspaceSize=2G
org.gradle.parallel=false
org.gradle.caching=false
org.gradle.workers.max=2
```

### For 4GB RAM Systems
```properties
org.gradle.jvmargs=-Xmx2G -XX:MaxMetaspaceSize=1G
org.gradle.parallel=false
org.gradle.caching=false
org.gradle.workers.max=1
```

## Next Steps

1. ✅ Updated gradle.properties with increased memory
2. ✅ Created build_apk.bat script for easy building
3. 📝 Run: `flutter clean && flutter pub get`
4. 🔨 Build: `flutter build apk --split-per-abi --release`
5. ✔️ Test: `adb install -r build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`

## Success Indicators

✅ Build command completes without errors
✅ APK files are created in build/app/outputs/flutter-apk/
✅ App installs successfully on Android device
✅ All features work (login, booking, location, etc.)

## Still Having Issues?

1. **Restart your computer** - Clears memory caches
2. **Disable antivirus** - It may be slowing down file access
3. **Check disk space** - Need at least 10GB free
4. **Update Flutter/Dart** - `flutter upgrade`
5. **Update Android SDK** - Check SDK Tools in Android Studio

Good luck! The build should succeed now. 🚀
