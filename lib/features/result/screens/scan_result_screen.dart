import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../data/models/scan_models.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/app_button.dart';

class ScanResultScreen extends StatefulWidget {
  final ScanResult? result;
  final ScanMode mode;

  const ScanResultScreen({
    super.key,
    required this.result,
    required this.mode,
  });

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  @override
  void initState() {
    super.initState();
    _triggerHaptic();
  }

  void _triggerHaptic() {
    final r = widget.result?.result;
    if (r?.isSuccess ?? false) {
      HapticFeedback.heavyImpact();
    } else if (r?.isWarning ?? false) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.vibrate();
    }
  }

  _ResultConfig get _config {
    final r = widget.result?.result ?? ScanResultCode.unknown;
    if (r.isSuccess) {
      return _ResultConfig(
        icon: Icons.check_circle_rounded,
        iconColor: AppColors.valid,
        bgColor: AppColors.validBg,
        glowColor: AppColors.valid,
        headline: 'Access Granted',
        gradient: const [Color(0xFF0D3320), Color(0xFF0A2342)],
      );
    } else if (r == ScanResultCode.offline) {
      return _ResultConfig(
        icon: Icons.cloud_queue_rounded,
        iconColor: AppColors.warning,
        bgColor: AppColors.warningBg,
        glowColor: AppColors.warning,
        headline: 'Queued Offline',
        gradient: const [Color(0xFF2F2800), Color(0xFF1A1A0D)],
      );
    } else if (r == ScanResultCode.alreadyUsed) {
      return _ResultConfig(
        icon: Icons.info_rounded,
        iconColor: AppColors.warning,
        bgColor: AppColors.warningBg,
        glowColor: AppColors.warning,
        headline: 'Already Used',
        gradient: const [Color(0xFF2F2800), Color(0xFF1A1A0D)],
      );
    } else {
      return _ResultConfig(
        icon: Icons.cancel_rounded,
        iconColor: AppColors.error,
        bgColor: AppColors.errorBg,
        glowColor: AppColors.error,
        headline: r.displayName,
        gradient: const [Color(0xFF2F0D0D), Color(0xFF1A0A0A)],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cfg = _config;
    final result = widget.result;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: cfg.gradient,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                // ── Top bar ───────────────────────────────────────────
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const Spacer(),
                    _ModePill(mode: widget.mode),
                  ],
                ),

                const Spacer(),

                // ── Result Icon ───────────────────────────────────────
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cfg.bgColor,
                    border: Border.all(
                        color: cfg.iconColor.withOpacity(0.3), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: cfg.glowColor.withOpacity(0.3),
                        blurRadius: 40,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(cfg.icon, color: cfg.iconColor, size: 56),
                )
                    .animate()
                    .scale(
                        begin: const Offset(0.3, 0.3),
                        end: const Offset(1, 1),
                        duration: 500.ms,
                        curve: Curves.elasticOut)
                    .fadeIn(duration: 300.ms),

                const SizedBox(height: 28),

                // ── Headline ──────────────────────────────────────────
                Text(
                  cfg.headline,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AppFonts.enzyme,
                    fontSize: 44,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    letterSpacing: -1,
                    height: 1.1,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                const SizedBox(height: 12),

                // Status badge
                if (result != null)
                  StatusBadge(code: result.result)
                      .animate()
                      .fadeIn(delay: 300.ms),

                if (result?.replayed == true) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Text(
                      'Replayed result',
                      style: TextStyle(
                        fontFamily: AppFonts.gilroy,
                        fontWeight: FontWeight.w300,
                        fontSize: 11,
                        color: Colors.white60,
                      ),
                    ),
                  ).animate().fadeIn(delay: 350.ms),
                ],

                const SizedBox(height: 40),

                // ── Ticket Details ────────────────────────────────────
                if (result?.attendeeName != null ||
                    result?.ticketNumber != null ||
                    result?.isOffline == true)
                  _DetailCard(result: result!)
                      .animate()
                      .fadeIn(delay: 400.ms)
                      .slideY(begin: 0.2),

                const Spacer(),

                // ── Actions ───────────────────────────────────────────
                Column(
                  children: [
                    AppButton(
                      label: 'Scan Another',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),
                    if (result?.isOffline == true) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Scan saved offline. Will sync automatically when online.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppFonts.gilroy,
                          fontWeight: FontWeight.w300,
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ).animate().fadeIn(delay: 700.ms),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final ScanResult result;
  const _DetailCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          if (result.attendeeName != null) ...[
            _DetailRow(
              icon: Icons.person_outline_rounded,
              label: 'Attendee',
              value: result.attendeeName!,
              highlight: result.result.isSuccess,
            ),
            const SizedBox(height: 16),
          ],
          if (result.ticketNumber != null) ...[
            _DetailRow(
              icon: Icons.confirmation_number_outlined,
              label: 'Ticket No.',
              value: result.ticketNumber!,
            ),
            if (result.category != null) const SizedBox(height: 16),
          ],
          if (result.category != null)
            _DetailRow(
              icon: Icons.category_outlined,
              label: 'Category',
              value: result.category!,
            ),
          if (result.isOffline) ...[
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.cloud_queue_rounded,
              label: 'Status',
              value: 'Queued for sync',
              valueColor: AppColors.warning,
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white70, size: 16),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontFamily: AppFonts.gilroy,
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                  color: Colors.white38,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: TextStyle(
                  fontFamily: AppFonts.gilroy,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: valueColor ??
                      (highlight ? AppColors.valid : Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ModePill extends StatelessWidget {
  final ScanMode mode;
  const _ModePill({required this.mode});

  @override
  Widget build(BuildContext context) {
    dynamic icon;
    String label;
    switch (mode) {
      case ScanMode.ticket:
        icon = HugeIcons.strokeRoundedTicket01;
        label = 'TICKET';
        break;
      case ScanMode.genZ:
        icon = HugeIcons.strokeRoundedFire;
        label = 'GEN-Z';
        break;
      case ScanMode.dinnerPass:
        icon = HugeIcons.strokeRoundedSpoonAndFork;
        label = 'DINNER';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(icon: icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: AppFonts.gilroy,
              fontWeight: FontWeight.w800,
              fontSize: 11,
              color: Colors.white70,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultConfig {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final Color glowColor;
  final String headline;
  final List<Color> gradient;

  const _ResultConfig({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.glowColor,
    required this.headline,
    required this.gradient,
  });
}
