import '/components/header_section/header_section_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'settings_model.dart';
export 'settings_model.dart';

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
              padding: const EdgeInsets.all(24.0),
              children: [
                _buildSectionHeader('Appearance'),
                _buildThemeToggle(),
                const SizedBox(height: 24),
                _buildSectionHeader('Account & Notifications'),
                _buildSettingsTile(
                  Icons.notifications_active_outlined,
                  'Push Notifications',
                  'Enable or disable app alerts',
                  trailing: Switch.adaptive(
                    value: true,
                    onChanged: (val) {},
                    activeTrackColor: FlutterFlowTheme.of(context).primary,
                  ),
                ),
                const SizedBox(height: 24),
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
                  'Version 1.0.5',
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
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: FlutterFlowTheme.of(context).labelMedium.override(
              font: GoogleFonts.inter(fontWeight: FontWeight.bold),
              color: FlutterFlowTheme.of(context).primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildThemeToggle() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: FlutterFlowTheme.of(context).alternate),
      ),
      child: ListTile(
        leading: Icon(
          isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
          color: FlutterFlowTheme.of(context).primary,
        ),
        title: Text('Dark Mode', style: FlutterFlowTheme.of(context).bodyLarge),
        subtitle: Text(
          isDarkMode ? 'Currently using dark theme' : 'Currently using light theme',
          style: FlutterFlowTheme.of(context).labelSmall,
        ),
        trailing: Switch.adaptive(
          value: isDarkMode,
          onChanged: (val) {
            final newMode = val ? ThemeMode.dark : ThemeMode.light;
            MyApp.of(context).setThemeMode(newMode);
          },
          activeTrackColor: FlutterFlowTheme.of(context).primary,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String subtitle,
      {Widget? trailing, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: FlutterFlowTheme.of(context).alternate),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: FlutterFlowTheme.of(context).secondaryText),
        title: Text(title, style: FlutterFlowTheme.of(context).bodyLarge),
        subtitle: Text(subtitle, style: FlutterFlowTheme.of(context).labelSmall),
        trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
