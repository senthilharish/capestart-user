@echo off
REM Firebase Hosting Deployment Script - Admin & User Apps
REM This script builds Flutter web and deploys to Firebase

echo.
echo ========================================
echo Firebase Hosting Deployment
echo ========================================
echo.

REM Check if we're in the right directory
if not exist "pubspec.yaml" (
    echo Error: pubspec.yaml not found!
    echo Please run this script from the project root directory.
    pause
    exit /b 1
)

REM Check if firebase-tools is installed
echo Checking Firebase CLI...
firebase --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo.
    echo Firebase CLI not found. Installing...
    call npm install -g firebase-tools
    if %ERRORLEVEL% neq 0 (
        echo Error: Failed to install Firebase CLI
        echo Please install Node.js first from https://nodejs.org
        pause
        exit /b 1
    )
)

echo.
echo Step 1: Cleaning previous builds...
call flutter clean

echo.
echo Step 2: Getting dependencies...
call flutter pub get

echo.
echo Step 3: Building Flutter web app (Release)...
call flutter build web --release

if %ERRORLEVEL% neq 0 (
    echo.
    echo Error: Flutter web build failed!
    pause
    exit /b 1
)

echo.
echo Step 4: Creating deployment directories...
if exist admin_build (
    echo Removing old admin_build directory...
    rmdir /s /q admin_build
)
if exist user_build (
    echo Removing old user_build directory...
    rmdir /s /q user_build
)

echo Creating new directories...
mkdir admin_build
mkdir user_build

echo.
echo Step 5: Copying build files to deployment directories...
echo Copying to admin_build...
xcopy build\web\* admin_build\ /E /I /Y >nul

echo Copying to user_build...
xcopy build\web\* user_build\ /E /I /Y >nul

if %ERRORLEVEL% neq 0 (
    echo Error: Failed to copy build files!
    pause
    exit /b 1
)

echo.
echo Step 6: Verifying Firebase authentication...
firebase auth:list >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo.
    echo Firebase login required!
    echo Starting login process...
    call firebase login
    if %ERRORLEVEL% neq 0 (
        echo Error: Firebase login failed!
        pause
        exit /b 1
    )
)

echo.
echo ========================================
echo Deployment Options
echo ========================================
echo.
echo 1. Deploy both (admin + user)
echo 2. Deploy only admin
echo 3. Deploy only user
echo 4. Cancel
echo.
set /p choice="Enter your choice (1-4): "

if "%choice%"=="1" (
    echo.
    echo Deploying both admin and user apps...
    call firebase deploy --only hosting:admin,hosting:user
) else if "%choice%"=="2" (
    echo.
    echo Deploying admin app only...
    call firebase deploy --only hosting:admin
) else if "%choice%"=="3" (
    echo.
    echo Deploying user app only...
    call firebase deploy --only hosting:user
) else if "%choice%"=="4" (
    echo Deployment cancelled.
    pause
    exit /b 0
) else (
    echo Invalid choice!
    pause
    exit /b 1
)

if %ERRORLEVEL% neq 0 (
    echo.
    echo Error: Deployment failed!
    pause
    exit /b 1
)

echo.
echo ========================================
echo Deployment Successful! ✓
echo ========================================
echo.

REM Get project ID for URLs
for /f "tokens=*" %%i in ('firebase projects:list --json ^| findstr projectId') do set PROJ=%%i

echo.
echo Your apps are now live:
echo.
echo Admin App: https://admin-app-d50b8.web.app
echo User App: https://user-app-d50b8.web.app
echo.
echo (Replace d50b8 with your Firebase project ID if different)
echo.
echo Next steps:
echo 1. Visit the URLs above to verify deployment
echo 2. Test all features on both apps
echo 3. Monitor Firebase Console for logs
echo.
pause
