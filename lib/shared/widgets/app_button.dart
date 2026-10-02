import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';

// ---------------------------------------------------------------------------
// Variant enum
// ---------------------------------------------------------------------------

enum AppButtonVariant { primary, secondary, ghost, danger }

// ---------------------------------------------------------------------------
// AppButton
// ---------------------------------------------------------------------------

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.fullWidth = true,
    this.icon,
    this.height = 56,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool fullWidth;
  final Widget? icon;
  final double height;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  bool get _disabled => widget.onPressed == null && !widget.isLoading;

  void _handleTap() {
    if (_disabled || widget.isLoading) return;
    HapticFeedback.lightImpact();
    widget.onPressed?.call();
  }

  void _handleTapDown(TapDownDetails _) {
    if (_disabled || widget.isLoading) return;
    setState(() => _pressed = true);
  }

  void _handleTapUp(TapUpDetails _) => setState(() => _pressed = false);
  void _handleTapCancel() => setState(() => _pressed = false);

  // ── Colours ────────────────────────────────────────────────────────────────

  Color _bgColor(bool isDark) {
    switch (widget.variant) {
      case AppButtonVariant.primary:
        return AppColors.saffron;
      case AppButtonVariant.secondary:
        return isDark ? AppColors.darkSurface : AppColors.lightSurface;
      case AppButtonVariant.ghost:
        return Colors.transparent;
      case AppButtonVariant.danger:
        return AppColors.error;
    }
  }

  Color _fgColor(bool isDark) {
    switch (widget.variant) {
      case AppButtonVariant.primary:
        return Colors.white;
      case AppButtonVariant.secondary:
        return isDark ? Colors.white : Colors.black87;
      case AppButtonVariant.ghost:
        return AppColors.saffron;
      case AppButtonVariant.danger:
        return Colors.white;
    }
  }

  Border? _border(bool isDark) {
    if (widget.variant == AppButtonVariant.secondary) {
      return Border.all(
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        width: 1.5,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = _bgColor(isDark);
    final fgColor = _fgColor(isDark);

    Widget child;

    if (widget.isLoading) {
      child = SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(fgColor),
        ),
      );
    } else {
      final labelWidget = Text(
        widget.label,
        style: TextStyle(
          fontFamily: AppFonts.gilroy,
          fontWeight: FontWeight.w800,
          fontSize: 15,
          color: fgColor,
          letterSpacing: 0.3,
        ),
      );

      if (widget.icon != null) {
        child = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconTheme(
              data: IconThemeData(color: fgColor, size: 20),
              child: widget.icon!,
            ),
            const SizedBox(width: 8),
            labelWidget,
          ],
        );
      } else {
        child = labelWidget;
      }
    }

    return Opacity(
      opacity: _disabled ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: _handleTap,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          height: widget.height,
          width: widget.fullWidth ? double.infinity : null,
          padding: widget.fullWidth
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(horizontal: 28),
          transform: Matrix4.identity()
            ..scale(_pressed ? 0.97 : 1.0, _pressed ? 0.97 : 1.0),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: _border(isDark),
            boxShadow: (widget.variant == AppButtonVariant.primary ||
                        widget.variant == AppButtonVariant.danger) &&
                    !_disabled
                ? [
                    BoxShadow(
                      color: bgColor.withOpacity(0.40),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
