import 'package:flutter/material.dart';

import 'package:fasalmitra/services/listing_service.dart';
import 'package:fasalmitra/services/language_service.dart';

class ProductListingCard extends StatelessWidget {
  const ProductListingCard({super.key, required this.listing, this.onTap});

  final ListingData listing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrls = listing.imageUrls.isNotEmpty
        ? listing.imageUrls
        : ['https://via.placeholder.com/300x200?text=No+Image'];

    return ValueListenableBuilder<String>(
      valueListenable: LanguageService.instance.listenable,
      builder: (context, lang, child) {
        final t = LanguageService.instance.t;
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image carousel section
                _ProductImageCarousel(
                  imageUrls: imageUrls,
                  height: 150, // Reduced height to save space
                ),

                // Details section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Rating and certificate row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Rating stars
                            if (listing.rating != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ...List.generate(5, (index) {
                                    final isFilled =
                                        index < (listing.rating ?? 0).floor();
                                    final isHalf =
                                        (listing.rating ?? 0) -
                                            (listing.rating ?? 0).floor() >=
                                        0.5;
                                    if (index ==
                                            (listing.rating ?? 0).floor() &&
                                        isHalf) {
                                      return const Icon(
                                        Icons.star_half,
                                        size: 14,
                                        color: Colors.amber,
                                      );
                                    }
                                    return Icon(
                                      isFilled ? Icons.star : Icons.star_border,
                                      size: 14,
                                      color: Colors.amber,
                                    );
                                  }),
                                  const SizedBox(width: 4),
                                  Text(
                                    listing.rating!.toStringAsFixed(1),
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),

                            // Certified tick and grade
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (listing.isCertified) ...[
                                  const Icon(
                                    Icons.verified,
                                    size: 16,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                if (listing.certificateGrade != null)
                                  TextButton(
                                    onPressed: () {
                                      // Navigate to view certificate page
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Viewing Certificate...',
                                          ),
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                      // TODO: Implement actual navigation
                                      // Navigator.pushNamed(context, '/certificate', arguments: listing.id);
                                    },
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      backgroundColor: Colors.green.shade50,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                        side: BorderSide(
                                          color: Colors.green,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          listing.certificateGrade!,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: Colors.green.shade700,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 10,
                                              ),
                                        ),
                                        const SizedBox(width: 2),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 8,
                                          color: Colors.green.shade700,
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Title and Price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                listing.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '₹${listing.price.toStringAsFixed(0)}${listing.priceUnit}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Quantity
                        if (listing.quantity != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              '${t('qty')}: ${listing.quantity?.toStringAsFixed(0)} ${listing.quantityUnit ?? ''}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                        // Farmer Info
                        Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.5,
                                  ),
                                  width: 1,
                                ),
                                image: listing.farmerProfileImage != null
                                    ? DecorationImage(
                                        image: NetworkImage(
                                          listing.farmerProfileImage!,
                                        ),
                                        fit: BoxFit.cover,
                                        onError: (_, __) {},
                                      )
                                    : null,
                                color: listing.farmerProfileImage == null
                                    ? Colors.grey.shade300
                                    : null,
                              ),
                              child: listing.farmerProfileImage == null
                                  ? Icon(
                                      Icons.person,
                                      size: 16,
                                      color: Colors.grey.shade600,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    listing.sellerName ?? t('unknownFarmer'),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (listing.processingDate != null)
                                    Text(
                                      '${t('processed')}: ${_formatDate(listing.processingDate!)}',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            fontSize: 10,
                                            color: Colors.grey.shade600,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Buy Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigate to payment gateway
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Initiating Purchase...'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                            child: Text(t('buyNow')),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}

class _ProductImageCarousel extends StatefulWidget {
  const _ProductImageCarousel({required this.imageUrls, required this.height});

  final List<String> imageUrls;
  final double height;

  @override
  State<_ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<_ProductImageCarousel> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasMultipleImages = widget.imageUrls.length > 1;

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          // Image carousel
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index) {
              return Image.network(
                widget.imageUrls[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey.shade100,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              );
            },
          ),

          // Page indicators (only show if multiple images)
          if (hasMultipleImages)
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.imageUrls.length,
                  (index) => Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == index
                          ? Colors.white
                          : const Color.fromRGBO(255, 255, 255, 0.5),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
