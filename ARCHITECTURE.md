# DCI Teachers App - Architecture & Module Specifications

## Overview
The DCI Teachers App is built using a **Feature-First Architecture** combined with **Riverpod** for state management and **Repository Pattern** for data access. This ensures a scalable, testable, and maintainable codebase.

## Directory Structure
- `lib/core/`: Global utilities, design system, and shared services.
- `lib/features/`: Feature-specific modules (e.g., attendance, reports).
  - `data/`: Repositories and data providers.
  - `domain/`: Business logic models and entities.
  - `presentation/`: Widgets, screens, and view models (providers).
- `lib/shared/`: Reusable UI components and global constants.

## Role-Based Access Control (RBAC)
The app supports three distinct roles:
1. **Admin**: Full access to user management, institute configuration, and all reports.
2. **Director**: View-only access to all institute-wide reports and analytics.
3. **Teacher**: Access to manage their specific classes, mark attendance, and submit daily reports.

## Data Access Layer
All Firestore interactions must be abstracted behind **Repositories**. Repositories are exposed via **Riverpod Providers**.
- **Direct Firestore calls in UI components are strictly prohibited.**
- Use `AsyncValue` for handling loading and error states in the UI.

## UI & Design System
- **Responsiveness**: Use `Expanded`, `Flexible`, `LayoutBuilder`, and `MediaQuery` to ensure the app works on all screen sizes.
- **Components**: Reusable components are located in `lib/components/shared/`.
- **Theme**: Centralized theme settings in `lib/shared/app_style.dart`.

## Error Handling & Logging
- Use `ErrorHandler.show()` for consistent user feedback.
- Audit logs are stored in the `audit_logs` collection in Firestore.
- Critical errors are logged in the `error_logs` collection.

## Form Validation
- Standardized validation patterns are available in `lib/backend/services/validation_service.dart`.
- Always use `GlobalKey<FormState>` for form validation before submission.
