import '../../shared/app_style.dart';
import '../../shared/app_colors.dart';
import '../../components/shared/app_card.dart';
import '../../components/shared/app_section_header.dart';
import '/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/flutter_flow/flutter_flow_util.dart';

export 'settings_model.dart';

class SettingsWidget extends ConsumerStatefulWidget {
  const SettingsWidget({super.key});

  static String routeName = 'Settings';
  static String routePath = '/settings';

  @override
  ConsumerState<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends ConsumerState<SettingsWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.safePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const AppSectionHeader(title: 'Appearance'),
          const SizedBox(height: AppSpacing.md),
          _buildThemeToggle(),
          const SizedBox(height: AppSpacing.xl),
          const AppSectionHeader(title: 'Support & About'),
          const SizedBox(height: AppSpacing.md),
          _buildSettingsTile(
            icon: Icons.help_outline_rounded,
            title: 'Help Center',
            subtitle: 'FAQ and contact support',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'About App',
            subtitle: 'Version 1.0.8',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'How we handle your data',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggle() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: SwitchListTile.adaptive(
          value: isDarkMode,
          onChanged: (val) {
            final newMode = val ? ThemeMode.dark : ThemeMode.light;
            MyApp.of(context).setThemeMode(newMode);
          },
          activeColor: AppColors.accent,
          secondary: Icon(
            isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            color: AppColors.primary,
          ),
          title: Text('Dark Mode', style: Theme.of(context).textTheme.bodyLarge),
          subtitle: Text('Toggle app appearance', style: Theme.of(context).textTheme.labelSmall),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primary10,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                  Text(subtitle, style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
