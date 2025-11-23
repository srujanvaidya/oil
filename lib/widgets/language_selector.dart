import 'package:flutter/material.dart';

import 'package:fasalmitra/services/language_service.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({
    super.key,
    this.compact = false,
    this.iconColor,
    this.textColor,
  });

  final bool compact;
  final Color? iconColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final service = LanguageService.instance;
    return ValueListenableBuilder<String>(
      valueListenable: service.listenable,
      builder: (context, current, _) {
        final dropdown = DropdownButton<String>(
          value: current,
          underline: const SizedBox.shrink(),
          focusColor: Colors.transparent,
          dropdownColor: Colors.white,
          style: TextStyle(color: textColor ?? Colors.black87),
          selectedItemBuilder: (context) {
            return LanguageService.supportedLanguages.map((lang) {
              return Text(
                lang['label'] ?? lang['code']!,
                style: TextStyle(color: textColor ?? Colors.black87),
              );
            }).toList();
          },
          items: LanguageService.supportedLanguages
              .map(
                (lang) => DropdownMenuItem<String>(
                  value: lang['code'],
                  child: Text(lang['label'] ?? lang['code']!),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              service.changeLanguage(value);
            }
          },
        );

        if (compact) {
          // For compact mode, show icon + text
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.language,
                color: iconColor ?? Colors.white,
                size: 20,
              ),
              const SizedBox(width: 4),
              dropdown,
            ],
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: dropdown,
        );
      },
    );
  }
}
