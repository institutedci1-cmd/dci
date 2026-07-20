import 'package:d_c_i_teacher_app/backend/models/exam.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/pages/exams/enter_marks_widget.dart';
import 'package:d_c_i_teacher_app/pages/exams/merit_list_widget.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:d_c_i_teacher_app/components/exam_card/exam_card_model.dart';
export 'package:d_c_i_teacher_app/components/exam_card/exam_card_model.dart';

class ExamCardWidget extends StatefulWidget {
  const ExamCardWidget({
    super.key,
    required this.exam,
    this.onTap,
    this.onDelete,
  });

  final Exam exam;
  final Future Function()? onTap;
  final Future Function()? onDelete;

  @override
  State<ExamCardWidget> createState() => _ExamCardWidgetState();
}

class _ExamCardWidgetState extends State<ExamCardWidget> {
  late ExamCardModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ExamCardModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
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
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(25),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        widget.exam.subject.toUpperCase(),
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 9,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 10, color: theme.secondaryText),
                        const SizedBox(width: 4),
                        Text(
                          dateTimeFormat('yMMMd', widget.exam.date),
                          style: AppTypography.caption.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.exam.className} - ${widget.exam.subject}',
                  style: AppTypography.label.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 12, color: theme.secondaryText),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.exam.startTime} - ${widget.exam.endTime}',
                      style: AppTypography.caption.copyWith(color: theme.primaryText, fontSize: 10),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.location_on_rounded, size: 12, color: theme.secondaryText),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.exam.venue,
                        style: AppTypography.caption.copyWith(color: theme.primaryText, fontSize: 10),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pushNamed(
                          EnterMarksWidget.routeName,
                          extra: {'exam': widget.exam},
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          minimumSize: const Size(0, 32),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        child: const Text('Enter Marks', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pushNamed(
                          MeritListWidget.routeName,
                          extra: {'exam': widget.exam},
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.secondary,
                          side: const BorderSide(color: AppColors.secondary),
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          minimumSize: const Size(0, 32),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        child: const Text('Merit List', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Divider(height: 1, color: theme.alternate),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: AppTypography.caption.copyWith(color: theme.secondaryText, fontSize: 10),
                        children: [
                          const TextSpan(text: 'Marks: '),
                          TextSpan(
                            text: '${widget.exam.totalMarks}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          const TextSpan(text: ' (Pass: '),
                          TextSpan(
                            text: '${widget.exam.passingMarks}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                          const TextSpan(text: ')'),
                        ],
                      ),
                    ),
                    if (widget.onDelete != null)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: widget.onDelete,
                          borderRadius: BorderRadius.circular(6),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 16),
                          ),
                        ),
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
