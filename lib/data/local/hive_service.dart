import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/ticket_models.dart';
import '../models/scan_models.dart';

class HiveService {
  static const String _ticketsBox = 'tickets';
  static const String _dinnerPassBox = 'dinner_passes';
  static const String _pendingScansBox = 'pending_scans';
  static const String _metaBox = 'meta';

  static const String _keyLastSync = 'last_sync';

  // ─── Init ────────────────────────────────────────────────────────────────
  Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox(_ticketsBox),
      Hive.openBox(_dinnerPassBox),
      Hive.openBox(_pendingScansBox),
      Hive.openBox(_metaBox),
    ]);
  }

  // ─── Theme ───────────────────────────────────────────────────────────────
  bool get isDarkMode => Hive.box(_metaBox).get('is_dark_mode', defaultValue: true) as bool;
  Future<void> setDarkMode(bool isDark) async => Hive.box(_metaBox).put('is_dark_mode', isDark);

  // ─── Tickets ─────────────────────────────────────────────────────────────
  Future<void> saveTickets(List<OfflineTicket> tickets) async {
    final box = Hive.box(_ticketsBox);
    final map = {for (final t in tickets) t.ticketNumber: jsonEncode(t.toJson())};
    await box.putAll(map);
  }

  Future<void> clearTickets() async => Hive.box(_ticketsBox).clear();

  int get ticketCount => Hive.box(_ticketsBox).length;

  OfflineTicket? findTicketByQr(String qrPayload) {
    final box = Hive.box(_ticketsBox);
    for (final v in box.values) {
      final t = OfflineTicket.fromJson(jsonDecode(v as String) as Map<String, dynamic>);
      if (t.qrPayload == qrPayload || t.ticketNumber == qrPayload) return t;
    }
    return null;
  }

  Future<void> markTicketUsed(String ticketNumber) async {
    final box = Hive.box(_ticketsBox);
    final raw = box.get(ticketNumber) as String?;
    if (raw == null) return;
    final t = OfflineTicket.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    final updated = OfflineTicket(
      ticketNumber: t.ticketNumber,
      attendeeName: t.attendeeName,
      category: t.category,
      status: 'Used',
      hasGenZAccess: t.hasGenZAccess,
      qrPayload: t.qrPayload,
    );
    await box.put(ticketNumber, jsonEncode(updated.toJson()));
  }

  // ─── Dinner Passes ───────────────────────────────────────────────────────
  Future<void> saveDinnerPasses(List<OfflineDinnerPass> passes) async {
    final box = Hive.box(_dinnerPassBox);
    final map = {for (final p in passes) p.passNumber: jsonEncode(p.toJson())};
    await box.putAll(map);
  }

  Future<void> clearDinnerPasses() async => Hive.box(_dinnerPassBox).clear();

  int get dinnerPassCount => Hive.box(_dinnerPassBox).length;

  // ─── Pending Scans ───────────────────────────────────────────────────────
  Future<void> addPendingScan(PendingScan scan) async {
    final box = Hive.box(_pendingScansBox);
    await box.put(scan.clientScanId, jsonEncode(scan.toJson()));
  }

  Future<void> removePendingScan(String clientScanId) async {
    await Hive.box(_pendingScansBox).delete(clientScanId);
  }

  List<PendingScan> getPendingScans() {
    final box = Hive.box(_pendingScansBox);
    return box.values
        .map((v) => PendingScan.fromJson(jsonDecode(v as String) as Map<String, dynamic>))
        .toList();
  }

  int get pendingScanCount => Hive.box(_pendingScansBox).length;

  // ─── Sync Metadata ───────────────────────────────────────────────────────
  Future<void> setLastSync(DateTime dt) async {
    await Hive.box(_metaBox).put(_keyLastSync, dt.toIso8601String());
  }

  DateTime? getLastSync() {
    final raw = Hive.box(_metaBox).get(_keyLastSync) as String?;
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }
}
