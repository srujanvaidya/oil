import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fasalmitra/widgets/home/product_listing_card.dart';
import 'package:fasalmitra/services/listing_service.dart';
import 'package:fasalmitra/services/language_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await LanguageService.instance.init(prefs);
  });

  testWidgets('ProductListingCard renders correctly with all features', (
    WidgetTester tester,
  ) async {
    final listing = ListingData(
      id: '1',
      title: 'Test Product',
      price: 100,
      priceUnit: '/kg',
      sellerName: 'Test Farmer',
      isCertified: true,
      certificateGrade: 'Grade A',
      rating: 4.5,
      processingDate: DateTime.now(),
      imageUrls: ['https://via.placeholder.com/150'],
      quantity: 100,
      quantityUnit: 'kg',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ProductListingCard(listing: listing)),
      ),
    );

    // Verify Title and Price
    expect(find.text('Test Product'), findsOneWidget);
    expect(find.text('₹100/kg'), findsOneWidget);

    // Verify Quantity
    expect(find.text('Qty: 100 kg'), findsOneWidget);

    // Verify Farmer Name
    expect(find.text('Test Farmer'), findsOneWidget);

    // Verify Buy Button
    expect(find.text('Buy Now'), findsOneWidget);

    // Verify Grade
    expect(find.text('Grade A'), findsOneWidget);

    // Tap Buy Button
    await tester.tap(find.text('Buy Now'));
    await tester.pump(); // Start animation
    await tester.pump(const Duration(milliseconds: 500)); // Wait for snackbar
    expect(find.text('Initiating Purchase...'), findsOneWidget);

    // Tap Grade
    await tester.tap(find.byIcon(Icons.arrow_forward_ios));
    await tester.pump();
  });

  testWidgets('ProductListingCard updates with language change', (
    WidgetTester tester,
  ) async {
    final listing = ListingData(
      id: '1',
      title: 'Test Product',
      price: 100,
      priceUnit: '/kg',
      sellerName: 'Test Farmer',
      rating: 4.5,
      processingDate: DateTime.now(),
      imageUrls: ['https://via.placeholder.com/150'],
      quantity: 100,
      quantityUnit: 'kg',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ProductListingCard(listing: listing)),
      ),
    );

    // Initial English
    expect(find.text('Buy Now'), findsOneWidget);
    expect(find.text('Qty: 100 kg'), findsOneWidget);

    // Change to Hindi
    await LanguageService.instance.changeLanguage('hi');
    await tester.pumpAndSettle();

    // Verify Hindi
    expect(find.text('अभी खरीदें'), findsOneWidget);
    // Note: Qty label changes to 'मात्रा'
    expect(find.text('मात्रा: 100 kg'), findsOneWidget);
  });
}
