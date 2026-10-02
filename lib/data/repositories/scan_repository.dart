import 'package:uuid/uuid.dart';
import '../models/scan_models.dart';
import '../local/hive_service.dart';
import '../remote/api_client.dart';
import '../../core/constants/api_constants.dart';

class ScanRepository {
  final ApiClient _api;
  final HiveService _hive;
  final _uuid = const Uuid();

  ScanRepository(this._api, this._hive);

  /// Perform a scan — online tries API first, offline queues locally
  Future<ScanResult> scan({
    required String qrPayload,
    required ScanMode mode,
    required bool isOnline,
  }) async {
    final clientScanId = _uuid.v4();
    final scannedAt = DateTime.now().toUtc();

    final pending = PendingScan(
      clientScanId: clientScanId,
      qrPayload: qrPayload,
      scannedAtUtc: scannedAt.toIso8601String(),
      mode: mode.name,
      createdAt: DateTime.now().toIso8601String(),
    );

    if (!isOnline) {
      // Store offline
      await _hive.addPendingScan(pending);
      // Try local lookup for immediate feedback
      final local = _hive.findTicketByQr(qrPayload);
      if (local != null) {
        await _hive.markTicketUsed(local.ticketNumber);
        return ScanResult(
          result: local.status == 'Used' ? ScanResultCode.alreadyUsed : ScanResultCode.offline,
          attendeeName: local.attendeeName,
          ticketNumber: local.ticketNumber,
          category: local.category,
          isOffline: true,
        );
      }
      return ScanResult.offline(ScanRequest(
        clientScanId: clientScanId,
        qrPayload: qrPayload,
        scannedAtUtc: scannedAt,
        mode: mode,
      ));
    }

    // Online scan
    try {
      final endpoint = _endpointForMode(mode);
      final response = await _api.post(endpoint, data: {
        'qrPayload': qrPayload,
        'clientScanId': clientScanId,
        'scannedAtUtc': scannedAt.toIso8601String(),
      });
      return ScanResult.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      // Fallback to offline queue on network error
      await _hive.addPendingScan(pending);
      return ScanResult.offline(ScanRequest(
        clientScanId: clientScanId,
        qrPayload: qrPayload,
        scannedAtUtc: scannedAt,
        mode: mode,
      ));
    }
  }

  String _endpointForMode(ScanMode mode) {
    switch (mode) {
      case ScanMode.ticket: return ApiConstants.scannerTicketScan;
      case ScanMode.genZ: return ApiConstants.scannerGenZScan;
      case ScanMode.dinnerPass: return ApiConstants.scannerDinnerScan;
    }
  }

  int get pendingCount => _hive.pendingScanCount;
}
