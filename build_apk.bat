@echo off
REM Android APK Build Script - Optimized for Memory
REM This script builds the Android APK with memory optimizations

echo.
echo ========================================
echo Android APK Build Script
echo ========================================
echo.

REM Check if flutter is installed
flutter --version
if %ERRORLEVEL% neq 0 (
    echo Error: Flutter is not installed or not in PATH
    pause
    exit /b 1
)

echo.
echo Step 1: Cleaning previous builds...
flutter clean
if %ERRORLEVEL% neq 0 (
    echo Error: Flutter clean failed
    pause
    exit /b 1
)

echo.
echo Step 2: Getting dependencies...
flutter pub get
if %ERRORLEVEL% neq 0 (
    echo Error: Pub get failed
    pause
    exit /b 1
)

echo.
echo Step 3: Building APK with split per ABI...
echo This will create separate APKs for arm64-v8a and armeabi-v7a architectures
echo.

REM Build with split per ABI to reduce memory usage
flutter build apk --split-per-abi --release -v

if %ERRORLEVEL% neq 0 (
    echo.
    echo ========================================
    echo Build Failed!
    echo ========================================
    echo.
    echo Error: APK build failed. Trying alternative method...
    echo.
    
    REM Try building without split if it fails
    echo Attempting single APK build (may use more memory)...
    flutter build apk --release -v
    
    if %ERRORLEVEL% neq 0 (
        echo.
        echo ========================================
        echo FATAL ERROR - Build Failed!
        echo ========================================
        echo.
        echo Troubleshooting steps:
        echo 1. Close other applications to free up RAM
        echo 2. Increase gradle.properties JVM memory settings
        echo 3. Restart your computer
        echo 4. Check that you have at least 8GB free RAM
        echo.
        pause
        exit /b 1
    )
)

echo.
echo ========================================
echo Build Successful!
echo ========================================
echo.
echo APK Location: build\app\outputs\flutter-apk\
echo.
echo Files created:
dir /B build\app\outputs\flutter-apk\*.apk 2>nul || echo (No files found)
echo.
echo Next steps:
echo 1. Install on device: adb install -r [apk-path]
echo 2. Or upload to Google Play Store
echo.
pause
