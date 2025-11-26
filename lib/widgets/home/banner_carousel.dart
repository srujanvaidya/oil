import 'package:flutter/material.dart';

import 'package:fasalmitra/services/banner_service.dart';

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final BannerService _bannerService = BannerService.instance;
  late Future<List<BannerData>> _bannersFuture;

  @override
  void initState() {
    super.initState();
    _bannersFuture = _bannerService.getTrendingBanners();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BannerData>>(
      future: _bannersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
          return _buildPlaceholderBanner();
        }

        final banners = snapshot.data!;
        return SizedBox(
          height: 200,
          child: PageView.builder(
            itemCount: banners.length,
            itemBuilder: (context, index) {
              return _BannerCard(banner: banners[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderBanner() {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          'Trending OilSeeds / Data / Images',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.banner});

  final BannerData banner;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              banner.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (banner.description != null) ...[
              const SizedBox(height: 8),
              Text(
                banner.description!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

