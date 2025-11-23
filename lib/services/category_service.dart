class CategoryData {
  const CategoryData({
    required this.id,
    required this.name,
    this.icon,
    this.description,
  });

  final String id;
  final String name;
  final String? icon;
  final String? description;
}

class CategoryService {
  CategoryService._();

  static final CategoryService instance = CategoryService._();

  Future<List<CategoryData>> getAllCategories() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    return const [
      CategoryData(id: '1', name: 'OilSeeds'),
      CategoryData(id: '2', name: 'Grains'),
      CategoryData(id: '3', name: 'Vegetables'),
      CategoryData(id: '4', name: 'Fruits'),
      CategoryData(id: '5', name: 'Spices'),
      CategoryData(id: '6', name: 'Pulses'),
      CategoryData(id: '7', name: 'Dairy'),
      CategoryData(id: '8', name: 'Nuts'),
    ];
  }

  Future<CategoryData?> getCategoryById(String id) async {
    final categories = await getAllCategories();
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}

