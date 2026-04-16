# Firebase Hosting - Deploy Admin & User Apps

## Current Status
- ✅ firebase.json configured with dual hosting targets (admin & user)
- ❌ No apps deployed yet (showing "Site Not Found")

## What You Need To Do

### Step 1: Build Admin App
```bash
# Navigate to admin project (if separate)
# OR build web version
flutter build web
```

This creates: `build/web/`

### Step 2: Build User App
```bash
# Build Flutter web version for user app
flutter build web
```

This creates: `build/web/`

### Step 3: Prepare Directories
Firebase expects:
- `admin_build/` - Contains admin app files
- `user_build/` - Contains user app files

Create these directories and copy build outputs:

```bash
# Create directories
mkdir admin_build
mkdir user_build

# Copy admin app build
xcopy build\web\* admin_build\ /E /I

# Copy user app build (if separate project)
xcopy build\web\* user_build\ /E /I
```

### Step 4: Deploy to Firebase
```bash
# Install Firebase CLI (if not already)
npm install -g firebase-tools

# Login to Firebase
firebase login

# Deploy to both targets
firebase deploy --only hosting:admin,hosting:user
```

Or deploy individually:
```bash
# Deploy only admin
firebase deploy --only hosting:admin

# Deploy only user
firebase deploy --only hosting:user
```

## Complete Deployment Script (Windows)

Create a file: `deploy.bat`

```batch
@echo off
echo.
echo ========================================
echo Firebase Hosting Deployment Script
echo ========================================
echo.

REM Check if firebase-tools is installed
firebase --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Firebase CLI not found. Installing...
    npm install -g firebase-tools
)

echo.
echo Step 1: Clean previous builds...
flutter clean

echo.
echo Step 2: Building web app...
flutter build web --release

echo.
echo Step 3: Creating deployment directories...
if exist admin_build rmdir /s /q admin_build
if exist user_build rmdir /s /q user_build

mkdir admin_build
mkdir user_build

echo.
echo Step 4: Copying build files...
xcopy build\web\* admin_build\ /E /I /Y
xcopy build\web\* user_build\ /E /I /Y

echo.
echo Step 5: Deploying to Firebase...
firebase deploy --only hosting:admin,hosting:user

echo.
echo ========================================
echo Deployment Complete!
echo ========================================
echo.
echo Admin URL: https://admin-app-d50b8.web.app
echo User URL: https://user-app-d50b8.web.app
echo.
pause
```

## Detailed Steps

### Option A: Manual Deployment

#### 1. Build Flutter Web
```bash
cd d:\work\capestart-user
flutter build web --release
```

Output: `build/web/` directory created

#### 2. Create Deployment Folders
```bash
# Windows Command Prompt
mkdir admin_build
mkdir user_build

# Copy build files
xcopy build\web\* admin_build\ /E /I /Y
xcopy build\web\* user_build\ /E /I /Y
```

#### 3. Install Firebase Tools
```bash
npm install -g firebase-tools
```

#### 4. Login to Firebase
```bash
firebase login
```

This opens a browser window for authentication.

#### 5. Deploy Both Targets
```bash
firebase deploy --only hosting:admin,hosting:user
```

### Option B: Separate Deployments

If you want to deploy apps separately:

```bash
# Deploy only admin
firebase deploy --only hosting:admin

# Deploy only user (after updating user_build files)
firebase deploy --only hosting:user
```

## Expected URLs After Deployment

```
Admin App: https://admin-app-d50b8.web.app
User App: https://user-app-d50b8.web.app
```

(Replace `d50b8` with your actual Firebase project ID)

## Directory Structure After Setup

```
d:\work\capestart-user\
├── admin_build/
│   ├── index.html
│   ├── main.dart.js
│   ├── assets/
│   └── ...
├── user_build/
│   ├── index.html
│   ├── main.dart.js
│   ├── assets/
│   └── ...
├── build/
│   └── web/
├── firebase.json (✅ Already configured)
├── deploy.bat (optional script)
└── ...
```

## firebase.json Configuration (Already Done ✅)

Your current configuration:

```json
{
  "hosting": [
    {
      "target": "admin",
      "public": "admin_build",
      "ignore": ["firebase.json", "**/.*", "**/node_modules/**"]
    },
    {
      "target": "user",
      "public": "user_build",
      "ignore": ["firebase.json", "**/.*", "**/node_modules/**"]
    }
  ],
  "flutter": { ... }
}
```

This tells Firebase:
- Look in `admin_build/` folder for admin app
- Look in `user_build/` folder for user app
- Ignore certain files during deployment

## Troubleshooting

### Error: "You haven't deployed an app yet"
**Cause:** The directories `admin_build/` or `user_build/` don't exist or are empty

**Fix:**
```bash
flutter build web --release
mkdir admin_build
mkdir user_build
xcopy build\web\* admin_build\ /E /I /Y
xcopy build\web\* user_build\ /E /I /Y
```

### Error: "Could not find firebase.json"
**Cause:** Running firebase CLI from wrong directory

**Fix:**
```bash
cd d:\work\capestart-user
firebase deploy
```

### Error: "Permission denied"
**Cause:** Not logged in to Firebase

**Fix:**
```bash
firebase login
```

### Error: "Cannot deploy to project"
**Cause:** Firebase project ID mismatch

**Fix:**
```bash
firebase projects:list
firebase use <project-id>
```

## Verify Deployment

After successful deployment:

```bash
# Check deployment status
firebase hosting:sites

# View deployment history
firebase hosting:channel:list

# Test admin app
start https://admin-app-d50b8.web.app

# Test user app
start https://user-app-d50b8.web.app
```

## Full Command Reference

```bash
# Initialize Firebase (one time)
firebase init hosting

# Login
firebase login

# Logout
firebase logout

# List projects
firebase projects:list

# Set active project
firebase use <project-id>

# Deploy all
firebase deploy

# Deploy only hosting
firebase deploy --only hosting

# Deploy only admin target
firebase deploy --only hosting:admin

# Deploy only user target
firebase deploy --only hosting:user

# View live site
firebase hosting:sites

# Check deployment
firebase hosting:channel:list
```

## Important Notes

1. **Same Build for Both Apps?**
   - If admin and user apps are the same, copying to both folders is fine
   - If different, build separately and copy respective builds

2. **Environment Variables**
   - Flutter web builds don't automatically use environment-specific configs
   - You may need separate web builds for admin vs user

3. **Performance**
   - First deployment takes 1-2 minutes
   - Subsequent deployments are faster (incremental)
   - Cache is cleared automatically

4. **Rollback**
   - Firebase keeps deployment history
   - You can rollback to previous versions via Firebase Console

## Next Steps

1. ✅ firebase.json is configured
2. 📝 Build web app: `flutter build web --release`
3. 📂 Create directories: `admin_build/` and `user_build/`
4. 📋 Copy build files to both directories
5. 🚀 Deploy: `firebase deploy --only hosting:admin,hosting:user`
6. ✔️ Visit URLs to verify

Your firebase.json is correctly set up! Now you just need to build and deploy the apps.
