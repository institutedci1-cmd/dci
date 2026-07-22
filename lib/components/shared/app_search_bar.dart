import 'package:flutter/material.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';

class AppSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final VoidCallback? onFilterTap;
  final bool filterPresent;
  final TextEditingController? controller;

  const AppSearchBar({
    super.key,
    this.hintText = 'Search...',
    this.onChanged,
    this.onClear,
    this.onFilterTap,
    this.filterPresent = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: theme.alternate,
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: theme.primary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: AppTypography.caption.copyWith(color: theme.secondaryText),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              style: AppTypography.body.copyWith(fontSize: 14),
            ),
          ),
          if (controller != null && controller!.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 20),
              onPressed: () {
                controller?.clear();
                if (onClear != null) onClear!();
                if (onChanged != null) onChanged!('');
              },
              color: FlutterFlowTheme.of(context).secondaryText,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            )
          else if (onClear != null)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 20),
              onPressed: onClear,
              color: theme.secondaryText,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          if (filterPresent) ...[
            VerticalDivider(
              color: theme.alternate,
              width: 24,
              thickness: 1,
              indent: 8,
              endIndent: 8,
            ),
            IconButton(
              icon: Icon(Icons.filter_list_rounded, color: theme.primary, size: 20),
              onPressed: onFilterTap,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );
  }
}
