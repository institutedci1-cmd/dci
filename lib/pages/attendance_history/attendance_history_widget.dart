import '/backend/models/student_attendance.dart';
import '/backend/providers/attendance_provider.dart';
import '../../shared/app_style.dart';
import '../../shared/app_colors.dart';
import '../../components/shared/app_card.dart';
import '../../components/shared/app_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/flutter_flow/flutter_flow_util.dart';

export 'attendance_history_model.dart';

class AttendanceHistoryWidget extends ConsumerStatefulWidget {
  const AttendanceHistoryWidget({super.key});

  static String routeName = 'AttendanceHistory';
  static String routePath = '/attendanceHistory';

  @override
  ConsumerState<AttendanceHistoryWidget> createState() => _AttendanceHistoryWidgetState();
}

class _AttendanceHistoryWidgetState extends ConsumerState<AttendanceHistoryWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paginatedAttendanceProvider.notifier).fetchLogs();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(paginatedAttendanceProvider.notifier).fetchLogs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paginatedAttendanceProvider);
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Attendance Logs', style: AppTypography.appBarTitle),
        elevation: 0,
        backgroundColor: AppColors.surface,
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(paginatedAttendanceProvider.notifier).fetchLogs(isRefresh: true),
              child: _buildBody(state, isDesktop),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      color: AppColors.surface,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: AppSearchBar(
                  hintText: 'Search by class...',
                  onChanged: (val) {
                    ref.read(paginatedAttendanceProvider.notifier).updateFilters(className: val);
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _buildStatusDropdown(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.outline),
      ),
      child: DropdownButton<String?>(
        value: ref.watch(paginatedAttendanceProvider).filterStatus,
        hint: const Text('Status', style: TextStyle(fontSize: 12)),
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(value: null, child: Text('All')),
          DropdownMenuItem(value: 'Present', child: Text('Present')),
          DropdownMenuItem(value: 'Absent', child: Text('Absent')),
        ],
        onChanged: (val) {
          ref.read(paginatedAttendanceProvider.notifier).updateFilters(status: val);
        },
      ),
    );
  }

  Widget _buildBody(AttendanceState state, bool isDesktop) {
    if (state.logs.isEmpty && state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.logs.isEmpty && !state.isLoading) {
      return _buildEmptyState();
    }

    if (state.errorMessage != null && state.logs.isEmpty) {
      return _buildErrorState(state.errorMessage!);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (isDesktop) {
          return _buildGridView(state);
        }
        return _buildListView(state);
      },
    );
  }

  Widget _buildListView(AttendanceState state) {
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: state.logs.length + (state.hasMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        if (index == state.logs.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: CircularProgressIndicator(),
            ),
          );
        }
        return _buildLogCard(state.logs[index]);
      },
    );
  }

  Widget _buildGridView(AttendanceState state) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.5,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: state.logs.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.logs.length) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildLogCard(state.logs[index]);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 64, color: AppColors.textTertiary.withValues(alpha: 0.5)),
          const SizedBox(height: AppSpacing.md),
          Text('No records found', style: AppTypography.sectionTitle),
          Text('Try adjusting your filters', style: AppTypography.caption),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text('Failed to load logs', style: AppTypography.sectionTitle),
            Text(error, textAlign: TextAlign.center, style: AppTypography.caption),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () => ref.read(paginatedAttendanceProvider.notifier).fetchLogs(isRefresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogCard(StudentAttendance record) {
    final statusColor = _getStatusColor(record.status);
    
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: statusColor.withValues(alpha: 0.1),
            child: Icon(_getStatusIcon(record.status), color: statusColor, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.studentName, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                Text(
                  '${record.className} • ${record.subject}',
                  style: AppTypography.caption,
                ),
                Text(
                  dateTimeFormat('yMMMd', record.date),
                  style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          _buildStatusBadge(record.status, statusColor),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }

  Color _getStatusColor(String status) {
    return switch (status) {
      'Present' => AppColors.success,
      'Absent' => AppColors.error,
      'Leave' => AppColors.warning,
      _ => AppColors.textTertiary,
    };
  }

  IconData _getStatusIcon(String status) {
    return switch (status) {
      'Present' => Icons.check_circle_rounded,
      'Absent' => Icons.cancel_rounded,
      'Leave' => Icons.pause_circle_rounded,
      _ => Icons.help_rounded,
    };
  }
}
