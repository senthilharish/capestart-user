@echo off
REM Setup environment variables for optimal Dart/Flutter/Gradle performance
REM Run this before building APK to optimize system resources

echo.
echo ========================================
echo Flutter Build Environment Setup
echo ========================================
echo.

REM Set Dart VM options
set DART_VM_OPTIONS=-Xmx8g

REM Set Gradle options
set GRADLE_OPTS=-Xmx8g -XX:MaxMetaspaceSize=3g

REM Optional: Increase file watchers for large projects
REM set GRADLE_OPTS=%GRADLE_OPTS% -XX:+UnlockExperimentalVMOptions -XX:UseG1GC

echo.
echo Environment Variables Set:
echo ================================
echo DART_VM_OPTIONS: %DART_VM_OPTIONS%
echo GRADLE_OPTS: %GRADLE_OPTS%
echo.
echo Your system is now optimized for building.
echo.
echo Next, run one of these commands:
echo.
echo Option 1 (Recommended - Split APK):
echo   flutter build apk --split-per-abi --release
echo.
echo Option 2 (Single APK):
echo   flutter build apk --release
echo.
echo Or use the batch script:
echo   build_apk.bat
echo.

pause
