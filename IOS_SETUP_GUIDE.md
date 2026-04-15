# iOS Configuration Guide

## iOS Setup for CapeStart User App

### Step 1: Location Permissions

#### Add to `ios/Runner/Info.plist`

Open the file and add these keys inside the `<dict>` section:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to your location to provide better services.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs access to your location to provide better services.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>This app needs access to your location to provide better services.</string>
```

### Step 2: Firebase Setup

1. **Download GoogleService-Info.plist**
   - Go to Firebase Console
   - Select your project
   - Click "Project Settings"
   - Download `GoogleService-Info.plist`

2. **Add to Xcode**
   - Open `ios/Runner.xcworkspace` in Xcode
   - Right-click on "Runner" project in left panel
   - Select "Add Files to Runner"
   - Choose `GoogleService-Info.plist`
   - Ensure "Copy items if needed" is checked
   - Select Runner target

3. **Update Pod dependencies**
   ```bash
   cd ios
   pod install --repo-update
   cd ..
   ```

### Step 3: Run the App

```bash
flutter run -d ios
```

### Step 4: iOS Build Settings

Ensure the following in `ios/Podfile`:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
  end
end
```

### Troubleshooting iOS

**Issue: Pod dependencies fail to install**
```bash
cd ios
rm -rf Pods
rm Podfile.lock
pod install --repo-update
cd ..
flutter clean
flutter pub get
flutter run -d ios
```

**Issue: Location permission not working**
- Ensure Info.plist keys are correctly added
- Restart the app
- Go to Settings > Your App > Location and enable it

**Issue: Firebase configuration not found**
- Verify GoogleService-Info.plist is in correct location
- Run `flutter clean` and rebuild
- Check that file is part of Runner target in Xcode
