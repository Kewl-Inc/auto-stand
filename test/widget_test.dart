import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:auto_stand/main.dart';

void main() {
  testWidgets('AutoStand app launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: AutoStandApp()));

    // Verify that the app title appears
    expect(find.text('🔧 AutoStand'), findsOneWidget);
    
    // Verify that the tagline appears
    expect(find.text('Kill your standup with AI-generated team digests'), findsOneWidget);
  });
}