import '/backend/models/notification_model.dart';
import '/backend/providers/repository_providers.dart';
import '../../shared/app_style.dart';
import '../../shared/app_colors.dart';
import '../../components/shared/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/flutter_flow/flutter_flow_util.dart';

export 'notifications_model.dart';

class NotificationsWidget extends ConsumerStatefulWidget {
  const NotificationsWidget({super.key});

  static String routeName = 'Notifications';
  static String routePath = '/notifications';

  @override
  ConsumerState<NotificationsWidget> createState() => _NotificationsWidgetState();
}

class _NotificationsWidgetState extends ConsumerState<NotificationsWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.safePop(),
        ),
      ),
      body: _buildNotificationsList(),
    );
  }

  Widget _buildNotificationsList() {
    return StreamBuilder<List<AppNotification>>(
      stream: ref.watch(notificationRepositoryProvider).getNotificationsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final notifications = snapshot.data ?? [];
        if (notifications.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: notifications.length,
          separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final item = notifications[index];
            return _buildNotificationItem(item);
          },
        );
      },
    );
  }

  Widget _buildNotificationItem(AppNotification item) {
    final theme = Theme.of(context);
    
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => ref.read(notificationRepositoryProvider).deleteNotification(item.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: AppCard(
        onTap: () {
          if (!item.isRead) {
            ref.read(notificationRepositoryProvider).markAsRead(item.id);
          }
        },
        padding: const EdgeInsets.all(AppSpacing.md),
        color: item.isRead ? AppColors.surface : AppColors.accent.withValues(alpha: 0.03),
        border: BorderSide(
          color: item.isRead ? AppColors.outline : AppColors.accent.withValues(alpha: 0.2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: (item.isRead ? AppColors.textTertiary : AppColors.accent).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIcon(item.type),
                size: 18,
                color: item.isRead ? AppColors.textTertiary : AppColors.accent,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: item.isRead ? FontWeight.w500 : FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.body,
                    style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    item.createdAt != null ? dateTimeFormat('relative', item.createdAt) : 'Just now',
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            if (!item.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded, size: 48, color: AppColors.textTertiary),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No notifications yet',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String type) {
    return switch (type) {
      'alert' => Icons.warning_amber_rounded,
      'reminder' => Icons.alarm_rounded,
      'system' => Icons.settings_suggest_rounded,
      _ => Icons.notifications_none_rounded,
    };
  }
}
