import 'package:fasalmitra/services/listing_service.dart';
import 'package:fasalmitra/widgets/home/product_listing_card.dart';
import 'package:flutter/material.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  static const String routeName = '/marketplace';

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  String _sortBy = 'distance';
  String? _categoryFilter;
  DateTime? _dateFrom;
  DateTime? _dateTo;
  late Future<List<ListingData>> _listingsFuture;

  final List<String> _categories = ['Seeds', 'Grains', 'Vegetables', 'Fruits'];
  final List<Map<String, String>> _sortOptions = [
    {'value': 'distance', 'label': 'Distance: Closest'},
    {'value': 'price_low', 'label': 'Price: Low to High'},
    {'value': 'price_high', 'label': 'Price: High to Low'},
    {'value': 'date_recent', 'label': 'Recently Listed'},
  ];

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check for arguments from navigation
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      var needsReload = false;

      if (args['category'] != null) {
        final category = args['category'] as String;
        if (_categoryFilter != category) {
          _categoryFilter = category;
          needsReload = true;
        }
      }

      if (args['sort'] != null) {
        final sort = args['sort'] as String;
        if (_sortBy != sort) {
          _sortBy = sort;
          needsReload = true;
        }
      }

      if (needsReload) {
        setState(() {});
        _loadListings();
      }
    }
  }

  void _loadListings() {
    setState(() {
      _listingsFuture = ListingService.instance.getMarketplaceListings(
        sortBy: _sortBy,
        categoryFilter: _categoryFilter,
        dateFrom: _dateFrom,
        dateTo: _dateTo,
      );
    });
  }

  void _showDateRangeFilter() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateFrom != null && _dateTo != null
          ? DateTimeRange(start: _dateFrom!, end: _dateTo!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _dateFrom = picked.start;
        _dateTo = picked.end;
      });
      _loadListings();
    }
  }

  void _clearFilters() {
    setState(() {
      _categoryFilter = null;
      _dateFrom = null;
      _dateTo = null;
    });
    _loadListings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_off),
            onPressed: _clearFilters,
            tooltip: 'Clear Filters',
          ),
        ],
      ),
      body: Column(
        children: [
          // Sorting and Filtering Controls
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Sort Dropdown
                Row(
                  children: [
                    const Icon(Icons.sort, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Sort by:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _sortBy,
                        isExpanded: true,
                        items: _sortOptions.map((option) {
                          return DropdownMenuItem<String>(
                            value: option['value'],
                            child: Text(option['label']!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _sortBy = value;
                            });
                            _loadListings();
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Filter Chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Category Filter
                    ..._categories.map((category) {
                      final isSelected = _categoryFilter == category;
                      return FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _categoryFilter = selected ? category : null;
                          });
                          _loadListings();
                        },
                      );
                    }),
                    // Date Range Filter
                    ActionChip(
                      avatar: const Icon(Icons.date_range, size: 18),
                      label: Text(
                        _dateFrom != null && _dateTo != null
                            ? 'Date: ${_dateFrom!.month}/${_dateFrom!.day} - ${_dateTo!.month}/${_dateTo!.day}'
                            : 'Filter by Date',
                      ),
                      onPressed: _showDateRangeFilter,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Listings Grid
          Expanded(
            child: FutureBuilder<List<ListingData>>(
              future: _listingsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                      ],
                    ),
                  );
                }

                final listings = snapshot.data ?? [];

                if (listings.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No listings found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 280,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: listings.length,
                  itemBuilder: (context, index) {
                    return ProductListingCard(
                      listing: listings[index],
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Viewing ${listings[index].title}'),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
