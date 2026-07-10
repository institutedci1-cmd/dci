import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../backend/models/homework.dart';
import '../../backend/providers/repository_providers.dart';
import '../../shared/app_style.dart';
import '../../shared/app_colors.dart';
import '../../components/homework_card/homework_card_widget.dart';
import '../../components/homework_search_bar/homework_search_bar.dart';
import '../../components/homework_filter/homework_filter_widget.dart';
import '../../components/homework_empty_state/homework_empty_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '../homework_assignment/homework_assignment_widget.dart';

class HomeworkHistoryWidget extends ConsumerStatefulWidget {
  const HomeworkHistoryWidget({super.key});

  static String routeName = 'HomeworkHistory';
  static String routePath = '/homeworkHistory';

  @override
  ConsumerState<HomeworkHistoryWidget> createState() => _HomeworkHistoryWidgetState();
}

class _HomeworkHistoryWidgetState extends ConsumerState<HomeworkHistoryWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Map<String, dynamic> _filters = {
    'class': null,
    'subject': null,
    'status': null,
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Homework> _applySearchAndFilters(List<Homework> allHomework) {
    return allHomework.where((hw) {
      // Search logic
      final matchesSearch = _searchQuery.isEmpty ||
          hw.homework.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          hw.chapter.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          hw.subject.toLowerCase().contains(_searchQuery.toLowerCase());

      // Filter logic
      final matchesClass = _filters['class'] == null || hw.className == _filters['class'];
      final matchesSubject = _filters['subject'] == null || hw.subject == _filters['subject'];
      final matchesStatus = _filters['status'] == null || 
          (hw.completed ? 'COMPLETED' : 'PENDING') == _filters['status'];

      return matchesSearch && matchesClass && matchesSubject && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Homework History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.safePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: Column(
        children: [
          HomeworkSearchBar(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val),
            onFilterTap: _showFilters,
          ),
          Expanded(
            child: StreamBuilder<List<Homework>>(
              stream: ref.watch(homeworkRepositoryProvider).getHomeworkHistory(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final allHomework = snapshot.data ?? [];
                final filteredHomework = _applySearchAndFilters(allHomework);

                if (allHomework.isEmpty) {
                  return HomeworkEmptyWidget(
                    onAssignPressed: () => context.pushNamed(HomeworkAssignmentWidget.routeName),
                  );
                }

                if (filteredHomework.isEmpty) {
                  return const Center(child: Text('No matches found for your search/filters.'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredHomework.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final homework = filteredHomework[index];
                    return HomeworkCardWidget(
                      homework: homework,
                      onView: () => _viewHomework(homework),
                      onEdit: () => _editHomework(homework),
                      onDuplicate: () => _duplicateHomework(homework),
                      onDelete: () => _deleteHomework(homework),
                      onShare: () => _shareHomework(homework),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(HomeworkAssignmentWidget.routeName),
        label: const Text('Assign Homework'),
        icon: const Icon(Icons.add_rounded),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HomeworkFilterWidget(
        initialFilters: _filters,
        onApply: (newFilters) {
          setState(() => _filters = newFilters);
        },
      ),
    );
  }

  void _viewHomework(Homework homework) {
    // Navigate to details or show dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(homework.chapter),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text('Class: ${homework.className}'),
              Text('Subject: ${homework.subject}'),
              const SizedBox(height: 8),
              Text('Homework: ${homework.homework}'),
              if (homework.remarks.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Remarks: ${homework.remarks}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _editHomework(Homework homework) {
    // Navigate to Assign screen with initial data
    context.pushNamed(HomeworkAssignmentWidget.routeName, extra: {'initialHomework': homework});
  }

  void _duplicateHomework(Homework homework) {
    // Duplicate logic: Navigate to Assign screen with homework data but without ID
    final duplicated = homework.copyWith(id: '');
    context.pushNamed(HomeworkAssignmentWidget.routeName, extra: {'initialHomework': duplicated});
  }

  Future<void> _deleteHomework(Homework homework) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Homework?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      await ref.read(homeworkRepositoryProvider).deleteHomework(homework.id);
    }
  }

  void _shareHomework(Homework homework) {
    // Sharing logic (Enterprise feature)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating PDF to share...')),
    );
  }
}
