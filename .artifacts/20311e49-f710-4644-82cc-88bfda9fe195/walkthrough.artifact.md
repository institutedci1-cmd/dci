# Walkthrough: Admin-Only Faculty Updates

I have restricted the ability to update faculty details to users with 'Admin' or 'Director' roles. Regular teachers can no longer edit their own profile information.

## Changes Made

### 1. Profile Visibility Logic
- **File**: [teacher_profile_widget.dart](file:///A:/dci-latest/lib/pages/teacher_profile/teacher_profile_widget.dart)
- **Change**: Updated the `canEdit` flag to strictly check the current user's role. The "Edit Profile" button is now hidden if the user's role is not 'Admin' or 'Director', even when viewing their own profile.

### 2. Access Control in Edit Screen
- **File**: [edit_profile_widget.dart](file:///A:/dci-latest/lib/pages/edit_profile/edit_profile_widget.dart)
- **Change**: Added a security check in `_loadUserData`. If a user manages to navigate to the edit screen (e.g., via a direct link or deep link) and is not an Admin/Director, they are immediately shown an "Access Denied" message and redirected back to the profile page.

## Verification Results

### Manual Verification
- **As Teacher**: Logged in and confirmed the "Edit Profile" button is gone from the profile screen.
- **As Admin**: Logged in and confirmed the "Edit Profile" button is visible for both their own profile and other faculty members' profiles.
- **Security**: Hard-redirect confirmed for unauthorized role types attempting to load the edit view.
