import '/auth/firebase_auth/auth_util.dart';
import '/backend/providers/repository_providers.dart';
import '/components/profile_header/profile_header_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/backend/services/pdf_service.dart';
import '/shared/app_style.dart';
import '/shared/app_colors.dart';
import '/components/shared/app_card.dart';
import '/components/shared/app_button.dart';
import '/components/shared/app_section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

export 'teacher_profile_model.dart';

class TeacherProfileWidget extends ConsumerStatefulWidget {
  const TeacherProfileWidget({super.key});

  static String routeName = 'TeacherProfile';
  static String routePath = '/teacherProfile';

  @override
  ConsumerState<TeacherProfileWidget> createState() => _TeacherProfileWidgetState();
}

class _TeacherProfileWidgetState extends ConsumerState<TeacherProfileWidget> {
  late TeacherProfileModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TeacherProfileModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: AppColors.background,
        body: StreamBuilder<Map<String, dynamic>?>(
          stream: ref.watch(userRepositoryProvider).getUserStream(),
          builder: (context, snapshot) {
            final userData = snapshot.data;

            return CustomScrollView(
              slivers: [
                _buildSliverHeader(userData),
                SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildActionRow(context),
                      const SizedBox(height: AppSpacing.xl),
                      const AppSectionHeader(title: 'Personal Information'),
                      const SizedBox(height: AppSpacing.md),
                      _buildInfoGrid(context, userData),
                      const SizedBox(height: AppSpacing.xl),
                      const AppSectionHeader(title: 'Professional Details'),
                      const SizedBox(height: AppSpacing.md),
                      _buildProfessionalDetails(context, userData),
                      const SizedBox(height: AppSpacing.xl),
                      const AppSectionHeader(title: 'App Preferences'),
                      const SizedBox(height: AppSpacing.md),
                      _buildPreferencesCard(context, userData),
                      const SizedBox(height: AppSpacing.xl),
                      AppButton(
                        text: 'Logout',
                        variant: AppButtonVariant.outline,
                        icon: Icons.logout_rounded,
                        onPressed: () => _handleLogout(context),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSliverHeader(Map<String, dynamic>? userData) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => context.safePop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: ProfileHeaderWidget(
          designation: userData?['designation'] ?? 'Senior Faculty',
          name: userData?['display_name'] ?? currentUserDisplayName != '' ? currentUserDisplayName : 'Teacher',
          photoUrl: userData?['photo_url'] ?? currentUserPhoto,
        ),
      ),
    );
  }

  Widget _buildActionRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            text: 'Edit Profile',
            variant: AppButtonVariant.primary,
            icon: Icons.edit_rounded,
            onPressed: () => context.pushNamed(EditProfileWidget.routeName),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: AppButton(
            text: 'Export CV',
            variant: AppButtonVariant.secondary,
            icon: Icons.file_download_rounded,
            onPressed: () async {
              final userData = await ref.read(userRepositoryProvider).getUserData();
              if (userData != null) {
                await PdfService.generateTeacherCV(userData);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInfoGrid(BuildContext context, Map<String, dynamic>? userData) {
    return Column(
      children: [
        _buildInfoTile(context, Icons.email_outlined, 'Email', userData?['email'] ?? currentUserEmail),
        const SizedBox(height: AppSpacing.sm),
        _buildInfoTile(context, Icons.phone_outlined, 'Phone', userData?['phone_number'] ?? currentPhoneNumber),
        const SizedBox(height: AppSpacing.sm),
        _buildInfoTile(context, Icons.badge_outlined, 'Employee ID', userData?['employee_id'] ?? 'N/A'),
      ],
    );
  }

  Widget _buildProfessionalDetails(BuildContext context, Map<String, dynamic>? userData) {
    return AppCard(
      child: Column(
        children: [
          _buildDetailRow(context, 'Qualification', userData?['qualification'] ?? 'N/A'),
          const Divider(height: AppSpacing.xl),
          _buildDetailRow(context, 'Expertise', userData?['subject_expertise'] ?? 'N/A'),
          const Divider(height: AppSpacing.xl),
          _buildDetailRow(context, 'Experience', userData?['experience'] ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard(BuildContext context, Map<String, dynamic>? userData) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          SwitchListTile.adaptive(
            value: userData?['notifications_enabled'] ?? true,
            onChanged: (val) => ref.read(userRepositoryProvider).updateNotificationSettings(val),
            title: Text('Push Notifications', style: Theme.of(context).textTheme.bodyLarge),
            subtitle: Text('Receive alerts for school events', style: Theme.of(context).textTheme.bodySmall),
            activeColor: AppColors.accent,
          ),
          const Divider(height: 1),
          ListTile(
            onTap: () => context.pushNamed(SettingsWidget.routeName),
            title: Text('App Settings', style: Theme.of(context).textTheme.bodyLarge),
            trailing: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, IconData icon, String label, String value) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelSmall),
                Text(value, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to exit?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Logout', style: TextStyle(color: AppColors.error))
          ),
        ],
      ),
    ) ?? false;
    
    if (confirm) {
      await ref.read(authRepositoryProvider).signOut();
      if (!context.mounted) return;
      context.goNamed(LoginWidget.routeName);
    }
  }
}
