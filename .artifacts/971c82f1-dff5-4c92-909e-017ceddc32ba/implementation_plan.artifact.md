# Implementation Plan - Institutional Branding Refresh

Update all naming-related details across the application to consistently use **"Deshmukh Coaching Institute"** instead of "DCI Teachers" or generic "DCI" placeholders.

## Proposed Changes

### [1. Global Constants & Configuration]

#### [MODIFY] [app_constants.dart](file:///A:/dci-latest/lib/backend/services/app_constants.dart)
- Update `instituteName` constant to "Deshmukh Coaching Institute".

#### [MODIFY] [config_repository.dart](file:///A:/dci-latest/lib/backend/repositories/config_repository.dart)
- Update default "DCI" prefix in `getNextEmployeeId` to "DESHMUKH".

### [2. App Metadata & Identity]

#### [MODIFY] [AndroidManifest.xml](file:///A:/dci-latest/android/app/src/main/AndroidManifest.xml)
- Update `android:label` to "Deshmukh Coaching Institute".

#### [MODIFY] [strings.xml](file:///A:/dci-latest/android/app/src/main/res/values/strings.xml)
- Update `app_name` string to "Deshmukh Coaching Institute".

#### [MODIFY] [Info.plist](file:///A:/dci-latest/ios/Runner/Info.plist)
- Update `CFBundleName` and `CFBundleDisplayName` to "Deshmukh Coaching Institute".

#### [MODIFY] [main.dart](file:///A:/dci-latest/lib/main.dart)
- Update MaterialApp `title` to "Deshmukh Coaching Institute".

### [3. UI Branding & Components]

#### [MODIFY] [responsive_scaffold.dart](file:///A:/dci-latest/lib/components/shared/responsive_scaffold.dart)
- Update sidebar brand text from "DCI ERP" to "Deshmukh ERP".

#### [MODIFY] [header_section_widget.dart](file:///A:/dci-latest/lib/components/header_section/header_section_widget.dart)
- Update fallback institute name to "Deshmukh Coaching Institute".

#### [MODIFY] [auth_header_widget.dart](file:///A:/dci-latest/lib/components/auth_header/auth_header_widget.dart)
- Update default app name and institute name labels.

#### [MODIFY] [ai_chat_widget.dart](file:///A:/dci-latest/lib/pages/ai_chat/ai_chat_widget.dart)
- Update "DCI AI Assistant" to "Deshmukh AI Assistant".
- Update mock AI response persona.

#### [MODIFY] [about_dci_widget.dart](file:///A:/dci-latest/lib/pages/about_dci/about_dci_widget.dart)
- Update title to "About Deshmukh Coaching Institute".
- Update app version label prefix.

### [4. Document Branding (PDFs & Reports)]

#### [MODIFY] [pdf_service.dart](file:///A:/dci-latest/lib/backend/services/pdf_service.dart)
- Update footers and report headers from "DCI Teachers" to "Deshmukh Coaching Institute".

#### [MODIFY] [announcements_feed_widget.dart](file:///A:/dci-latest/lib/pages/announcements_feed/announcements_feed_widget.dart)
- Update signature in shared messages from "DCI Team" to "Deshmukh Team".

## Verification Plan

### Visual Brand Audit
- Inspect Login, Dashboard, Sidebar, and About screens to ensure the full name is displayed correctly.
- Generate a sample PDF report to verify the updated branding in the document header/footer.

### System Verification
- Ensure the app title in the device's launcher is updated to "Deshmukh Coaching Institute".
