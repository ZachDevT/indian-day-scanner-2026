import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
import '../../data/models/scan_models.dart';

// ---------------------------------------------------------------------------
// _ScanTypeCardProps — internal data class
// ---------------------------------------------------------------------------

class _ScanTypeCardProps {
  const _ScanTypeCardProps({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.badge,
    required this.gradient,
    required this.index,
  });

  final String title;
  final String subtitle;
  final dynamic icon;
  final String badge;
  final List<Color> gradient;
  final int index;

  factory _ScanTypeCardProps.fromMode(ScanMode mode) {
    switch (mode) {
      case ScanMode.ticket:
        return _ScanTypeCardProps(
          title: 'Ticket Entry',
          subtitle: 'Scan event admission ticket',
          icon: HugeIcons.strokeRoundedTicket01,
          badge: 'SCAN TYPE 01',
          gradient: AppColors.ticketGradient,
          index: 0,
        );
      case ScanMode.genZ:
        return _ScanTypeCardProps(
          title: 'Gen-Z Access',
          subtitle: 'Dancing area special access',
          icon: HugeIcons.strokeRoundedFire,
          badge: 'SCAN TYPE 02',
          gradient: AppColors.genZGradient,
          index: 1,
        );
      case ScanMode.dinnerPass:
        return _ScanTypeCardProps(
          title: 'Dinner Pass',
          subtitle: 'Corporate dinner (CDP1.) pass',
          icon: HugeIcons.strokeRoundedSpoonAndFork,
          badge: 'SCAN TYPE 03',
          gradient: AppColors.dinnerGradient,
          index: 2,
        );
    }
  }
}

// ---------------------------------------------------------------------------
// ScanTypeCard
// ---------------------------------------------------------------------------

class ScanTypeCard extends StatefulWidget {
  const ScanTypeCard({
    super.key,
    required this.mode,
    required this.onTap,
    this.enabled = true,
    this.pendingCount,
  });

  final ScanMode mode;
  final VoidCallback onTap;
  final bool enabled;
  final int? pendingCount;

  @override
  State<ScanTypeCard> createState() => _ScanTypeCardState();
}

class _ScanTypeCardState extends State<ScanTypeCard> {
  bool _pressed = false;

  void _handleTapDown(TapDownDetails _) {
    if (!widget.enabled) return;
    setState(() => _pressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    setState(() => _pressed = false);
  }

  void _handleTapCancel() => setState(() => _pressed = false);

  void _handleTap() {
    if (!widget.enabled) return;
    HapticFeedback.mediumImpact();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final props = _ScanTypeCardProps.fromMode(widget.mode);
    final hasPending =
        widget.pendingCount != null && widget.pendingCount! > 0;

    return Animate(
      effects: [
        FadeEffect(
          duration: 400.ms,
          delay: (props.index * 100).ms,
          curve: Curves.easeOut,
        ),
        SlideEffect(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
          duration: 400.ms,
          delay: (props.index * 100).ms,
          curve: Curves.easeOut,
        ),
      ],
      child: Opacity(
        opacity: widget.enabled ? 1.0 : 0.55,
        child: GestureDetector(
          onTap: _handleTap,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          child: AnimatedScale(
            scale: _pressed ? 0.96 : 1.0,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: props.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: props.gradient.first.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // ── Decorative circles ───────────────────────────────────
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 40,
                    bottom: -30,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                  ),

                  // ── Main content ─────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    child: Row(
                      children: [
                        // Emoji frosted container
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          alignment: Alignment.center,
                          child: HugeIcon(
                            icon: props.icon,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Title / subtitle / badge
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                props.badge,
                                style: TextStyle(
                                  fontFamily: AppFonts.gilroy,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                  color: Colors.white.withOpacity(0.70),
                                  letterSpacing: 1.4,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                props.title,
                                style: const TextStyle(
                                  fontFamily: AppFonts.gilroy,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                  color: Colors.white,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                props.subtitle,
                                style: TextStyle(
                                  fontFamily: AppFonts.gilroy,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.75),
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Arrow frosted container
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Pending count badge ──────────────────────────────────
                  if (hasPending)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          '${widget.pendingCount} pending',
                          style: TextStyle(
                            fontFamily: AppFonts.gilroy,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            color: props.gradient.first,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
