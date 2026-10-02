import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';

// ---------------------------------------------------------------------------
// AppTextField
// ---------------------------------------------------------------------------

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.textInputAction,
    this.focusNode,
    this.onFieldSubmitted,
    this.readOnly = false,
    this.onTap,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final ValueChanged<String>? onFieldSubmitted;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
  }

  void _toggleObscured() => setState(() => _obscured = !_obscured);

  // ── Styles ─────────────────────────────────────────────────────────────────

  static const _textStyle = TextStyle(
    fontFamily: AppFonts.gilroy,
    fontWeight: FontWeight.w300,
    fontSize: 15,
  );

  static const _labelStyle = TextStyle(
    fontFamily: AppFonts.gilroy,
    fontWeight: FontWeight.w600,
    fontSize: 13,
  );

  static const _hintStyle = TextStyle(
    fontFamily: AppFonts.gilroy,
    fontWeight: FontWeight.w300,
    fontSize: 15,
  );

  InputBorder _border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: 1.5),
      );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final fillColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark
        ? AppColors.textSecondary
        : AppColors.textSecondaryLight;
    final labelColor = isDark
        ? AppColors.textSecondary
        : AppColors.textSecondaryLight;

    // Determine suffix icon
    Widget? effectiveSuffix = widget.suffixIcon;
    if (widget.obscureText) {
      effectiveSuffix = GestureDetector(
        onTap: _toggleObscured,
        child: Icon(
          _obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 20,
          color: hintColor,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: _labelStyle.copyWith(color: labelColor),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          obscureText: _obscured,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onFieldSubmitted,
          validator: widget.validator,
          style: _textStyle.copyWith(color: textColor),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: _hintStyle.copyWith(color: hintColor),
            prefixIcon: widget.prefixIcon != null
                ? IconTheme(
                    data: IconThemeData(color: hintColor, size: 20),
                    child: widget.prefixIcon!,
                  )
                : null,
            suffixIcon: effectiveSuffix != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: IconTheme(
                      data: IconThemeData(color: hintColor, size: 20),
                      child: effectiveSuffix,
                    ),
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
            filled: true,
            fillColor: fillColor,
            border: _border(borderColor),
            enabledBorder: _border(borderColor),
            focusedBorder: _border(AppColors.saffron),
            errorBorder: _border(AppColors.error),
            focusedErrorBorder: _border(AppColors.error),
            errorStyle: const TextStyle(
              fontFamily: AppFonts.gilroy,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
