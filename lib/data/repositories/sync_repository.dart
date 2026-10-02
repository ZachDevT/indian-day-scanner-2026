import '../models/ticket_models.dart';
import '../local/hive_service.dart';
import '../remote/api_client.dart';
import '../../core/constants/api_constants.dart';

class SyncRepository {
  final ApiClient _api;
  final HiveService _hive;

  SyncRepository(this._api, this._hive);

  Future<SyncResult> syncAll() async {
    var ticketsSynced = 0;
    var passesSynced = 0;
    var pendingUploaded = 0;
    var errors = 0;

    try {
      // 1. Upload pending offline scans as a batch
      final pending = _hive.getPendingScans();
      if (pending.isNotEmpty) {
        try {
          final items = pending.map((scan) => {
            'scanType': _modeToType(scan.mode),
            'qrPayload': scan.qrPayload,
            'clientScanId': scan.clientScanId,
            'scannedAtUtc': scan.scannedAtUtc,
            'offlineDecision': 'Admitted'
          }).toList();
          
          await _api.post(ApiConstants.scannerSync, data: {'items': items});
          
          for (final scan in pending) {
            await _hive.removePendingScan(scan.clientScanId);
            pendingUploaded++;
          }
        } catch (_) {
          errors++;
        }
      }

      // 2. Download fresh tickets (cursor)
      await _hive.clearTickets();
      String? cursor;
      while (true) {
        final Map<String, dynamic> query = {'limit': 500};
        if (cursor != null) query['cursor'] = cursor;
        
        final resp = await _api.get(ApiConstants.scannerTickets, queryParameters: query);
        final data = resp.data as Map<String, dynamic>;
        final items = (data['items'] as List<dynamic>?) ?? [];
        if (items.isEmpty) break;
        
        final tickets = items.map((e) {
          final m = e as Map<String, dynamic>;
          return OfflineTicket(
            ticketNumber: m['ticketNumber'] as String? ?? '',
            attendeeName: m['attendeeName'] as String?,
            category: m['categoryName'] as String?,
            status: m['status'] as String? ?? 'Issued',
            hasGenZAccess: m['genZEntitled'] as bool? ?? false,
          );
        }).toList();
        await _hive.saveTickets(tickets);
        ticketsSynced += tickets.length;
        
        if (data['hasMore'] != true) break;
        cursor = data['nextCursor'] as String?;
        if (cursor == null) break;
      }

      // 3. Download dinner passes (cursor)
      await _hive.clearDinnerPasses();
      cursor = null;
      while (true) {
        final Map<String, dynamic> query = {'limit': 500};
        if (cursor != null) query['cursor'] = cursor;

        final resp = await _api.get(ApiConstants.scannerDinnerPasses, queryParameters: query);
        final data = resp.data as Map<String, dynamic>;
        final items = (data['items'] as List<dynamic>?) ?? [];
        if (items.isEmpty) break;
        
        final passes = items.map((e) {
          final m = e as Map<String, dynamic>;
          return OfflineDinnerPass(
            passNumber: m['passNumber'] as String? ?? '',
            recipientName: m['recipientName'] as String?,
            batch: m['batchReference'] as String?,
            status: m['status'] as String? ?? 'Issued',
          );
        }).toList();
        await _hive.saveDinnerPasses(passes);
        passesSynced += passes.length;
        
        if (data['hasMore'] != true) break;
        cursor = data['nextCursor'] as String?;
        if (cursor == null) break;
      }

      await _hive.setLastSync(DateTime.now());
    } catch (e) {
      errors++;
    }

    return SyncResult(
      ticketsSynced: ticketsSynced,
      passesSynced: passesSynced,
      pendingUploaded: pendingUploaded,
      errors: errors,
    );
  }

  String _modeToType(String mode) {
    switch (mode) {
      case 'ticket': return 'Ticket';
      case 'genZ': return 'GenZ';
      case 'dinnerPass': return 'DinnerPass';
      default: return 'Ticket';
    }
  }
}

class SyncResult {
  final int ticketsSynced;
  final int passesSynced;
  final int pendingUploaded;
  final int errors;

  const SyncResult({
    required this.ticketsSynced,
    required this.passesSynced,
    required this.pendingUploaded,
    required this.errors,
  });

  bool get hasErrors => errors > 0;
  int get total => ticketsSynced + passesSynced;
}
