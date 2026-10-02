import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_fonts.dart';

// ---------------------------------------------------------------------------
// ConnectivityBanner
// ---------------------------------------------------------------------------

class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({super.key, required this.isOnline});

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => SizeTransition(
        sizeFactor: animation,
        axisAlignment: -1,
        child: child,
      ),
      child: isOnline
          ? const SizedBox.shrink(key: ValueKey('online'))
          : _OfflineBanner(key: const ValueKey('offline')),
    );
  }
}

// ---------------------------------------------------------------------------
// _OfflineBanner (private)
// ---------------------------------------------------------------------------

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFFF3CD), // amber-100 equivalent
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Pulsing orange dot
          _PulsingDot(),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Offline mode — Scans queued for sync',
              style: TextStyle(
                fontFamily: AppFonts.gilroy,
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: const Color(0xFF7D4F00),
                height: 1.3,
              ),
            ),
          ),
          const Icon(
            Icons.wifi_off_rounded,
            size: 18,
            color: Color(0xFF7D4F00),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _PulsingDot
// ---------------------------------------------------------------------------

class _PulsingDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: Color(0xFFE67E00),
        shape: BoxShape.circle,
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .scaleXY(
          begin: 1.0,
          end: 1.6,
          duration: 700.ms,
          curve: Curves.easeInOut,
        )
        .then()
        .scaleXY(
          begin: 1.6,
          end: 1.0,
          duration: 700.ms,
          curve: Curves.easeInOut,
        )
        .fadeOut(
          begin: 1.0,
          duration: 700.ms,
        );
  }
}
