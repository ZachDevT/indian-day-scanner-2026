import 'package:flutter_bloc/flutter_bloc.dart';
import 'scanner_state.dart';
import '../../../data/repositories/scan_repository.dart';
import '../../../data/models/scan_models.dart';
import '../../../core/utils/connectivity_service.dart';

class ScannerCubit extends Cubit<ScannerState> {
  final ScanRepository _repo;
  final ConnectivityService _connectivity;
  final ScanMode mode;

  ScannerCubit(
    this._repo,
    this._connectivity, {
    required this.mode,
  }) : super(const ScannerIdle());

  Future<ScanResult?> scan(String qrPayload) async {
    if (state is ScannerProcessing) return null;
    emit(const ScannerProcessing());
    try {
      final result = await _repo.scan(
        qrPayload: qrPayload,
        mode: mode,
        isOnline: _connectivity.isOnline,
      );
      emit(ScannerSuccess(result));
      return result;
    } catch (e) {
      emit(ScannerFailure(e.toString()));
      return null;
    }
  }

  void reset() => emit(const ScannerIdle());
}
