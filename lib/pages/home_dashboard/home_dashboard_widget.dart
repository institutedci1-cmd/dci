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

        bottomNavigationBar: _buildBottomNavBar(context),

        body: SafeArea(
          child: currentUserUid.isEmpty
              ? const Center(
            child: CircularProgressIndicator(),
          )
              : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(currentUserUid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final userData = snapshot.data?.data();

              return Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    // Header
                    _buildDashboardHeader(
                      context,
                      userData,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Six Modules
                    _buildModulesGrid(context),

                    const SizedBox(height: AppSpacing.lg),

                    // Recent Activity
                    Expanded(
                      child: _buildRecentActivitySection(context),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // AI Card
                    _buildAIHelpSection(context),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardHeader(
      BuildContext context,
      Map<String, dynamic>? userData,
      ) {
    final displayName =
    (userData?['display_name'] as String?)
        ?.trim()
        .isNotEmpty ==
        true
        ? userData!['display_name']
        : (currentUserDisplayName.isNotEmpty
        ? currentUserDisplayName
        : 'Teacher');

    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [

                Text(
                  'Welcome',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  displayName.toString(),
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                    color: Colors.white,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Stack(
            children: [

              IconButton(
                onPressed: () {
                  context.pushNamed(
                    NotificationsWidget.routeName,
                  );
                },
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                ),
              ),

            ],
          ),

          IconButton(
            onPressed: () async {

              await ref
                  .read(authRepositoryProvider)
                  .signOut();

              if (!context.mounted) return;

              context.goNamed(
                LoginWidget.routeName,
              );
            },
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
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
    return const SizedBox(
      height: 300,
      child: Column(
        children: [

          Expanded(
            child: Row(
              children: [

                Expanded(
                  child: DashboardCardWidget(
                    target: 'DailyReport',
                    title: 'Daily Report',
                    icon: Icon(Icons.assessment_rounded),
                  ),
                ),

                SizedBox(width: AppSpacing.md),

                Expanded(
                  child: DashboardCardWidget(
                    target: 'Attendance',
                    title: 'Attendance',
                    icon: Icon(Icons.fact_check_rounded),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: AppSpacing.md),

          Expanded(
            child: Row(
              children: [

                Expanded(
                  child: DashboardCardWidget(
                    target: 'Homework',
                    title: 'Homework',
                    icon: Icon(Icons.edit_note_rounded),
                  ),
                ),

                SizedBox(width: AppSpacing.md),

                Expanded(
                  child: DashboardCardWidget(
                    target: 'Students',
                    title: 'Students',
                    icon: Icon(Icons.people_rounded),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: AppSpacing.md),

          Expanded(
            child: Row(
              children: [

                Expanded(
                  child: DashboardCardWidget(
                    target: 'Announcements',
                    title: 'Notices',
                    icon: Icon(Icons.campaign_rounded),
                  ),
                ),

                SizedBox(width: AppSpacing.md),

                Expanded(
                  child: DashboardCardWidget(
                    target: 'TeacherProfile',
                    title: 'My Profile',
                    icon: Icon(Icons.person_rounded),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outline.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [

                Text(
                  'Recent Activity',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                TextButton(
                  onPressed: () {
                    context.pushNamed(
                      ReportHistoryWidget.routeName,
                    );
                  },
                  child: const Text('View All'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Expanded(
              child: StreamBuilder<List<DailyReport>>(
                stream: ref
                    .read(dailyReportRepositoryProvider)
                    .getRecentReports(limit: 2),
                builder: (context, snapshot) {

                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Unable to load reports',
                      ),
                    );
                  }

                  final reports = snapshot.data ?? [];

                  if (reports.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          Icon(
                            Icons.history,
                            size: 42,
                            color: Colors.grey,
                          ),

                          SizedBox(height: 12),

                          Text(
                            'No recent activity',
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    physics:
                    const NeverScrollableScrollPhysics(),
                    itemCount: reports.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(height: 8),
                    itemBuilder: (context, index) {

                      final report = reports[index];

                      return RecentActivityItemWidget(
                        title:
                        '${report.className} • ${report.subject}',

                        subtitle:
                        report.chapter,

                        onTap: () {
                          context.pushNamed(
                            ReportHistoryWidget
                                .routeName,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIHelpSection(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // TODO: AI Assistant
        },
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withOpacity(.15),
            ),
          ),
          child: Row(
            children: [

              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [

                    Text(
                      'DCI AI Assistant',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      'Lesson plans, homework & reports',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall,
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return NavigationBar(
      height: 64,
      selectedIndex: 0,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            break;
          case 1:
            context.goNamed(ReportsDashboardWidget.routeName);
            break;
          case 2:
            context.goNamed(AttendanceDashboardWidget.routeName);
            break;
          case 3:
            context.goNamed(TeacherProfileWidget.routeName);
            break;
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.description_outlined),
          selectedIcon: Icon(Icons.description),
          label: 'Reports',
        ),
        NavigationDestination(
          icon: Icon(Icons.event_note_outlined),
          selectedIcon: Icon(Icons.event_note),
          label: 'Attend',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
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
