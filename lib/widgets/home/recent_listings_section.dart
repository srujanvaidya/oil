import 'package:flutter/material.dart';

import 'package:fasalmitra/services/listing_service.dart';
import 'package:fasalmitra/services/language_service.dart';
import 'package:fasalmitra/widgets/home/product_listing_card.dart';

class RecentListingsSection extends StatefulWidget {
  const RecentListingsSection({super.key});

  @override
  State<RecentListingsSection> createState() => _RecentListingsSectionState();
}

class _RecentListingsSectionState extends State<RecentListingsSection> {
  final ListingService _listingService = ListingService.instance;
  late Future<List<ListingData>> _listingsFuture;

  @override
  void initState() {
    super.initState();
    _listingsFuture = _listingService.getRecentListings(limit: 10);
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService.instance;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  lang.t('recentListings'),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to all listings page
                },
                child: Text(lang.t('viewAll')),
              ),
            ],
          ),
        ),

        // Listings horizontal scroll
        FutureBuilder<List<ListingData>>(
          future: _listingsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 360,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return SizedBox(
                height: 360,
                child: Center(
                  child: Text(
                    'Error loading listings',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.red,
                    ),
                  ),
                ),
              );
            }

            final listings = snapshot.data ?? [];

            if (listings.isEmpty) {
              return SizedBox(
                height: 360,
                child: Center(
                  child: Text(
                    'No listings available',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ),
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 900;
                final cardWidth = isWide ? 280.0 : 260.0;
                final minHeight = 360.0;

                // For web/wide screens, use a responsive grid/scroll
                if (isWide && listings.length <= 4) {
                  // Show as grid if few items
                  return SizedBox(
                    height: minHeight,
                    child: Row(
                      children: [
                        ...listings.map((listing) {
                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              constraints: BoxConstraints(
                                maxWidth: cardWidth,
                                minHeight: minHeight,
                              ),
                              child: ProductListingCard(
                                listing: listing,
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Viewing ${listing.title}'),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                }

                // Horizontal scroll for mobile or many items
                return SizedBox(
                  height: minHeight,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: listings.length,
                    itemBuilder: (context, index) {
                      return Container(
                        constraints: BoxConstraints(
                          minWidth: cardWidth,
                          maxWidth: cardWidth,
                        ),
                        margin: const EdgeInsets.only(right: 16),
                        child: ProductListingCard(
                          listing: listings[index],
                          onTap: () {
                            // TODO: Navigate to product details page
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Viewing ${listings[index].title}',
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
