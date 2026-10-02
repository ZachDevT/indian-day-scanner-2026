class OfflineTicket {
  final String ticketNumber;
  final String? attendeeName;
  final String? category;
  final String status;
  final bool hasGenZAccess;
  final String? qrPayload;

  OfflineTicket({
    required this.ticketNumber,
    this.attendeeName,
    this.category,
    required this.status,
    this.hasGenZAccess = false,
    this.qrPayload,
  });

  Map<String, dynamic> toJson() => {
        'ticketNumber': ticketNumber,
        'attendeeName': attendeeName,
        'category': category,
        'status': status,
        'hasGenZAccess': hasGenZAccess,
        'qrPayload': qrPayload,
      };

  factory OfflineTicket.fromJson(Map<String, dynamic> json) => OfflineTicket(
        ticketNumber: json['ticketNumber'] as String,
        attendeeName: json['attendeeName'] as String?,
        category: json['category'] as String?,
        status: json['status'] as String? ?? 'Issued',
        hasGenZAccess: json['hasGenZAccess'] as bool? ?? false,
        qrPayload: json['qrPayload'] as String?,
      );
}

class OfflineDinnerPass {
  final String passNumber;
  final String? recipientName;
  final String? batch;
  final String status;
  final String? qrPayload;

  OfflineDinnerPass({
    required this.passNumber,
    this.recipientName,
    this.batch,
    required this.status,
    this.qrPayload,
  });

  Map<String, dynamic> toJson() => {
        'passNumber': passNumber,
        'recipientName': recipientName,
        'batch': batch,
        'status': status,
        'qrPayload': qrPayload,
      };

  factory OfflineDinnerPass.fromJson(Map<String, dynamic> json) => OfflineDinnerPass(
        passNumber: json['passNumber'] as String,
        recipientName: json['recipientName'] as String?,
        batch: json['batch'] as String?,
        status: json['status'] as String? ?? 'Issued',
        qrPayload: json['qrPayload'] as String?,
      );
}
