import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/services/quran_page_theme_service.dart';

double _contrastRatio(Color foreground, Color background) {
  final a = foreground.computeLuminance();
  final b = background.computeLuminance();
  final lighter = a > b ? a : b;
  final darker = a > b ? b : a;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  test('Quran text gold remains readable on every Mushaf page theme', () {
    for (final theme in QuranPageTheme.values) {
      final ratio = _contrastRatio(
        QuranPageThemeService.text(theme),
        QuranPageThemeService.background(theme),
      );
      expect(
        ratio,
        greaterThanOrEqualTo(4.5),
        reason: 'Insufficient text contrast for ${QuranPageThemeService.label(theme)}: $ratio',
      );
    }
  });
}
