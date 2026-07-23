# Architecture & Module Specifications

This document outlines the architectural patterns and technical standards governing the DCI Teachers App.

## 🏛 Core Architecture

The application follows a **Layered Feature-First Architecture**, ensuring that logic related to specific modules (Attendance, Exams, etc.) remains cohesive and easy to navigate.

### Layers
1. **Data Layer**: Repositories (`lib/backend/repositories/`) that abstract Firestore and other external APIs.
2. **Domain Layer**: Pure Dart models and entities (`lib/backend/models/`).
3. **Presentation Layer**: 
   - **Widgets**: Reusable components (`lib/components/`) and full-screen pages (`lib/pages/`).
   - **Notifiers**: Riverpod `Notifier` classes (`lib/features/.../application/`) that manage UI state and interact with repositories.

## 🛠 State Management (Riverpod)

We use **Riverpod 2.0+** for all state management.
- **Providers**: Global access to services and configuration.
- **StreamProviders**: Real-time synchronization with Firestore collections.
- **Notifiers**: Encapsulate complex UI logic (e.g., Attendance selection, Exam result entry).

## 🔐 Security & RBAC

The app implements **Role-Based Access Control (RBAC)** via the `AccessControl` service.

### Roles
- **Director**: Full visibility of institute-wide data and financial/performance reports.
- **Admin**: Full management capabilities for users, students, and settings.
- **Teacher**: Restricted to assigned classes, attendance tracking, and reporting.

### Implementation
- Access is checked at the UI level (conditional rendering) and the service level (method protection).
- Firestore Rules are used to enforce these roles at the database level.

## 🎨 UI & Design System

### Design Tokens
- **Colors**: Defined in `lib/shared/app_colors.dart`. Use `AppColors` for consistency.
- **Spacing/Typography**: Centralized in `lib/shared/app_style.dart`.
- **Standard Radius**: All interactive elements (Inputs, Buttons) use `AppRadius.md` (12px).

### Responsiveness
- The app uses a `ResponsiveScaffold` that automatically switches between a Bottom Navigation Bar (Mobile) and a persistent Sidebar (Tablet/Desktop).
- Breakpoints are defined in `AppSpacing`.

## 📈 Performance & Quality

- **Error Handling**: Use the centralized `ErrorHandler.show()` for all user-facing errors.
- **Logging**: All administrative actions must be logged via the `AuditRepository`.
- **Validation**: Shared validation logic resides in `ValidationService`.
