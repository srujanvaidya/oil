import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'language_service.dart';

class TipService {
  TipService._();

  static final TipService instance = TipService._();

  final ValueNotifier<String> _tipNotifier = ValueNotifier<String>('');
  Map<String, List<String>> _tipsByLang = {};
  int _currentIndex = 0;
  Timer? _timer;

  static const Map<String, List<String>> _fallbackTips = {
    'en': ['Use certified seeds to improve germination rates.'],
  };

  ValueListenable<String> get listenable => _tipNotifier;

  Future<void> init() async {
    try {
      final raw = await rootBundle.loadString('assets/data/farmer_tips.json');
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _tipsByLang = decoded.map(
        (key, value) => MapEntry(
          key,
          (value as List<dynamic>).map((e) => e.toString()).toList(),
        ),
      );
    } catch (_) {
      _tipsByLang = _fallbackTips;
    }

    _setTipFor(LanguageService.instance.currentLanguage);
    LanguageService.instance.listenable.addListener(_handleLanguageChange);

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 8), (_) {
      _advanceTip();
    });
  }

  void _handleLanguageChange() {
    _currentIndex = 0;
    _setTipFor(LanguageService.instance.currentLanguage);
  }

  void _advanceTip() {
    final lang = LanguageService.instance.currentLanguage;
    final tips = _tipsByLang[lang] ?? _tipsByLang['en'] ?? const [];
    if (tips.isEmpty) return;
    _currentIndex = (_currentIndex + 1) % tips.length;
    _tipNotifier.value = tips[_currentIndex];
  }

  void _setTipFor(String lang) {
    final tips = _tipsByLang[lang] ?? _tipsByLang['en'] ?? const [];
    if (tips.isEmpty) {
      _tipNotifier.value = '';
      return;
    }
    _tipNotifier.value = tips[_currentIndex % tips.length];
  }

  void dispose() {
    _timer?.cancel();
    LanguageService.instance.listenable.removeListener(_handleLanguageChange);
  }
}
