import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/components/homework_card/homework_card_widget.dart';
import 'package:d_c_i_teacher_app/components/shared/app_empty_state.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'my_homework_model.dart';

class MyHomeworkWidget extends ConsumerStatefulWidget {
  const MyHomeworkWidget({super.key});

  static String routeName = 'MyHomework';
  static String routePath = '/myHomework';

  @override
  ConsumerState<MyHomeworkWidget> createState() => _MyHomeworkWidgetState();
}

class _MyHomeworkWidgetState extends ConsumerState<MyHomeworkWidget> {
  late MyHomeworkModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MyHomeworkModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final studentAsync = ref.watch(currentStudentStreamProvider);

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.primaryBackground,
      body: Column(
        children: [
          HeaderSectionWidget(
            title: 'My Homework',
            subtitle: 'Assignments & Tasks',
            onBackPressed: () async => context.safePop(),
            showActionIcon: false,
          ),
          Expanded(
            child: studentAsync.when(
              data: (student) {
                if (student == null) return const Center(child: Text('Profile not found.'));
                
                final homeworkAsync = ref.watch(studentHomeworkStreamProvider(student.className));
                
                return homeworkAsync.when(
                  data: (assignments) {
                    if (assignments.isEmpty) {
                      return const AppEmptyState(
                        icon: Icons.edit_note_rounded,
                        title: 'No homework assigned',
                        description: 'Enjoy your free time! Check back later.',
                      );
                    }
                    return ListView.separated(
                      padding: AppSpacing.pagePadding,
                      itemCount: assignments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        return HomeworkCardWidget(
                          assignment: assignments[index],
                          onTap: () async {
                            context.pushNamed(
                              'HomeworkDetails',
                              extra: {'assignment': assignments[index]},
                            );
                          },
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Error: $err')),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
