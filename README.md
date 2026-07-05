# Deshmukh Teacher App

A Flutter project designed for teachers at Deshmukh Coaching Institute.

## Deployment Guide

### Android
1. **Keystore**: Create a release keystore and place it in a secure location.
2. **Configuration**: Create `android/key.properties` (use `android/key.properties.example` as a template) and fill in your keystore details.
3. **Build**: Run `flutter build apk --release` or `flutter build appbundle --release`.

### iOS
1. **Signing**: Open `ios/Runner.xcworkspace` in Xcode and configure your Development Team in the "Signing & Capabilities" tab.
2. **Build**: Run `flutter build ipa --release`.

### Firebase
1. Ensure the Firebase Project ID in `lib/backend/firebase/firebase_config.dart` matches your production project.
2. Deploy Firestore rules and indexes using `firebase deploy --only firestore`.

## Project Configuration
- **Package Name**: `com.dciteacherapp`
- **Target SDK**: 35 (Android)
- **Min SDK**: 23 (Android) / 13.0 (iOS)
