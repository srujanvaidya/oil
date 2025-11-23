import 'package:fasalmitra/screens/create_listing_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CreateListingScreen renders all fields and validates input', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: CreateListingScreen()));

    // Verify fields exist
    expect(find.text('List New Product'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Product Name'), findsOneWidget);
    expect(find.text('Processing Date (mm/dd/yyyy)'), findsOneWidget);
    expect(find.text('Amount (kg)'), findsOneWidget);
    expect(find.text('Price per kg (INR)'), findsOneWidget);
    expect(find.text('Certificate (PDF)'), findsOneWidget);
    expect(find.text('Product Image'), findsOneWidget);
    expect(find.text('Location'), findsOneWidget);

    // Tap Create Listing to trigger validation
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -500),
    );
    await tester.pump();
    await tester.tap(find.text('Create Listing'));
    await tester.pump();

    // Verify validation errors
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, 500),
    ); // Scroll back up
    await tester.pump();
    expect(find.text('Please select a category'), findsOneWidget);
    expect(find.text('Please enter product name'), findsOneWidget);
    expect(find.text('Please select a date'), findsOneWidget);
    expect(find.text('Please enter quantity'), findsOneWidget);
    expect(find.text('Please enter price'), findsOneWidget);

    // Fill form
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Seeds').last);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Product Name'),
      'Test Seeds',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Amount (kg)'),
      '100',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Price per kg (INR)'),
      '50',
    );

    // Pick Date
    await tester.tap(
      find.widgetWithText(TextFormField, 'Processing Date (mm/dd/yyyy)'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Scroll down for files
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -300),
    );
    await tester.pump();

    // Mock File Picking (Certificate)
    await tester.tap(find.widgetWithText(OutlinedButton, 'Choose File').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Select Mock File'));
    await tester.pumpAndSettle();
    expect(find.text('mock_certificate.pdf'), findsOneWidget);

    // Mock File Picking (Image)
    await tester.tap(find.widgetWithText(OutlinedButton, 'Choose File').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Select Mock File'));
    await tester.pumpAndSettle();
    expect(find.text('mock_image.jpg'), findsOneWidget);

    // Mock Location
    await tester.ensureVisible(find.text('Get Location'));
    await tester.tap(find.text('Get Location'));
    await tester.pump(); // Start loading
    await tester.pump(const Duration(seconds: 1)); // Wait for mock delay
    await tester.pump(); // Update UI
    expect(find.text('12.9716° N, 77.5946° E (Bangalore)'), findsOneWidget);

    // Submit
    await tester.ensureVisible(find.text('Create Listing'));
    await tester.tap(find.text('Create Listing'));
    await tester.pump(); // Start loading
    await tester.pump(
      const Duration(seconds: 2),
    ); // Wait for mock network delay
    await tester.pumpAndSettle(); // Wait for snackbar and navigation

    // Verify navigation (screen popped)
    expect(find.text('List New Product'), findsNothing);
  });
}
