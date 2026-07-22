import 'package:flutter/material.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';

class ResponsiveUtils {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width <= AppSpacing.mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width > AppSpacing.mobileBreakpoint &&
      MediaQuery.of(context).size.width <= AppSpacing.tabletBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width > AppSpacing.tabletBreakpoint;

  static int getCrossAxisCount(BuildContext context, {int mobile = 1, int tablet = 2, int desktop = 3}) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }

  static Widget responsiveRow(BuildContext context, List<Widget> children, {double spacing = AppSpacing.md}) {
    if (isMobile(context)) {
      return Column(
        children: children.map((c) => Padding(
          padding: EdgeInsets.only(bottom: spacing),
          child: c,
        )).toList(),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.map((c) => Expanded(
        child: Padding(
          padding: EdgeInsets.only(right: children.indexOf(c) != children.length - 1 ? spacing : 0),
          child: c,
        ),
      )).toList(),
    );
  }
}
