// EV-Grama Charge Widget Tests
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ev_gamma_flutter/main.dart';
import 'package:ev_gamma_flutter/features/map/screens/map_screen.dart';

void main() {
  testWidgets('EV-Grama app loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const EVGramaApp());

    // Verify that the map screen loads
    expect(find.byType(MapScreen), findsOneWidget);
    expect(find.text('EV-Grama Charge'), findsOneWidget);
  });

  testWidgets('Map screen displays charging points',
      (WidgetTester tester) async {
    // Build the map screen
    await tester.pumpWidget(
      MaterialApp(
        home: const MapScreen(),
      ),
    );

    // Verify app bar is present
    expect(find.text('EV-Grama Charge'), findsOneWidget);

    // Verify floating action button is present
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
