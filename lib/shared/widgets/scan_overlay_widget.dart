import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/scan_models.dart';

// ---------------------------------------------------------------------------
// ScanOverlayWidget
// ---------------------------------------------------------------------------

class ScanOverlayWidget extends StatelessWidget {
  const ScanOverlayWidget({
    super.key,
    required this.mode,
    this.isProcessing = false,
  });

  final ScanMode mode;
  final bool isProcessing;

  static const double _cutoutSize = 260.0;
  static const double _cutoutRadius = 20.0;

  Color get _accent {
    switch (mode) {
      case ScanMode.ticket:
        return AppColors.saffron;
      case ScanMode.genZ:
        return const Color(0xFFAD3AFF);
      case ScanMode.dinnerPass:
        return AppColors.gold;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accent;

    return Stack(
      alignment: Alignment.center,
      children: [
        // ── Dark mask with cutout ──────────────────────────────────────────
        CustomPaint(
          painter: _ScannerMaskPainter(
            cutoutSize: _cutoutSize,
            cutoutRadius: _cutoutRadius,
          ),
          child: const SizedBox.expand(),
        ),

        // ── Corner brackets ────────────────────────────────────────────────
        CustomPaint(
          painter: _CornerPainter(
            cutoutSize: _cutoutSize,
            cutoutRadius: _cutoutRadius,
            accent: accent,
          ),
          child: const SizedBox.expand(),
        ),

        // ── Animated scan line ─────────────────────────────────────────────
        if (!isProcessing)
          ClipRRect(
            borderRadius: BorderRadius.circular(_cutoutRadius),
            child: SizedBox(
              width: _cutoutSize,
              height: _cutoutSize,
              child: _ScanLine(accent: accent),
            ),
          ),

        // ── Processing spinner ─────────────────────────────────────────────
        if (isProcessing)
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// _ScanLine — animated top-to-bottom gradient line
// ---------------------------------------------------------------------------

class _ScanLine extends StatelessWidget {
  const _ScanLine({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Animate(
      onPlay: (c) => c.repeat(reverse: true),
      effects: [
        MoveEffect(
          begin: const Offset(0, 0),
          end: const Offset(0, 258),
          duration: 1800.ms,
          curve: Curves.easeInOut,
        ),
      ],
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          height: 2,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                accent.withOpacity(0.8),
                accent,
                accent.withOpacity(0.8),
                Colors.transparent,
              ],
              stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.60),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _ScannerMaskPainter — black 65% overlay with clear rounded-rect cutout
// ---------------------------------------------------------------------------

class _ScannerMaskPainter extends CustomPainter {
  const _ScannerMaskPainter({
    required this.cutoutSize,
    required this.cutoutRadius,
  });

  final double cutoutSize;
  final double cutoutRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final maskPaint = Paint()..color = Colors.black.withOpacity(0.65);

    final cutoutRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: cutoutSize,
        height: cutoutSize,
      ),
      Radius.circular(cutoutRadius),
    );

    // Full-screen path minus the cutout
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(cutoutRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, maskPaint);
  }

  @override
  bool shouldRepaint(_ScannerMaskPainter old) =>
      old.cutoutSize != cutoutSize || old.cutoutRadius != cutoutRadius;
}

// ---------------------------------------------------------------------------
// _CornerPainter — 4 L-shaped rounded corner brackets
// ---------------------------------------------------------------------------

class _CornerPainter extends CustomPainter {
  const _CornerPainter({
    required this.cutoutSize,
    required this.cutoutRadius,
    required this.accent,
  });

  final double cutoutSize;
  final double cutoutRadius;
  final Color accent;

  static const double _armLength = 32.0;
  static const double _strokeWidth = 3.5;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accent
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final half = cutoutSize / 2;
    final r = cutoutRadius;

    // Helper: draw one L-shaped corner using a continuous path.
    void drawCorner(double signX, double signY) {
      final cornerX = cx + signX * half;
      final cornerY = cy + signY * half;

      final path = Path();
      
      // Start at the tip of the horizontal arm
      path.moveTo(cornerX - signX * (_armLength + r), cornerY);
      
      // Line to the start of the corner curve
      path.lineTo(cornerX - signX * r, cornerY);

      // Curve around the corner
      path.quadraticBezierTo(
        cornerX, cornerY, 
        cornerX, cornerY - signY * r,
      );

      // Line to the tip of the vertical arm
      path.lineTo(cornerX, cornerY - signY * (_armLength + r));

      canvas.drawPath(path, paint);
    }

    // top-left
    drawCorner(-1, -1);
    // top-right
    drawCorner(1, -1);
    // bottom-left
    drawCorner(-1, 1);
    // bottom-right
    drawCorner(1, 1);
  }

  @override
  bool shouldRepaint(_CornerPainter old) =>
      old.accent != accent ||
      old.cutoutSize != cutoutSize ||
      old.cutoutRadius != cutoutRadius;
}
