# Deshmukh Teacher ERP

A high-performance Enterprise Resource Planning (ERP) application for Deshmukh Coaching Institute faculty. Built with Flutter and Firebase, this app streamlines academic management with a focus on efficiency, responsiveness, and AI-driven insights.

## ✨ Key Features

- **Multi-Role Access Control**: Tailored dashboards for Directors, Admins, and Teachers.
- **Smart Attendance**: Rapid student attendance tracking with automatic WhatsApp notifications for parents.
- **Academic Management**: Simplified homework assignments, exam scheduling, and bulk marks entry.
- **AI Assistant**: Built-in academic assistant for lesson planning and performance analysis.
- **Rich Analytics**: Deep insights into student performance and faculty activity.
- **Audit Logs**: Transparent tracking of all administrative actions.

## 🛠 Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (Cross-platform)
- **State Management**: [Riverpod](https://riverpod.dev/) (Modern & Testable)
- **Database & Auth**: [Firebase](https://firebase.google.com/) (Firestore, Auth, Storage)
- **Architecture**: Feature-First + Repository Pattern

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Firebase CLI (for rules deployment)

### Deployment

#### Android
1. **Keystore**: Place your release keystore in `android/app/`.
2. **Configuration**: Create `android/key.properties` with your signing credentials.
3. **Build**: 
   ```bash
   flutter build apk --release
   # or for Play Store
   flutter build appbundle --release
   ```

#### iOS
1. **Signing**: Open `ios/Runner.xcworkspace` in Xcode.
2. **Team**: Select your development team in "Signing & Capabilities".
3. **Build**: `flutter build ipa --release`

## 📊 Project Configuration
- **Package Name**: `com.dciteacherapp`
- **Version**: 1.0.4+6
- **Target SDK**: 35 (Android) / 14.0 (iOS)
- **Min SDK**: 23 (Android) / 13.0 (iOS)
