import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/di/injection.dart';
import '../../../data/models/scan_models.dart';
import '../../../data/repositories/sync_repository.dart';
import '../../../data/local/hive_service.dart';
import '../../../core/utils/connectivity_service.dart';
import '../../../shared/widgets/scan_type_card.dart';
import '../../../shared/widgets/connectivity_banner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../scanner/screens/qr_scanner_screen.dart';
import '../../../core/theme/theme_cubit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(
        sl<SyncRepository>(),
        sl<HiveService>(),
        sl<ConnectivityService>(),
      )..init(),
      child: const _HomeBody(),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  Future<void> _openScanner(BuildContext context, ScanMode mode) async {
    final status = await Permission.camera.request();
    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Camera permission is required. Please enable it in Settings.'),
            action: SnackBarAction(label: 'Settings', onPressed: () => openAppSettings()),
          ),
        );
      }
      return;
    } else if (!status.isGranted) {
      return;
    }

    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QrScannerScreen(mode: mode),
      ),
    ).then((_) {
      // Refresh counts after returning from scanner
      if (context.mounted) {
        context.read<HomeCubit>().refreshCounts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor:
              isDark ? AppColors.darkBg : AppColors.lightBg,
          body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: isDark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark,
            child: Column(
              children: [
                // Connectivity Banner
                if (state is HomeLoaded)
                  ConnectivityBanner(isOnline: state.isOnline),

                Expanded(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // ── App Bar ─────────────────────────────────────────
                      SliverAppBar(
                        expandedHeight: 180,
                        collapsedHeight: 80,
                        pinned: true,
                        backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
                        flexibleSpace: FlexibleSpaceBar(
                          collapseMode: CollapseMode.pin,
                          background: _buildHeroHeader(context, state, isDark),
                        ),
                        actions: [
                          IconButton(
                            icon: HugeIcon(
                              icon: isDark ? HugeIcons.strokeRoundedSun01 : HugeIcons.strokeRoundedMoon02,
                              color: isDark ? Colors.white : AppColors.textPrimaryLight,
                              size: 22,
                            ),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              context.read<ThemeCubit>().toggleTheme();
                            },
                          ),
                          if (state is HomeLoaded && state.isSyncing)
                            const Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: Center(
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.saffron,
                                  ),
                                ),
                              ),
                            )
                          else if (state is HomeLoaded && state.isOnline)
                            IconButton(
                              icon: const Icon(Icons.sync_rounded, size: 22),
                              onPressed: () =>
                                  context.read<HomeCubit>().syncData(),
                              tooltip: 'Sync Now',
                            ),
                        ],
                      ),

                      // ── Body Content ─────────────────────────────────────
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: state is HomeLoading
                              ? const _HomeLoadingState()
                              : state is HomeError
                                  ? _HomeErrorState(message: state.message)
                                  : state is HomeLoaded
                                      ? _HomeLoadedContent(
                                          state: state,
                                          onScan: (mode) => _openScanner(
                                            context,
                                            mode,
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroHeader(BuildContext context, HomeState state, bool isDark) {
    bool isOnline = false;

    if (state is HomeLoaded) {
      isOnline = state.isOnline;
    }

    // Removed auth cubit reference since it's open scanning mode

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBg : AppColors.lightBg,
      ),
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              // Online indicator dot
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOnline ? AppColors.valid : AppColors.warning,
                  boxShadow: [
                    BoxShadow(
                      color: (isOnline ? AppColors.valid : AppColors.warning)
                          .withOpacity(0.5),
                      blurRadius: 6,
                    )
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isOnline ? 'Online' : 'Offline',
                style: TextStyle(
                  fontFamily: AppFonts.gilroy,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: isOnline ? AppColors.valid : AppColors.warning,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontFamily: AppFonts.enzyme,
                fontSize: 38,
                fontWeight: FontWeight.w400,
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
                letterSpacing: -1,
                height: 1.05,
              ),
              children: [
                const TextSpan(text: 'India Day\n'),
                TextSpan(
                  text: '2026',
                  style: TextStyle(
                    color: AppColors.saffron,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeLoadedContent extends StatelessWidget {
  final HomeLoaded state;
  final void Function(ScanMode) onScan;

  const _HomeLoadedContent({required this.state, required this.onScan});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        // ── Stats Row ─────────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: _StatChip(
                icon: Icons.confirmation_number_outlined,
                label: 'Tickets',
                value: '${state.ticketCount}',
                color: AppColors.saffron,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatChip(
                icon: Icons.cloud_upload_outlined,
                label: 'Pending',
                value: '${state.pendingScanCount}',
                color: state.pendingScanCount > 0
                    ? AppColors.warning
                    : AppColors.valid,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatChip(
                icon: Icons.access_time_rounded,
                label: 'Last Sync',
                value: state.lastSync != null
                    ? DateFormat('HH:mm').format(state.lastSync!.toLocal())
                    : 'Never',
                color: AppColors.jade,
              ),
            ),
          ],
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

        const SizedBox(height: 28),

        // ── Section label ─────────────────────────────────────────────
        Text(
          'SCAN TYPE',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                letterSpacing: 2,
                color: isDark
                    ? AppColors.textSecondary
                    : AppColors.textSecondaryLight,
              ),
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 14),

        // ── Scanner Cards ─────────────────────────────────────────────
        Expanded(
          child: ScanTypeCard(
            mode: ScanMode.ticket,
            enabled: true,
            onTap: () => onScan(ScanMode.ticket),
          ),
        ),
        const SizedBox(height: 14),

        Expanded(
          child: ScanTypeCard(
            mode: ScanMode.genZ,
            enabled: true,
            onTap: () => onScan(ScanMode.genZ),
          ),
        ),
        const SizedBox(height: 14),

        Expanded(
          child: ScanTypeCard(
            mode: ScanMode.dinnerPass,
            enabled: true,
            onTap: () => onScan(ScanMode.dinnerPass),
          ),
        ),
        const SizedBox(height: 16),

        // ── Sync info bar ─────────────────────────────────────────────
        if (!state.isOnline && state.pendingScanCount > 0)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.warningBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.warning.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule_rounded,
                    color: AppColors.warning, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${state.pendingScanCount} scan(s) will be uploaded when you go back online.',
                    style: const TextStyle(
                      fontFamily: AppFonts.gilroy,
                      fontWeight: FontWeight.w300,
                      fontSize: 13,
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 700.ms),

        const SizedBox(height: 16),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppFonts.gilroy,
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppFonts.gilroy,
              fontWeight: FontWeight.w300,
              fontSize: 11,
              color: isDark
                  ? AppColors.textSecondary
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}



class _HomeLoadingState extends StatelessWidget {
  const _HomeLoadingState();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 60),
      child: Center(
        child: CircularProgressIndicator(color: AppColors.saffron),
      ),
    );
  }
}

class _HomeErrorState extends StatelessWidget {
  final String message;
  const _HomeErrorState({required this.message});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
