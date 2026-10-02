class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.vishwadharma.org';
  static const String apiVersion = '/api/v1';

  // Auth
  static const String login = '$apiVersion/auth/login';
  static const String logout = '$apiVersion/auth/logout';
  static const String refresh = '$apiVersion/auth/refresh';
  static const String me = '$apiVersion/auth/me';
  static const String revokeSessions = '$apiVersion/auth/sessions/revoke';

  // Tickets
  static const String tickets = '$apiVersion/tickets';
  static const String ticketByNumber = '$apiVersion/tickets/number';
  static const String ticketScans = '$apiVersion/ticket-scans';
  static const String ticketScansSync = '$apiVersion/ticket-scans/sync';

  // Scanner
  static const String scannerEnrol = '$apiVersion/scanner/enrol';
  static const String scannerDevice = '$apiVersion/scanner/device';
  static const String scannerRotate = '$apiVersion/scanner/device/rotate';
  static const String scannerTickets = '$apiVersion/scanner/tickets';
  static const String scannerTicketScan = '$apiVersion/scanner/tickets/scan';
  static const String scannerGenZScan = '$apiVersion/scanner/genz/scan';
  static const String scannerDinnerPasses = '$apiVersion/scanner/dinner-passes';
  static const String scannerDinnerScan = '$apiVersion/scanner/dinner-passes/scan';
  static const String scannerSync = '$apiVersion/scanner/sync';

  // Corporate Dinner Passes
  static const String dinnerPasses = '$apiVersion/corporate-dinner-passes';
  static const String dinnerPassScans = '$apiVersion/corporate-dinner-passes/scans';

  // Reference Data
  static const String gates = '$apiVersion/gates';
  static const String ticketCategories = '$apiVersion/ticket-categories';

  // Scans
  static const String recentScans = '$apiVersion/scans/recent';

  // Timeouts (ms)
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 30000;

  // Pagination
  static const int defaultPageSize = 100;
}
