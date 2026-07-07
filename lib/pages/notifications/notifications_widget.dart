import '/backend/models/notification_model.dart';
import '/backend/providers/repository_providers.dart';
import '/components/header_section/header_section_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'notifications_model.dart';
export 'notifications_model.dart';

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
    return FutureBuilder<List<AppNotification>>(
      future: ref.read(notificationRepositoryProvider).getNotificationsStream().first,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final notifications = snapshot.data ?? [];
        if (notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_none_rounded, size: 64, color: FlutterFlowTheme.of(context).alternate),
                const SizedBox(height: 16),
                Text('No notifications yet', style: FlutterFlowTheme.of(context).labelLarge),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(24.0),
          itemCount: notifications.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final item = notifications[index];
            return Dismissible(
              key: Key(item.id),
              direction: DismissDirection.endToStart,
              onDismissed: (_) {
                ref.read(notificationRepositoryProvider).deleteNotification(item.id);
              },
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).error,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.delete_outline, color: Colors.white),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: item.isRead 
                      ? FlutterFlowTheme.of(context).secondaryBackground 
                      : FlutterFlowTheme.of(context).primary10.applyAlpha(0.05),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: item.isRead 
                        ? FlutterFlowTheme.of(context).alternate 
                        : FlutterFlowTheme.of(context).primary,
                    width: item.isRead ? 1.0 : 1.5,
                  ),
                ),
                child: ListTile(
                  onTap: () {
                    if (!item.isRead) {
                      ref.read(notificationRepositoryProvider).markAsRead(item.id);
                    }
                  },
                  leading: CircleAvatar(
                    backgroundColor: item.isRead 
                        ? FlutterFlowTheme.of(context).primary10 
                        : FlutterFlowTheme.of(context).primary,
                    child: Icon(
                      _getIcon(item.type), 
                      color: item.isRead 
                          ? FlutterFlowTheme.of(context).primary 
                          : Colors.white, 
                      size: 20
                    ),
                  ),
                  title: Text(item.title, style: FlutterFlowTheme.of(context).bodyLarge.override(
                    font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                    fontWeight: FontWeight.bold,
                  )),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.body, style: FlutterFlowTheme.of(context).bodyMedium),
                      const SizedBox(height: 4),
                      Text(
                        item.createdAt != null 
                            ? dateTimeFormat('relative', item.createdAt)
                            : 'Just now', 
                        style: FlutterFlowTheme.of(context).labelSmall
                      ),
                    ],
                  ),
                  isThreeLine: true,
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
