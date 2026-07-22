import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/pages/home_dashboard/home_dashboard_widget.dart';
import 'package:d_c_i_teacher_app/pages/login/login_widget.dart';
import 'package:d_c_i_teacher_app/pages/student_dashboard/student_dashboard_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RootDashboardWidget extends ConsumerWidget {
  const RootDashboardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserDataStreamProvider);

    return userAsync.when(
      data: (userData) {
        if (userData == null) return const LoginWidget();
        
        return switch (userData.role) {
          'Admin' => const HomeDashboardWidget(),
          'Director' => const HomeDashboardWidget(),
          'Teacher' => const HomeDashboardWidget(),
          'Student' => const StudentDashboardWidget(),
          _ => const HomeDashboardWidget(),
        };
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, _) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text('Error loading dashboard'),
              const SizedBox(height: 8),
              Text(err.toString(), style: const TextStyle(fontSize: 12)),
              TextButton(
                onPressed: () => ref.invalidate(currentUserDataStreamProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
