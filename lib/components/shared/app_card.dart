import 'package:flutter/material.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final double? elevation;
  final BorderSide? border;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.elevation,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(),
      child: Material(
        color: color ?? FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: AppRadius.card,
        elevation: elevation ?? 0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.card,
            border: border != null ? Border.fromBorderSide(border!) : Border.all(
              color: FlutterFlowTheme.of(context).alternate,
              width: 1,
            ),
            boxShadow: (elevation != 0) ? (elevation != null ? [
              BoxShadow(
                blurRadius: elevation!,
                color: Colors.black.withAlpha(15),
                offset: const Offset(0, 4),
              )
            ] : AppShadows.low) : null,
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.card,
            child: Padding(
              padding: padding ?? const EdgeInsets.all(AppSpacing.md),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
