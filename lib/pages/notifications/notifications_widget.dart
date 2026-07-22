import 'package:d_c_i_teacher_app/backend/providers/service_providers.dart';
import 'package:d_c_i_teacher_app/backend/models/notification_model.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/components/shared/app_empty_state.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:d_c_i_teacher_app/pages/notifications/notifications_model.dart';
export 'package:d_c_i_teacher_app/pages/notifications/notifications_model.dart';

class NotificationsWidget extends ConsumerStatefulWidget {
  const NotificationsWidget({super.key});

  static String routeName = 'Notifications';
  static String routePath = '/notifications';

  @override
  ConsumerState<NotificationsWidget> createState() => _NotificationsWidgetState();
}

class _NotificationsWidgetState extends ConsumerState<NotificationsWidget> {
  late NotificationsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NotificationsModel());
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
              title: 'Notifications',
              subtitle: 'Stay updated with school events',
              onBackPressed: () async => context.safePop(),
            ),
          ),
          Expanded(
            child: _buildNotificationsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    final theme = FlutterFlowTheme.of(context);
    return FutureBuilder<List<AppNotification>>(
      future: ref.read(notificationRepositoryProvider).getNotificationsStream().first,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final notifications = snapshot.data ?? [];
        if (notifications.isEmpty) {
          return AppEmptyState(
            icon: Icons.notifications_none_rounded,
            title: 'No notifications',
            description: 'We\'ll notify you when something important happens.',
            actionLabel: 'Refresh',
            onActionPressed: () => setState(() {}),
          );
        }

        return ListView.separated(
          padding: AppSpacing.pagePadding,
          itemCount: notifications.length,
          separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final item = notifications[index];
            return Dismissible(
              key: Key(item.id),
              direction: DismissDirection.endToStart,
              onDismissed: (_) {
                ref.read(dciNotificationServiceProvider).deleteNotification(item.id);
              },
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(Icons.delete_outline, color: Colors.white),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: item.isRead ? null : AppShadows.low,
                ),
                child: Material(
                  color: item.isRead 
                      ? theme.secondaryBackground 
                      : theme.primary.withAlpha(15),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      if (!item.isRead) {
                        ref.read(dciNotificationServiceProvider).markAsRead(item.id);
                      }
                    },
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: item.isRead 
                              ? theme.alternate 
                              : theme.primary.withAlpha(50),
                          width: 1.0,
                        ),
                      ),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: item.isRead 
                                  ? theme.primary.withAlpha(25)
                                  : theme.primary,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              _getIcon(item.type), 
                              color: item.isRead 
                                  ? theme.primary 
                                  : Colors.white, 
                              size: 20
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title, 
                                  style: AppTypography.body.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: theme.primaryText,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.body, 
                                  style: AppTypography.caption.copyWith(
                                    color: theme.secondaryText,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item.createdAt != null 
                                      ? dateTimeFormat('relative', item.createdAt)
                                      : 'Just now', 
                                  style: AppTypography.caption.copyWith(
                                    fontSize: 11,
                                    color: theme.secondaryText.withAlpha(150),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!item.isRead)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: theme.secondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'alert': return Icons.warning_amber_rounded;
      case 'reminder': return Icons.alarm_rounded;
      case 'system': return Icons.settings_suggest_rounded;
      default: return Icons.notifications_none_rounded;
    }
  }
}
