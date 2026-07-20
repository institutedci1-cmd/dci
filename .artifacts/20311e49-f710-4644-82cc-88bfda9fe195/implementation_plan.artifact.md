# Implementation Plan: Restrict Faculty Detail Updates to Admin Only

The goal is to ensure that only administrators (Admin and potentially Director) can update faculty details, preventing regular faculty members from editing their own professional profiles.

## User Review Required

> [!IMPORTANT]
> This change will prevent regular teachers from editing their own profiles (including name, designation, and expertise). Only users with the 'Admin' or 'Director' role will be able to perform these updates.

## Proposed Changes

### [UI Layer]

#### [MODIFY] [teacher_profile_widget.dart](file:///A:/dci-latest/lib/pages/teacher_profile/teacher_profile_widget.dart)
- Update `_buildActionButtons` to restrict the `canEdit` logic. It should only return true if the current user's role is 'Admin' or 'Director', regardless of whether they are viewing their own profile or someone else's.

#### [MODIFY] [edit_profile_widget.dart](file:///A:/dci-latest/lib/pages/edit_profile/edit_profile_widget.dart)
- Add a check in `initState` or `_loadUserData` to verify if the current user has permission to edit.
- If not, redirect back or show an error state. (Redirection to profile is safer).
- *Optional*: Disable the "Save Changes" button if the user is not an Admin/Director.

## Verification Plan

### Manual Verification
1. **Login as Teacher**:
   - Navigate to "My Profile".
   - Verify that the "Edit Profile" button is **NOT** visible.
2. **Login as Admin**:
   - Navigate to "My Profile".
   - Verify that the "Edit Profile" button **IS** visible.
   - Navigate to "Faculty Directory" -> Select another teacher.
   - Verify that the "Edit Profile" button **IS** visible for their profile.
3. **Login as Director**:
   - Verify that the "Edit Profile" button **IS** visible.
