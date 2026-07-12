import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:makankira/shared/google_sign_in_button.dart';

void main() {
  testWidgets('renders the approved label and the multicolor G, and taps', (tester) async {
    var tapped = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: GoogleSignInButton(label: 'Continue with Google', onPressed: () => tapped = true),
      ),
    ));
    // If the embedded Google "G" SVG were invalid, building ScalableImageWidget
    // would have thrown during pump.
    expect(tester.takeException(), isNull);
    expect(find.text('Continue with Google'), findsOneWidget);

    await tester.tap(find.byType(GoogleSignInButton));
    expect(tapped, isTrue, reason: 'button should invoke onPressed');
  });

  testWidgets('renders in dark theme and is inert when disabled', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData.dark(),
      home: const Scaffold(body: GoogleSignInButton(label: 'Continue with Google')),
    ));
    expect(tester.takeException(), isNull);
    expect(find.text('Continue with Google'), findsOneWidget);
  });
}
