import 'package:equatable/equatable.dart';
import '../../../data/models/scan_models.dart';

abstract class ScannerState extends Equatable {
  const ScannerState();
  @override List<Object?> get props => [];
}

class ScannerIdle extends ScannerState { const ScannerIdle(); }
class ScannerProcessing extends ScannerState { const ScannerProcessing(); }

class ScannerSuccess extends ScannerState {
  final ScanResult result;
  const ScannerSuccess(this.result);
  @override List<Object?> get props => [result];
}

class ScannerFailure extends ScannerState {
  final String message;
  const ScannerFailure(this.message);
  @override List<Object?> get props => [message];
}
