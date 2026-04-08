import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_matrix/golden_matrix.dart';

void main() {
  Widget placeholder() => const SizedBox();

  MatrixCombination makeCombination({
    String scenario = 'default',
    MatrixTheme theme = MatrixTheme.light,
    Locale locale = const Locale('en'),
    double textScale = 1.0,
    MatrixDevice device = MatrixDevice.phoneSmall,
    TextDirection direction = TextDirection.ltr,
  }) {
    return MatrixCombination(
      scenario: MatrixScenario(scenario, builder: placeholder),
      theme: theme,
      locale: locale,
      textScale: textScale,
      device: device,
      direction: direction,
    );
  }

  group('NamingStrategy', () {
    test('basic path format', () {
      final path = NamingStrategy.goldenPath(makeCombination());
      expect(path, 'goldens/default/light_en_ltr_1x_phonesmall.png');
    });

    test('dark theme in path', () {
      final path = NamingStrategy.goldenPath(
        makeCombination(theme: MatrixTheme.dark),
      );
      expect(path, 'goldens/default/dark_en_ltr_1x_phonesmall.png');
    });

    test('RTL direction in path', () {
      final path = NamingStrategy.goldenPath(
        makeCombination(
          locale: const Locale('ar'),
          direction: TextDirection.rtl,
        ),
      );
      expect(path, 'goldens/default/light_ar_rtl_1x_phonesmall.png');
    });

    test('text scale 2.0 formatted as 2x', () {
      final path = NamingStrategy.goldenPath(
        makeCombination(textScale: 2.0),
      );
      expect(path, contains('_2x_'));
    });

    test('text scale 1.3 formatted as 1_3x', () {
      final path = NamingStrategy.goldenPath(
        makeCombination(textScale: 1.3),
      );
      expect(path, contains('_1_3x_'));
    });

    test('locale with country code', () {
      final path = NamingStrategy.goldenPath(
        makeCombination(locale: const Locale('en', 'US')),
      );
      expect(path, contains('_en_US_'));
    });

    test('different device in path', () {
      final path = NamingStrategy.goldenPath(
        makeCombination(device: MatrixDevice.tablet),
      );
      expect(path, 'goldens/default/light_en_ltr_1x_tablet.png');
    });

    test('scenario name in directory', () {
      final path = NamingStrategy.goldenPath(
        makeCombination(scenario: 'loading'),
      );
      expect(path, startsWith('goldens/loading/'));
    });

    test('custom theme name is slugified', () {
      final customTheme = MatrixTheme.custom('My Theme', ThemeData.light());
      final path = NamingStrategy.goldenPath(
        makeCombination(theme: customTheme),
      );
      expect(path, contains('my_theme'));
    });
  });

  group('formatTextScale', () {
    test('integer scales', () {
      expect(NamingStrategy.formatTextScale(1.0), '1x');
      expect(NamingStrategy.formatTextScale(2.0), '2x');
      expect(NamingStrategy.formatTextScale(3.0), '3x');
    });

    test('fractional scales', () {
      expect(NamingStrategy.formatTextScale(1.3), '1_3x');
      expect(NamingStrategy.formatTextScale(1.5), '1_5x');
      expect(NamingStrategy.formatTextScale(0.8), '0_8x');
    });
  });
}
