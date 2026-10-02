import 'package:equatable/equatable.dart';

enum ScanMode { ticket, genZ, dinnerPass }
enum ScanResultCode {
  valid,
  alreadyUsed,
  invalid,
  cancelled,
  replaced,
  notPaid,
  notIssued,
  wrongEvent,
  expired,
  unauthorizedGate,
  duplicateRequest,
  temporarilyUnavailable,
  wrongCredentialType,
  offline,
  unknown,
}

extension ScanResultCodeX on ScanResultCode {
  String get displayName {
    switch (this) {
      case ScanResultCode.valid: return 'Valid';
      case ScanResultCode.alreadyUsed: return 'Already Used';
      case ScanResultCode.invalid: return 'Invalid QR';
      case ScanResultCode.cancelled: return 'Cancelled';
      case ScanResultCode.replaced: return 'Replaced';
      case ScanResultCode.notPaid: return 'Not Paid';
      case ScanResultCode.notIssued: return 'Not Issued';
      case ScanResultCode.wrongEvent: return 'Wrong Event';
      case ScanResultCode.expired: return 'Expired';
      case ScanResultCode.unauthorizedGate: return 'Unauthorized Gate';
      case ScanResultCode.duplicateRequest: return 'Duplicate';
      case ScanResultCode.temporarilyUnavailable: return 'Temporarily Unavailable';
      case ScanResultCode.wrongCredentialType: return 'Wrong Credential Type';
      case ScanResultCode.offline: return 'Queued (Offline)';
      case ScanResultCode.unknown: return 'Unknown';
    }
  }

  bool get isSuccess => this == ScanResultCode.valid;
  bool get isWarning => this == ScanResultCode.alreadyUsed || this == ScanResultCode.offline;
  bool get isError => !isSuccess && !isWarning;
}

ScanResultCode scanResultFromString(String? value) {
  switch (value) {
    case 'Valid': return ScanResultCode.valid;
    case 'AlreadyUsed': return ScanResultCode.alreadyUsed;
    case 'Invalid': return ScanResultCode.invalid;
    case 'Cancelled': return ScanResultCode.cancelled;
    case 'Replaced': return ScanResultCode.replaced;
    case 'NotPaid': return ScanResultCode.notPaid;
    case 'NotIssued': return ScanResultCode.notIssued;
    case 'WrongEvent': return ScanResultCode.wrongEvent;
    case 'Expired': return ScanResultCode.expired;
    case 'UnauthorizedGate': return ScanResultCode.unauthorizedGate;
    case 'DuplicateRequest': return ScanResultCode.duplicateRequest;
    case 'TemporarilyUnavailable': return ScanResultCode.temporarilyUnavailable;
    case 'WrongCredentialType': return ScanResultCode.wrongCredentialType;
    default: return ScanResultCode.unknown;
  }
}

class ScanRequest extends Equatable {
  final String clientScanId;
  final String qrPayload;
  final DateTime scannedAtUtc;
  final ScanMode mode;

  const ScanRequest({
    required this.clientScanId,
    required this.qrPayload,
    required this.scannedAtUtc,
    required this.mode,
  });

  Map<String, dynamic> toJson() => {
        'clientScanId': clientScanId,
        'qrPayload': qrPayload,
        'scannedAtUtc': scannedAtUtc.toIso8601String(),
      };

  @override
  List<Object?> get props => [clientScanId, qrPayload, scannedAtUtc, mode];
}

class ScanResult extends Equatable {
  final ScanResultCode result;
  final bool replayed;
  final String? attendeeName;
  final String? ticketNumber;
  final String? category;
  final String? passNumber;
  final String? passName;
  final bool isOffline;

  const ScanResult({
    required this.result,
    this.replayed = false,
    this.attendeeName,
    this.ticketNumber,
    this.category,
    this.passNumber,
    this.passName,
    this.isOffline = false,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    final ticket = json['ticket'] as Map<String, dynamic>?;
    final attendee = ticket?['attendee'] as Map<String, dynamic>?;
    final categoryMap = ticket?['category'] as Map<String, dynamic>?;
    return ScanResult(
      result: scanResultFromString(json['result'] as String?),
      replayed: json['replayed'] as bool? ?? false,
      attendeeName: attendee?['name'] as String?,
      ticketNumber: ticket?['ticketNumber'] as String?,
      category: categoryMap?['name'] as String?,
    );
  }

  factory ScanResult.offline(ScanRequest request) => const ScanResult(
        result: ScanResultCode.offline,
        isOffline: true,
      );

  @override
  List<Object?> get props => [result, replayed, attendeeName, ticketNumber];
}

// Pending offline scan to be synced
class PendingScan {
  final String clientScanId;
  final String qrPayload;
  final String scannedAtUtc;
  final String mode; // 'ticket' | 'genZ' | 'dinnerPass'
  final String createdAt;

  PendingScan({
    required this.clientScanId,
    required this.qrPayload,
    required this.scannedAtUtc,
    required this.mode,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'clientScanId': clientScanId,
        'qrPayload': qrPayload,
        'scannedAtUtc': scannedAtUtc,
        'mode': mode,
        'createdAt': createdAt,
      };

  factory PendingScan.fromJson(Map<String, dynamic> json) => PendingScan(
        clientScanId: json['clientScanId'] as String,
        qrPayload: json['qrPayload'] as String,
        scannedAtUtc: json['scannedAtUtc'] as String,
        mode: json['mode'] as String,
        createdAt: json['createdAt'] as String,
      );
}
