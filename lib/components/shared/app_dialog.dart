import 'package:flutter/material.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/components/shared/app_primary_button.dart';

class AppDialog extends StatelessWidget {
  final String title;
  final String content;
  final String? confirmLabel;
  final String? cancelLabel;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final bool isDanger;

  const AppDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onConfirm,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.onCancel,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.standard),
      title: Text(
        title,
        style: AppTypography.section.copyWith(fontWeight: FontWeight.bold),
      ),
      content: Text(
        content,
        style: AppTypography.body,
      ),
      actionsPadding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
      actions: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.pop(context),
          child: Text(
            cancelLabel!,
            style: AppTypography.label.copyWith(color: AppColors.textSecondary),
          ),
        ),
        AppPrimaryButton(
          text: confirmLabel!,
          onPressed: onConfirm,
          color: isDanger ? AppColors.error : AppColors.primary,
          width: 100,
          height: 40,
          fullWidth: false,
        ),
      ],
    );
  }

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String content,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDanger = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        content: content,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDanger: isDanger,
        onConfirm: () => Navigator.pop(context, true),
        onCancel: () => Navigator.pop(context, false),
      ),
    );
  }
}
