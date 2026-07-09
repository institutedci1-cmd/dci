import '/auth/firebase_auth/auth_util.dart';
import '/backend/models/daily_report.dart';
import '/backend/providers/repository_providers.dart';
import '/components/dashboard_card/dashboard_card_widget.dart';
import '/components/recent_activity_item/recent_activity_item_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/shared/app_style.dart';
import '/shared/app_colors.dart';
import '/components/shared/app_card.dart';
import '/components/shared/app_section_header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

export 'home_dashboard_model.dart';

class HomeDashboardWidget extends ConsumerStatefulWidget {
  const HomeDashboardWidget({super.key});

  static String routeName = 'HomeDashboard';
  static String routePath = '/homeDashboard';

  @override
  ConsumerState<HomeDashboardWidget> createState() => _HomeDashboardWidgetState();
}

class _HomeDashboardWidgetState extends ConsumerState<HomeDashboardWidget> {
  late HomeDashboardModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeDashboardModel());
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
        body: currentUserUid.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUserUid)
                    .snapshots(),
                builder: (context, userSnapshot) {
                  final userData = userSnapshot.data?.data() as Map<String, dynamic>?;

                  return CustomScrollView(
                    slivers: [
                      _buildSliverAppBar(context, userData),
                      SliverPadding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            const AppSectionHeader(
                              title: 'Management Modules',
                              subtitle: 'Quick access to school operations',
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _buildModulesGrid(context),
                            const SizedBox(height: AppSpacing.xl),
                            _buildRecentActivitySection(context),
                            const SizedBox(height: AppSpacing.xl),
                            _buildAIHelpSection(context),
                            const SizedBox(height: AppSpacing.xxl),
                          ]),
                        ),
                      ),
                    ],
                  );
                },
              ),
        bottomNavigationBar: _buildBottomNavBar(context),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, Map<String, dynamic>? userData) {
    final theme = Theme.of(context);
    
    return SliverAppBar(
      expandedHeight: 140.0,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: AppColors.primary,
          child: Stack(
            children: [
              // Subtle background pattern or circles could go here for "Premium" feel
              Positioned(
                right: -20,
                top: -20,
                child: CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.white.withOpacity(0.03),
                ),
              ),
            ],
          ),
        ),
        titlePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back,',
              style: theme.textTheme.labelSmall?.copyWith(color: Colors.white70),
            ),
            Text(
              userData?['display_name'] ?? currentUserDisplayName != '' ? currentUserDisplayName : 'Teacher',
              style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      actions: [
        _buildNotificationAction(context),
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Colors.white),
          onPressed: () async {
            await ref.read(authRepositoryProvider).signOut();
            if (!context.mounted) return;
            context.goNamed(LoginWidget.routeName);
          },
        ),
        const SizedBox(width: AppSpacing.sm),
      ],
    );
  }

  Widget _buildNotificationAction(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
          onPressed: () => context.pushNamed(NotificationsWidget.routeName),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: StreamBuilder<int>(
            stream: ref.read(notificationRepositoryProvider).getUnreadCountStream(),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              if (count == 0) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  count > 9 ? '9+' : count.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildModulesGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.4,
      children: const [
        DashboardCardWidget(
          target: 'DailyReport',
          title: 'Daily Report',
          icon: Icon(Icons.assessment_rounded),
        ),
        DashboardCardWidget(
          target: 'Attendance',
          title: 'Attendance',
          icon: Icon(Icons.fact_check_rounded),
        ),
        DashboardCardWidget(
          target: 'Homework',
          title: 'Homework',
          icon: Icon(Icons.edit_note_rounded),
        ),
        DashboardCardWidget(
          target: 'Students',
          title: 'Students',
          icon: Icon(Icons.people_rounded),
        ),
        DashboardCardWidget(
          target: 'Announcements',
          title: 'Notices',
          icon: Icon(Icons.campaign_rounded),
        ),
        DashboardCardWidget(
          target: 'TeacherProfile',
          title: 'My Profile',
          icon: Icon(Icons.person_rounded),
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: 'Recent Activity',
          action: TextButton(
            onPressed: () => context.pushNamed(ReportHistoryWidget.routeName),
            child: const Text('View All'),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        StreamBuilder<List<DailyReport>>(
          stream: ref.read(dailyReportRepositoryProvider).getRecentReports(limit: 3),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final reports = snapshot.data ?? [];
            if (reports.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Center(
                  child: Text('No recent activity found.', style: Theme.of(context).textTheme.bodySmall),
                ),
              );
            }
            return Column(
              children: reports.map((report) {
                return RecentActivityItemWidget(
                  title: '${report.className} - ${report.subject}',
                  subtitle: 'Topic: ${report.chapter} • ${dateTimeFormat('yMMMd', report.createdAt)}',
                  onTap: () => context.pushNamed(ReportHistoryWidget.routeName),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAIHelpSection(BuildContext context) {
    return AppCard(
      onTap: () {}, // Link to AI help
      color: AppColors.accent.withOpacity(0.05),
      border: const BorderSide(color: AppColors.accent, width: 0.5),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Deshmukh AI Assistant', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.accent)),
                Text('Get help with lesson planning or data analysis.', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.accent),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.outline, width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavBarItem(context, Icons.home_rounded, 'Home', true, () {}),
              _buildNavBarItem(context, Icons.description_outlined, 'Reports', false, () => context.goNamed(ReportsDashboardWidget.routeName)),
              _buildNavBarItem(context, Icons.event_note_outlined, 'Attend.', false, () => context.goNamed(AttendanceDashboardWidget.routeName)),
              _buildNavBarItem(context, Icons.account_circle_outlined, 'Profile', false, () => context.goNamed(TeacherProfileWidget.routeName)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavBarItem(BuildContext context, IconData icon, String label, bool isSelected, VoidCallback onTap) {
    final color = isSelected ? AppColors.accent : AppColors.textTertiary;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
