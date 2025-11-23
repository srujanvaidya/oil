import 'api.dart';

class ListingData {
  const ListingData({
    required this.id,
    required this.title,
    required this.price,
    required this.priceUnit,
    this.description,
    this.imageUrls = const [],
    this.sellerName,
    this.farmerProfileImage,
    this.category,
    this.rating,
    this.certificateGrade,
    this.isCertified = false,
    this.processingDate,
    this.quantity,
    this.quantityUnit,
    this.distance,
  });

  factory ListingData.fromJson(Map<String, dynamic> json) {
    return ListingData(
      id: json['id'] as String,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      priceUnit: json['priceUnit'] as String? ?? '/kg',
      description: json['description'] as String?,
      imageUrls:
          (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      sellerName: json['sellerName'] as String?,
      farmerProfileImage: json['farmerProfileImage'] as String?,
      category: json['category'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      certificateGrade: json['certificateGrade'] as String?,
      isCertified: json['isCertified'] as bool? ?? false,
      processingDate: json['processingDate'] != null
          ? DateTime.parse(json['processingDate'] as String)
          : null,
      quantity: (json['quantity'] as num?)?.toDouble(),
      quantityUnit: json['quantityUnit'] as String?,
      distance: (json['distance'] as num?)?.toDouble(),
    );
  }

  final String id;
  final String title;
  final double price;
  final String priceUnit; // e.g., "/kg", "/ton"
  final String? description;
  final List<String> imageUrls; // Multiple images for scrolling
  final String? sellerName;
  final String? farmerProfileImage;
  final String? category;
  final double? rating; // Rating out of 5
  final String? certificateGrade; // e.g., "Grade A", "Organic"
  final bool isCertified;
  final DateTime? processingDate;
  final double? quantity;
  final String? quantityUnit;
  final double? distance; // Distance in km from user
}

class ListingService {
  ListingService._();

  static final ListingService instance = ListingService._();

  Future<List<ListingData>> getRecentListings({int limit = 10}) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    return List.generate(
      limit,
      (i) => ListingData(
        id: 'listing_$i',
        title: 'Organic Wheat ${i + 1}',
        price: (i + 1) * 50.0,
        priceUnit: '/kg',
        description: 'High quality organic wheat',
        imageUrls: [
          'https://via.placeholder.com/300x200?text=Product+${i + 1}+Image+1',
          'https://via.placeholder.com/300x200?text=Product+${i + 1}+Image+2',
          if (i % 2 == 0)
            'https://via.placeholder.com/300x200?text=Product+${i + 1}+Image+3',
        ],
        sellerName: 'Farmer ${i + 1}',
        farmerProfileImage: 'https://via.placeholder.com/50?text=F${i + 1}',
        category: ['OilSeeds', 'Grains', 'Vegetables'][i % 3],
        rating: 3.5 + (i % 3) * 0.5,
        certificateGrade: ['Grade A', 'Organic', 'Premium'][i % 3],
        isCertified: i % 2 == 0,
        processingDate: DateTime.now().subtract(Duration(days: i)),
        quantity: (i + 1) * 100.0,
        quantityUnit: 'kg',
        distance: (i + 1) * 5.0 + (i % 3) * 2.5,
      ),
    );
  }

  Future<List<ListingData>> getListingsByCategory(String category) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    return List.generate(
      5,
      (i) => ListingData(
        id: 'cat_${category}_$i',
        title: '$category Product ${i + 1}',
        price: (i + 1) * 30.0,
        priceUnit: '/kg',
        imageUrls: [
          'https://via.placeholder.com/300x200?text=$category+${i + 1}',
        ],
        category: category,
        rating: 4.0,
        isCertified: true,
        quantity: 500.0,
        quantityUnit: 'kg',
        distance: (i + 1) * 3.0,
      ),
    );
  }

  Future<List<ListingData>> getMarketplaceListings({
    String sortBy = 'distance', // 'distance', 'price_high', 'price_low'
    String? categoryFilter,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{'sort': sortBy};
      if (categoryFilter != null && categoryFilter.isNotEmpty) {
        queryParams['category'] = categoryFilter;
      }
      if (dateFrom != null) {
        queryParams['date_from'] = dateFrom.toIso8601String();
      }
      if (dateTo != null) {
        queryParams['date_to'] = dateTo.toIso8601String();
      }

      // Call backend API
      final response = await ApiService.instance.get(
        '/api/listings/marketplace',
        queryParameters: queryParams,
      );

      // Parse response
      final listingsJson = response['listings'] as List<dynamic>?;
      if (listingsJson != null) {
        return listingsJson
            .map((json) => ListingData.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      // Fallback to mock data if API fails
      print('API call failed, using mock data: $e');
    }

    // Mock data fallback
    await Future<void>.delayed(const Duration(milliseconds: 500));

    var listings = List.generate(
      20,
      (i) => ListingData(
        id: 'market_$i',
        title: ['Wheat', 'Rice', 'Corn', 'Barley', 'Oats'][i % 5],
        price: 50.0 + (i * 10.0),
        priceUnit: '/kg',
        description: 'High quality product',
        imageUrls: [
          'https://via.placeholder.com/300x200?text=Product+${i + 1}',
        ],
        sellerName: 'Farmer ${i + 1}',
        category: ['Seeds', 'Grains', 'Vegetables', 'Fruits'][i % 4],
        rating: 3.0 + (i % 3) * 0.5,
        certificateGrade: ['Grade A', 'Organic', 'Premium'][i % 3],
        isCertified: i % 2 == 0,
        processingDate: DateTime.now().subtract(Duration(days: i * 2)),
        quantity: (i + 1) * 50.0,
        quantityUnit: 'kg',
        distance: 2.0 + (i * 3.5),
      ),
    );

    // Apply category filter
    if (categoryFilter != null && categoryFilter.isNotEmpty) {
      listings = listings
          .where((listing) => listing.category == categoryFilter)
          .toList();
    }

    // Apply date filter
    if (dateFrom != null) {
      listings = listings.where((listing) {
        return listing.processingDate != null &&
            listing.processingDate!.isAfter(dateFrom);
      }).toList();
    }
    if (dateTo != null) {
      listings = listings.where((listing) {
        return listing.processingDate != null &&
            listing.processingDate!.isBefore(dateTo);
      }).toList();
    }

    // Apply sorting
    switch (sortBy) {
      case 'distance':
        listings.sort((a, b) => (a.distance ?? 0).compareTo(b.distance ?? 0));
        break;
      case 'price_high':
        listings.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'price_low':
        listings.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'date_recent':
        listings.sort((a, b) {
          final dateA = a.processingDate ?? DateTime(2000);
          final dateB = b.processingDate ?? DateTime(2000);
          return dateB.compareTo(dateA); // Most recent first
        });
        break;
    }

    return listings;
  }

  Future<void> createListing({
    required String title,
    required String category,
    required double quantity,
    required double price,
    required DateTime processingDate,
    required String certificatePath,
    required String imagePath,
    required String location,
  }) async {
    // TODO: Implement actual backend integration
    // Endpoint: POST /api/listings/
    // Body: {
    //   "title": title,
    //   "category": category,
    //   "quantity": quantity,
    //   "price": price,
    //   "processing_date": processingDate.toIso8601String(),
    //   "location": location
    // }
    // Files: certificate, image

    await Future<void>.delayed(
      const Duration(seconds: 2),
    ); // Mock network delay
    print('Creating listing: $title, $category, $quantity, $price, $location');
  }
}
