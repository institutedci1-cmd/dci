import 'package:d_c_i_teacher_app/components/shared/app_primary_button.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:flutter/material.dart';
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
      'PARENT_MEETING' => AppColors.tertiary,
      _ => AppColors.secondary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final category = widget.category ?? 'GENERAL';
    final categoryColor = _getCategoryColor(category);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppShadows.low,
        ),
        child: Material(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () async {
              if (widget.onTap != null) {
                await widget.onTap!();
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.alternate,
                  width: 1.0,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: categoryColor.withAlpha(25),
                            borderRadius: BorderRadius.circular(20),
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
                          style: AppTypography.caption.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.title ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.label.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: theme.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.description ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: theme.secondaryText,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (widget.onShare != null)
                          IconButton(
                            icon: Icon(Icons.share_rounded, color: theme.success, size: 18),
                            onPressed: widget.onShare,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        const SizedBox(width: 12),
                        AppPrimaryButton(
                          text: 'Read More',
                          variant: 'primary',
                          fullWidth: false,
                          width: 100,
                          height: 32,
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
        ),
      ),
    );
  }
}
