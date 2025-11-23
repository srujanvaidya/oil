class BannerData {
  const BannerData({
    required this.id,
    required this.title,
    this.imageUrl,
    this.description,
  });

  final String id;
  final String title;
  final String? imageUrl;
  final String? description;
}

class BannerService {
  BannerService._();

  static final BannerService instance = BannerService._();

  Future<List<BannerData>> getTrendingBanners() async {
    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // Mock data - replace with real API call later
    return [
      const BannerData(
        id: '1',
        title: 'Trending OilSeeds / Data / Images',
        description: 'Discover the latest trends in oilseeds',
      ),
      const BannerData(
        id: '2',
        title: 'Featured Products',
        description: 'Check out our featured collection',
      ),
      const BannerData(
        id: '3',
        title: 'Special Offers',
        description: 'Limited time deals for farmers',
      ),
    ];
  }

  Future<BannerData?> getBannerById(String id) async {
    final banners = await getTrendingBanners();
    try {
      return banners.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }
}

