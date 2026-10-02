import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../cubit/scanner_cubit.dart';
import '../cubit/scanner_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/di/injection.dart';
import '../../../data/models/scan_models.dart';
import '../../../data/repositories/scan_repository.dart';
import '../../../core/utils/connectivity_service.dart';
import '../../../shared/widgets/connectivity_banner.dart';
import '../../../shared/widgets/scan_overlay_widget.dart';
import '../../result/screens/scan_result_screen.dart';

class QrScannerScreen extends StatelessWidget {
  final ScanMode mode;

  const QrScannerScreen({
    super.key,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ScannerCubit(
        sl<ScanRepository>(),
        sl<ConnectivityService>(),
        mode: mode,
      ),
      child: _QrScannerBody(mode: mode),
    );
  }
}

class _QrScannerBody extends StatefulWidget {
  final ScanMode mode;

  const _QrScannerBody({required this.mode});

  @override
  State<_QrScannerBody> createState() => _QrScannerBodyState();
}

class _QrScannerBodyState extends State<_QrScannerBody>
    with WidgetsBindingObserver {
  late final MobileScannerController _controller;
  bool _hasNavigated = false;
  bool _isAppInForeground = true;
  bool _stopPending = false;
  Future<void> _cameraOperation = Future<void>.value();

  _ScanModeConfig get _config => _ScanModeConfig.fromMode(widget.mode);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      returnImage: false,
      // MobileScanner starts the camera once the controller is attached.
      autoStart: true,
    );
    _controller.addListener(_onCameraStateChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.removeListener(_onCameraStateChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _isAppInForeground = true;
        _stopPending = false;
        unawaited(_runCameraOperation(_startCameraIfNeeded));
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _isAppInForeground = false;
        _stopCameraWhenReady();
    }
  }

  void _onCameraStateChanged() {
    if (_stopPending && _controller.value.isRunning) {
      _stopPending = false;
      unawaited(_runCameraOperation(_controller.stop));
    }
  }

  void _stopCameraWhenReady() {
    if (_controller.value.isStarting) {
      _stopPending = true;
      return;
    }

    if (_controller.value.isRunning) {
      unawaited(_runCameraOperation(_controller.stop));
    }
  }

  Future<void> _startCameraIfNeeded() async {
    if (!_isAppInForeground ||
        _controller.value.isRunning ||
        _controller.value.isStarting) {
      return;
    }

    await _controller.start();
  }

  Future<void> _runCameraOperation(Future<void> Function() operation) {
    // Serialize camera operations. CameraX can fail if start/stop overlap,
    // which can happen when a QR is detected as the app is backgrounded.
    _cameraOperation = _cameraOperation.then((_) => operation()).catchError(
      (Object error, StackTrace stackTrace) {
        debugPrint('Scanner camera operation failed: $error');
      },
    );
    return _cameraOperation;
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_hasNavigated) return;
    final code = capture.barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    _hasNavigated = true;
    await _runCameraOperation(_controller.stop);
    HapticFeedback.heavyImpact();

    if (!mounted) return;
    final result = await context.read<ScannerCubit>().scan(code);
    if (!mounted) return;

    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, anim, __) => FadeTransition(
          opacity: anim,
          child: ScanResultScreen(
            result: result,
            mode: widget.mode,
          ),
        ),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );

    // Return to scanner
    if (!mounted) return;
    _hasNavigated = false;
    context.read<ScannerCubit>().reset();
    await _runCameraOperation(_startCameraIfNeeded);
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = sl<ConnectivityService>().isOnline;

    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocListener<ScannerCubit, ScannerState>(
        listener: (context, state) {
          // Nothing extra needed — navigation handled in _onDetect
        },
        child: Stack(
          children: [
            // ── Camera ────────────────────────────────────────────────
            MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              errorBuilder: (context, error) {
                return Center(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            color: Colors.redAccent, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'Camera Error',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.errorDetails?.message ??
                              error.errorCode.message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () async {
                            await _runCameraOperation(_startCameraIfNeeded);
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // ── Dark overlay + frame ──────────────────────────────────
            BlocBuilder<ScannerCubit, ScannerState>(
              builder: (context, state) {
                return ScanOverlayWidget(
                  mode: widget.mode,
                  isProcessing: state is ScannerProcessing,
                );
              },
            ),

            // ── Connectivity Banner ───────────────────────────────────
            SafeArea(
              child: Column(
                children: [
                  ConnectivityBanner(isOnline: isOnline),

                  // ── Top Bar ─────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Mode badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: _config.accentColor.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              HugeIcon(
                                icon: _config.icon,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _config.title.toUpperCase(),
                                style: const TextStyle(
                                  fontFamily: AppFonts.gilroy,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn()
                            .scale(begin: const Offset(0.8, 0.8)),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // ── Bottom HUD ──────────────────────────────────────
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 48),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _config.instruction,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: AppFonts.gilroy,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _config.hint,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppFonts.gilroy,
                            fontWeight: FontWeight.w300,
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Torch toggle
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ValueListenableBuilder<MobileScannerState>(
                              valueListenable: _controller,
                              builder: (context, state, child) {
                                final isOn = state.torchState == TorchState.on;
                                return _HudButton(
                                  icon: isOn
                                      ? Icons.flash_on_rounded
                                      : Icons.flash_off_rounded,
                                  label: 'Torch',
                                  isActive: isOn,
                                  onTap: () => _controller.toggleTorch(),
                                );
                              },
                            ),
                            const SizedBox(width: 20),
                            _HudButton(
                              icon: Icons.flip_camera_ios_rounded,
                              label: 'Flip',
                              onTap: () => _controller.switchCamera(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HudButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _HudButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withOpacity(0.25)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
              color: isActive
                  ? Colors.white.withOpacity(0.4)
                  : Colors.white.withOpacity(0.15)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: AppFonts.gilroy,
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanModeConfig {
  final String title;
  final dynamic icon;
  final String instruction;
  final String hint;
  final Color accentColor;

  const _ScanModeConfig({
    required this.title,
    required this.icon,
    required this.instruction,
    required this.hint,
    required this.accentColor,
  });

  static _ScanModeConfig fromMode(ScanMode mode) {
    switch (mode) {
      case ScanMode.ticket:
        return const _ScanModeConfig(
          title: 'Ticket Entry',
          icon: HugeIcons.strokeRoundedTicket01,
          instruction: 'Scan attendee ticket QR',
          hint: 'Point the camera at the QR code on the ticket',
          accentColor: AppColors.saffron,
        );
      case ScanMode.genZ:
        return const _ScanModeConfig(
          title: 'Gen-Z Access',
          icon: HugeIcons.strokeRoundedFire,
          instruction: 'Scan Gen-Z dancing area QR',
          hint: 'Use the same ticket QR — recorded independently',
          accentColor: Color(0xFFAD3AFF),
        );
      case ScanMode.dinnerPass:
        return const _ScanModeConfig(
          title: 'Dinner Pass',
          icon: HugeIcons.strokeRoundedSpoonAndFork,
          instruction: 'Scan Corporate Dinner Pass',
          hint: 'QR codes start with CDP1. — tickets will be rejected',
          accentColor: AppColors.gold,
        );
    }
  }
}
