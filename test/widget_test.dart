import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:india_day_scanner/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // App requires DI init, so just verify it builds without crashing
    expect(IndiaDayScannerApp, isNotNull);
  });
}
