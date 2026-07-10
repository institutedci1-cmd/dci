import 'package:flutter/material.dart';
import '../../shared/app_style.dart';
import '../../shared/app_colors.dart';
import '../shared/app_button.dart';

class HomeworkEmptyWidget extends StatelessWidget {
  final VoidCallback onAssignPressed;

  const HomeworkEmptyWidget({
    super.key,
    required this.onAssignPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Homework Assigned Yet',
              style: AppTypography.h1.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Assign your first homework to track it here.',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            AppButton(
              text: 'Assign Homework',
              icon: Icons.add_rounded,
              onPressed: onAssignPressed,
              fullWidth: false,
              width: 220,
            ),
          ],
        ),
      ),
    );
  }
}
