import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/services/quran_page_theme_service.dart';

void main() {
  group('QuranPageThemeService readability palettes', () {
    test('paper theme uses crisp dark ink instead of glowing gold', () {
      expect(
        QuranPageThemeService.text(QuranPageTheme.paper),
        const Color(0xFF3B2B1C),
      );
      expect(
        QuranPageThemeService.background(QuranPageTheme.paper),
        const Color(0xFFF8F1E4),
      );
    });

    test('pearl theme provides a neutral high-contrast reading surface', () {
      expect(
        QuranPageThemeService.background(QuranPageTheme.pearl),
        const Color(0xFFF8F7F2),
      );
      expect(
        QuranPageThemeService.text(QuranPageTheme.pearl),
        const Color(0xFF252525),
      );
      expect(
        QuranPageThemeService.text(QuranPageTheme.pearl).computeLuminance(),
        lessThan(QuranPageThemeService.background(QuranPageTheme.pearl).computeLuminance()),
      );
    });

    test('amber theme keeps a restrained warm text color on a dark surface', () {
      expect(
        QuranPageThemeService.background(QuranPageTheme.amber),
        const Color(0xFF101010),
      );
      expect(
        QuranPageThemeService.text(QuranPageTheme.amber),
        const Color(0xFFF2C879),
      );
    });

    test('all themes expose a label and readable foreground/background pair', () {
      for (final theme in QuranPageTheme.values) {
        expect(QuranPageThemeService.label(theme), isNotEmpty);
        expect(
          QuranPageThemeService.text(theme).computeLuminance() ==
              QuranPageThemeService.background(theme).computeLuminance(),
          isFalse,
        );
      }
    });
  });
}
