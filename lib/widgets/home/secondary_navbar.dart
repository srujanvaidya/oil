import 'package:flutter/material.dart';

import 'package:fasalmitra/services/language_service.dart';

class SecondaryNavbar extends StatelessWidget {
  const SecondaryNavbar({
    super.key,
    this.onListProduct,
    this.onMarketplace,
    this.onRecentListings,
    this.onSearchByCategory,
  });

  final VoidCallback? onListProduct;
  final VoidCallback? onMarketplace;
  final VoidCallback? onRecentListings;
  final VoidCallback? onSearchByCategory;

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService.instance;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _NavItem(
                label: lang.t('listProduct'),
                onTap: onListProduct,
              ),
              _NavItem(
                label: lang.t('marketplace'),
                onTap: onMarketplace,
              ),
              _NavItem(
                label: lang.t('recentListings'),
                onTap: onRecentListings,
              ),
              _NavItem(
                label: lang.t('searchByCategory'),
                onTap: onSearchByCategory,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 24),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ),
    );
  }
}

