# Firebase Hosting Setup - Quick Start Guide

## The Error You're Seeing
```
"Site Not Found" - https://admin-app-d50b8.web.app
```

**Reason:** No app has been deployed to that URL yet.

## What's Already Done ✅
- firebase.json configured with dual hosting targets
- Admin target points to `admin_build/` directory
- User target points to `user_build/` directory

## What You Need To Do 🚀

### Option 1: Use the Deployment Script (Easiest)
```cmd
cd d:\work\capestart-user
deploy.bat
```

This script:
1. Builds Flutter web app
2. Creates admin_build & user_build folders
3. Copies files to both
4. Deploys to Firebase
5. Shows success confirmation

### Option 2: Manual Steps

#### Step 1: Build Web App
```bash
cd d:\work\capestart-user
flutter build web --release
```

#### Step 2: Create Deployment Folders
```bash
mkdir admin_build
mkdir user_build

# Copy build files
xcopy build\web\* admin_build\ /E /I /Y
xcopy build\web\* user_build\ /E /I /Y
```

#### Step 3: Install Firebase CLI
```bash
npm install -g firebase-tools
```

#### Step 4: Login to Firebase
```bash
firebase login
```

#### Step 5: Deploy Both Apps
```bash
firebase deploy --only hosting:admin,hosting:user
```

## Directory Structure After Deploy

```
d:\work\capestart-user\
├── admin_build/          ← Admin app files
│   ├── index.html
│   ├── main.dart.js
│   └── assets/
├── user_build/           ← User app files
│   ├── index.html
│   ├── main.dart.js
│   └── assets/
├── build/web/            ← Flutter build output
├── firebase.json         ✅ Configured
├── deploy.bat           ← Deployment script
└── ...
```

## Expected Result After Deployment

✅ Admin App:
```
https://admin-app-d50b8.web.app
```

✅ User App:
```
https://user-app-d50b8.web.app
```

Both should display your Flutter web app instead of "Site Not Found"

## Troubleshooting

### "Site Not Found" still showing?
- Wait a few minutes for deployment to propagate
- Clear browser cache (Ctrl+Shift+Delete)
- Try incognito/private window

### Build fails?
```bash
flutter clean
flutter pub get
flutter build web --release
```

### Firebase login fails?
```bash
firebase logout
firebase login
```

### Permission denied when copying files?
Make sure no file explorer windows have the folders open, then retry.

## Key Files

| File | Purpose | Status |
|------|---------|--------|
| firebase.json | Firebase config | ✅ Ready |
| deploy.bat | Deployment script | ✅ Ready |
| admin_build/ | Admin app folder | 📝 To create |
| user_build/ | User app folder | 📝 To create |

## Command Reference

```bash
# Build web
flutter build web --release

# Create folders
mkdir admin_build && mkdir user_build

# Copy files
xcopy build\web\* admin_build\ /E /I /Y
xcopy build\web\* user_build\ /E /I /Y

# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Deploy
firebase deploy --only hosting:admin,hosting:user

# Check status
firebase hosting:sites

# View live sites
firebase open hosting
```

## Next Steps

1. Run: `deploy.bat`
2. Wait for deployment to complete
3. Visit the URLs shown
4. Verify both apps are working

That's it! Your apps will be live on Firebase Hosting. 🚀
