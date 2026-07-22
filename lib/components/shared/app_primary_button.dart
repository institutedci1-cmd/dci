import 'package:flutter/material.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fullWidth = true,
    this.width,
    this.height,
    this.color,
    this.variant = 'primary',
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;
  final double? width;
  final double? height;
  final Color? color;
  final String variant; // 'primary' or 'outline'

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? (variant == 'primary' ? AppColors.primary : Colors.transparent);
    final effectiveHeight = height ?? AppSize.buttonHeight;

    return SizedBox(
      width: width ?? (fullWidth ? double.infinity : null),
      height: effectiveHeight,
      child: variant == 'primary' 
          ? ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: _getButtonStyle(effectiveColor),
              child: _buildContent(),
            )
          : OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: _getOutlineStyle(color ?? AppColors.primary),
              child: _buildContent(textColor: color ?? AppColors.primary),
            ),
    );
  }

  ButtonStyle _getButtonStyle(Color baseColor) {
    return ElevatedButton.styleFrom(
      backgroundColor: baseColor,
      foregroundColor: Colors.white,
      disabledBackgroundColor: baseColor.withAlpha(150),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
      padding: EdgeInsets.symmetric(
        horizontal: width != null ? AppSpacing.sm : AppSpacing.lg,
      ),
    );
  }

  ButtonStyle _getOutlineStyle(Color baseColor) {
    return OutlinedButton.styleFrom(
      foregroundColor: baseColor,
      side: BorderSide(color: baseColor, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
      padding: EdgeInsets.symmetric(
        horizontal: width != null ? AppSpacing.sm : AppSpacing.lg,
      ),
    );
  }

  Widget _buildContent({Color textColor = Colors.white}) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) Icon(icon, size: 20),
        if (icon != null && text.isNotEmpty) const SizedBox(width: AppSpacing.sm),
        if (text.isNotEmpty)
          Flexible(
            child: Text(
              text,
              style: AppTypography.button.copyWith(color: textColor),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
      ],
    );
  }
}
