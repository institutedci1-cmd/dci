# Implementation Plan - Functional Module Modernization (Phase 7)

Following the successful optimization of Students and Attendance, this plan covers the refactoring of the remaining core modules (Homework, Announcements, and Exams) to the modern Riverpod **AsyncNotifier** pattern.

## User Review Required

> [!IMPORTANT]
> This refactor will move logic from the UI (WidgetState) into dedicated logic controllers (Notifiers). This makes the code more testable and prevents UI "stutter" during heavy operations like file uploads or marks calculations.

## Proposed Changes

### 1. Homework Assignment Modernization
- **[NEW] [homework_assignment_notifier.dart](file:///A:/dci-latest/lib/features/homework/application/homework_assignment_notifier.dart)**:
    - Create a notifier to manage class/subject selection, file uploads, and final submission.
    - Centralize form validation logic.
- **[MODIFY] [homework_assignment_widget.dart](file:///A:/dci-latest/lib/pages/homework_assignment/homework_assignment_widget.dart)**:
    - Bind the UI to the new `homeworkAssignmentNotifierProvider`.
    - Simplify file picking and status management.

### 2. Notice Board (Announcements) Refactoring
- **[NEW] [announcements_notifier.dart](file:///A:/dci-latest/lib/features/announcement/application/announcements_notifier.dart)**:
    - Create a notifier to handle fetching notices and the "Post Announcement" flow.
- **[MODIFY] [announcements_feed_widget.dart](file:///A:/dci-latest/lib/pages/announcements_feed/announcements_feed_widget.dart)**:
    - Simplify the building of the list and the modal bottom sheet using the new notifier.

### 3. Exams & Marks Logic Optimization
- **[NEW] [marks_entry_notifier.dart](file:///A:/dci-latest/lib/features/exams/application/marks_entry_notifier.dart)**:
    - Create a specialized notifier for `EnterMarksWidget` to handle marks parsing, grade calculation, and batch saving.
- **[MODIFY] [enter_marks_widget.dart](file:///A:/dci-latest/lib/pages/exams/enter_marks_widget.dart)**:
    - Replace imperative state management with the new logic controller.

## Verification Plan

### Automated Logic Check
- Verify that **Grade Calculation** (A, B, C, etc.) is consistent across the new notifier.
- Ensure **File Upload** state correctly updates the UI during homework assignment.

### Manual Verification
- Test "Save Draft" vs "Publish" in the Homework module.
- Post a new Notice and verify it appears immediately in the feed without manual refresh.
- Enter marks for a class and confirm they are correctly recorded in Firestore.
