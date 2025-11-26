import 'package:flutter/foundation.dart';

class FontSizeService {
  FontSizeService._();

  static final FontSizeService instance = FontSizeService._();

  static const double _defaultSize = 1.0;
  static const double _minSize = 0.8;
  static const double _maxSize = 1.5;
  static const double _step = 0.1;

  final ValueNotifier<double> _fontScaleNotifier =
      ValueNotifier<double>(_defaultSize);

  ValueListenable<double> get listenable => _fontScaleNotifier;

  double get currentScale => _fontScaleNotifier.value;

  void increase() {
    final newSize = (_fontScaleNotifier.value + _step).clamp(_minSize, _maxSize);
    _fontScaleNotifier.value = newSize;
  }

  void decrease() {
    final newSize = (_fontScaleNotifier.value - _step).clamp(_minSize, _maxSize);
    _fontScaleNotifier.value = newSize;
  }

  void reset() {
    _fontScaleNotifier.value = _defaultSize;
  }
}

