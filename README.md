# RecallPro — ARVION

A Flutter Android reminder app prototype with local persistence and scheduled notifications.

## Features
- Add, edit, delete reminders
- Mark reminders done/active
- Normal and Emergency priority
- Daily / weekly / monthly repeating reminders
- Local persistence with SharedPreferences
- Scheduled Android notifications
- Separate normal/emergency notification channels
- Day / Night mode
- Settings sheet
- Google Sign-In entry point
- ARVION branding

## Run on Windows
1. Install Flutter and Android tooling.
2. Extract this folder.
3. Open Command Prompt in the project folder.
4. Run:

```text
flutter pub get
flutter run
```

Or double-click `SETUP_WINDOWS.bat`.

## Build APK

```text
flutter pub get
flutter build apk --release
```

The APK is normally created under `build/app/outputs/flutter-apk/`.

## Important
This package contains the Flutter application source and Android platform files, but Flutter's generated Gradle wrapper/cache files are intentionally not bundled. The Flutter CLI creates/uses those files when the project is run or built.

Google Sign-In requires your own Android OAuth configuration (package: `com.arvion.recallpro`) and signing-key SHA fingerprints.

Android notification sound/vibration can still be restricted by the user's system settings. Emergency mode uses a separate maximum-importance channel and a stronger vibration pattern; an app cannot guarantee overriding system-level settings.
