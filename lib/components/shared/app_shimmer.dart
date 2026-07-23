import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';

class AppShimmer extends StatelessWidget {
  const AppShimmer({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.margin,
  });

  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final baseColor = theme.alternate.withAlpha(100);
    final highlightColor = theme.alternate.withAlpha(30);

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ).animate(onPlay: (controller) => controller.repeat())
     .shimmer(
       duration: 1200.ms,
       color: highlightColor,
       angle: 0.7,
     );
  }

  static Widget listTile({EdgeInsetsGeometry? padding}) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const AppShimmer(width: 48, height: 48, borderRadius: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppShimmer(width: double.infinity, height: 16),
                const SizedBox(height: 8),
                const AppShimmer(width: 150, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget card({double height = 120, EdgeInsetsGeometry? margin}) {
    return AppShimmer(
      width: double.infinity,
      height: height,
      borderRadius: 12,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
