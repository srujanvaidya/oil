import 'package:flutter/material.dart';

import 'package:fasalmitra/services/language_service.dart';

class FeatureCardGrid extends StatelessWidget {
  const FeatureCardGrid({
    super.key,
    this.onListProduct,
    this.onQualityCheck,
    this.onSearchSeeds,
  });

  final VoidCallback? onListProduct;
  final VoidCallback? onQualityCheck;
  final VoidCallback? onSearchSeeds;

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService.instance;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: isWide
              ? Row(
                  children: [
                    Expanded(
                      child: _FeatureCard(
                        title: lang.t('listProduct'),
                        icon: Icons.add_circle_outline,
                        onTap: onListProduct,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _FeatureCard(
                        title: lang.t('qualityCheck'),
                        icon: Icons.verified_outlined,
                        onTap: onQualityCheck,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _FeatureCard(
                        title: lang.t('searchSeeds'),
                        icon: Icons.search,
                        onTap: onSearchSeeds,
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _FeatureCard(
                      title: lang.t('listProduct'),
                      icon: Icons.add_circle_outline,
                      onTap: onListProduct,
                    ),
                    const SizedBox(height: 16),
                    _FeatureCard(
                      title: lang.t('qualityCheck'),
                      icon: Icons.verified_outlined,
                      onTap: onQualityCheck,
                    ),
                    const SizedBox(height: 16),
                    _FeatureCard(
                      title: lang.t('searchSeeds'),
                      icon: Icons.search,
                      onTap: onSearchSeeds,
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.icon,
    this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 48,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

