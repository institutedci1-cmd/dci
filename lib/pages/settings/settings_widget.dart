import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:d_c_i_teacher_app/core/services/access_control.dart';
import 'package:d_c_i_teacher_app/pages/institute_settings/institute_settings_widget.dart';
import 'package:d_c_i_teacher_app/pages/audit_logs/audit_logs_widget.dart';
import 'package:d_c_i_teacher_app/pages/settings/settings_model.dart';
export 'package:d_c_i_teacher_app/pages/settings/settings_model.dart';

class SettingsWidget extends ConsumerStatefulWidget {
  const SettingsWidget({super.key});

  static String routeName = 'Settings';
  static String routePath = '/settings';

  @override
  ConsumerState<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends ConsumerState<SettingsWidget> {
  late SettingsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SettingsModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: Column(
        children: [
          wrapWithModel(
            model: createModel(context, () => HeaderSectionModel()),
            updateCallback: () => safeSetState(() {}),
            child: HeaderSectionWidget(
              title: 'Settings',
              subtitle: 'App preferences and info',
              onBackPressed: () async => context.safePop(),
            ),
          ),
          Expanded(
            child: ListView(
              padding: AppSpacing.pagePadding,
              children: [
                if (ref.watch(accessControlProvider).canViewAdminReports) ...[
                  _buildSectionHeader('Institutional Management'),
                  if (ref.watch(accessControlProvider).canManageFullSettings)
                    _buildSettingsTile(
                      Icons.account_balance_rounded,
                      'Institute Setup',
                      'Configure name, logo, and subjects',
                      onTap: () => context.pushNamed(InstituteSettingsWidget.routeName),
                    ),
                  _buildSettingsTile(
                    Icons.history_rounded,
                    'System Audit Logs',
                    'Track platform actions and updates',
                    onTap: () => context.pushNamed(AuditLogsWidget.routeName),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                _buildSectionHeader('Appearance'),
                _buildThemeToggle(),
                const SizedBox(height: AppSpacing.lg),
                _buildSectionHeader('Account & Notifications'),
                _buildSettingsTile(
                  Icons.notifications_active_outlined,
                  'Push Notifications',
                  'Enable or disable app alerts',
                  trailing: Switch.adaptive(
                    value: true,
                    onChanged: (val) {},
                    activeTrackColor: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildSectionHeader('Support'),
                _buildSettingsTile(
                  Icons.help_outline_rounded,
                  'Help Center',
                  'FAQ and contact support',
                  onTap: () {},
                ),
                _buildSettingsTile(
                  Icons.info_outline_rounded,
                  'About App',
                  'Version 1.0.2',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(
        title,
        style: AppTypography.label.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildThemeToggle() {
    final theme = FlutterFlowTheme.of(context);
    final themeMode = MyApp.of(context).themeMode;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: theme.alternate),
        boxShadow: AppShadows.low,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  themeMode == ThemeMode.dark ? Icons.dark_mode_rounded : (themeMode == ThemeMode.light ? Icons.light_mode_rounded : Icons.settings_suggest_rounded),
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('App Theme', style: AppTypography.body.copyWith(fontWeight: FontWeight.bold)),
                  Text(
                    themeMode == ThemeMode.system ? 'Using system settings' : 'Currently in ${themeMode.name} mode',
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('Light'),
                  icon: Icon(Icons.light_mode_rounded, size: 18),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('Dark'),
                  icon: Icon(Icons.dark_mode_rounded, size: 18),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('System'),
                  icon: Icon(Icons.settings_suggest_rounded, size: 18),
                ),
              ],
              selected: {themeMode},
              onSelectionChanged: (newSelection) {
                MyApp.of(context).setThemeMode(newSelection.first);
              },
              showSelectedIcon: false,
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                side: WidgetStateProperty.all(BorderSide(color: theme.alternate)),
                backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.primary;
                    }
                    return theme.secondaryBackground;
                  },
                ),
                foregroundColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    return AppColors.textSecondary;
                  },
                ),
                textStyle: WidgetStateProperty.all(AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String subtitle,
      {Widget? trailing, VoidCallback? onTap}) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: theme.alternate),
        boxShadow: AppShadows.low,
      ),
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Icon(icon, color: AppColors.textSecondary, size: 24),
          title: Text(title, style: AppTypography.body.copyWith(fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle, style: AppTypography.caption),
          trailing: trailing ?? Icon(Icons.chevron_right_rounded, color: theme.secondaryText),
        ),
      ),
    );
  }
}
