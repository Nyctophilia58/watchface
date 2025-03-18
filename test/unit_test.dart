import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:watchface/pages/watchface.dart';

// Mock class for HTTP requests
class MockClient extends Mock implements http.Client {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  group('WatchFace Widget Tests', () {
    testWidgets('Displays initial time correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: WatchFace()));
      expect(find.textContaining(':'), findsOneWidget);
    });

    testWidgets('Toggles between English and Bengali', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: WatchFace()));
      expect(find.text('English'), findsOneWidget);
      await tester.tap(find.byType(CupertinoSwitch));
      await tester.pump();
      expect(find.text('বাংলা'), findsOneWidget);
    });

    testWidgets('Fetches temperature successfully', (WidgetTester tester) async {
      final client = MockClient();
      when(client.get(Uri.parse('https://api.example.com/weather'))).thenAnswer(
            (_) async => http.Response(json.encode({'main': {'temp': 25}}), 200),
      );

      await tester.pumpWidget(const MaterialApp(home: WatchFace()));
      await tester.pump();
      expect(find.textContaining('°C'), findsOneWidget);
    });

    testWidgets('Timezone change updates time', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: WatchFace()));
      final initialTime = find.textContaining(':');
      await tester.tap(find.byType(DropdownButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Europe/London').last);
      await tester.pump();
      expect(find.textContaining(':'), isNot(initialTime));
    });

    testWidgets('12-hour / 24-hour format toggle works', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: WatchFace()));
      final initialFormat = find.textContaining('AM');
      final initialFormatPM = find.textContaining('PM');

      expect(initialFormat, findsOneWidget);
      expect(initialFormatPM, findsOneWidget);

      await tester.tap(find.byType(TextButton));
      await tester.pump();

      expect(find.textContaining('AM'), isNot(initialFormat));
      expect(find.textContaining('PM'), isNot(initialFormatPM));
    });

    testWidgets('Weather icon updates based on temperature', (WidgetTester tester) async {
      final client = MockClient();
      when(client.get(Uri.parse('https://api.example.com/weather'))).thenAnswer((_) async => http.Response(json.encode({
        'main': {'temp': 5}
      }), 200));

      await tester.pumpWidget(const MaterialApp(home: WatchFace()));
      await tester.pump();
      expect(find.byIcon(Icons.ac_unit), findsOneWidget);
    });

    testWidgets('Handles API failure gracefully', (WidgetTester tester) async {
      final client = MockClient();
      when(client.get(Uri.parse('https://api.example.com/weather'))).thenAnswer((_) async => http.Response('Error', 404));

      await tester.pumpWidget(const MaterialApp(home: WatchFace()));
      await tester.pump();
      expect(find.text('...'), findsOneWidget);
    });
  });
}
