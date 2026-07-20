import 'package:d_c_i_teacher_app/components/shared/app_primary_button.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:d_c_i_teacher_app/components/announcement_card/announcement_card_model.dart';
export 'package:d_c_i_teacher_app/components/announcement_card/announcement_card_model.dart';

class AnnouncementCardWidget extends StatefulWidget {
  const AnnouncementCardWidget({
    super.key,
    this.category,
    this.date,
    this.description,
    this.title,
    this.onTap,
    this.onShare,
  });

  final String? category;
  final String? date;
  final String? description;
  final String? title;
  final Future Function()? onTap;
  final VoidCallback? onShare;

  @override
  State<AnnouncementCardWidget> createState() => _AnnouncementCardWidgetState();
}

class _AnnouncementCardWidgetState extends State<AnnouncementCardWidget> {
  late AnnouncementCardModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AnnouncementCardModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  Color _getCategoryColor(String category) {
    return switch (category) {
      'URGENT' => AppColors.error,
      'EXAM' => AppColors.primary,
      'EVENT' => AppColors.info,
      'HOLIDAY' => AppColors.warning,
      'PARENT_MEETING' => Colors.purple,
      _ => AppColors.secondary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final category = widget.category ?? 'GENERAL';
    final categoryColor = _getCategoryColor(category);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () async {
          if (widget.onTap != null) {
            await widget.onTap!();
          }
        },
        borderRadius: AppRadius.card,
        child: Container(
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: AppRadius.card,
            border: Border.all(
              color: theme.alternate,
              width: 1.0,
            ),
            boxShadow: AppShadows.low,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: categoryColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        category,
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          color: categoryColor,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    Text(
                      widget.date ?? '',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  widget.title ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.section.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.description ?? '',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body.copyWith(
                    color: theme.secondaryText,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (widget.onShare != null)
                      IconButton(
                        icon: const Icon(Icons.share_rounded, color: AppColors.success, size: 20),
                        onPressed: widget.onShare,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    const SizedBox(width: AppSpacing.md),
                    AppPrimaryButton(
                      text: 'Read More',
                      variant: 'outline',
                      width: 100,
                      height: 36,
                      onPressed: () async {
                        if (widget.onTap != null) {
                          await widget.onTap!();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
