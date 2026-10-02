import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
import '../../data/models/scan_models.dart';

// ---------------------------------------------------------------------------
// StatusBadge
// ---------------------------------------------------------------------------

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.code});

  final ScanResultCode code;

  // ── Palette ────────────────────────────────────────────────────────────────

  Color get _bg {
    if (code.isSuccess) return AppColors.validBg;
    if (code.isWarning) return AppColors.warningBg;
    return AppColors.errorBg;
  }

  Color get _fg {
    if (code.isSuccess) return AppColors.valid;
    if (code.isWarning) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final bg = _bg;
    final fg = _fg;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: fg.withOpacity(0.30),
          width: 1.5,
        ),
      ),
      child: Text(
        code.displayName,
        style: TextStyle(
          fontFamily: AppFonts.gilroy,
          fontWeight: FontWeight.w800,
          fontSize: 12,
          color: fg,
          letterSpacing: 0.2,
          height: 1.1,
        ),
      ),
    );
  }
}
