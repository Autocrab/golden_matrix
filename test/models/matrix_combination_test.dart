import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_matrix/golden_matrix.dart';

void main() {
  Widget placeholder() => const SizedBox();

  group('MatrixCombination', () {
    test('stores all fields correctly', () {
      final scenario = MatrixScenario('loading', builder: placeholder);
      const theme = MatrixTheme.dark;
      const locale = Locale('ru');
      const textScale = 2.0;
      const device = MatrixDevice.phoneLarge;
      const direction = TextDirection.ltr;

      final combo = MatrixCombination(
        scenario: scenario,
        theme: theme,
        locale: locale,
        textScale: textScale,
        device: device,
        direction: direction,
      );

      expect(combo.scenario.name, 'loading');
      expect(combo.theme.name, 'dark');
      expect(combo.locale, const Locale('ru'));
      expect(combo.textScale, 2.0);
      expect(combo.device.name, 'phoneLarge');
      expect(combo.direction, TextDirection.ltr);
    });

    test('toString provides readable output', () {
      final combo = MatrixCombination(
        scenario: MatrixScenario('test', builder: placeholder),
        theme: MatrixTheme.light,
        locale: const Locale('en'),
        textScale: 1.0,
        device: MatrixDevice.phoneSmall,
        direction: TextDirection.ltr,
      );

      final str = combo.toString();
      expect(str, contains('test'));
      expect(str, contains('light'));
      expect(str, contains('en'));
    });
  });

  group('MatrixScenario', () {
    test('slug is lowercased and sanitized', () {
      final scenario = MatrixScenario('Error State', builder: placeholder);
      expect(scenario.slug, 'error_state');
    });

    test('tags are preserved', () {
      final scenario = MatrixScenario('test', builder: placeholder, tags: ['error', 'network']);
      expect(scenario.tags, ['error', 'network']);
    });
  });

  group('MatrixTheme', () {
    test('light and dark have correct names', () {
      expect(MatrixTheme.light.name, 'light');
      expect(MatrixTheme.dark.name, 'dark');
    });

    test('custom theme stores ThemeData', () {
      final theme = MatrixTheme.custom('brand', ThemeData(primarySwatch: Colors.red));
      expect(theme.name, 'brand');
      expect(theme.themeData, isNotNull);
    });

    test('resolve returns correct ThemeData', () {
      expect(MatrixTheme.light.resolve().brightness, Brightness.light);
      expect(MatrixTheme.dark.resolve().brightness, Brightness.dark);
    });

    test('slug is sanitized', () {
      final theme = MatrixTheme.custom('My Theme!', ThemeData.light());
      expect(theme.slug, 'my_theme_');
    });
  });

  group('MatrixDevice', () {
    test('presets have correct sizes', () {
      expect(MatrixDevice.phoneSmall.logicalSize, const Size(375, 667));
      expect(MatrixDevice.phoneLarge.logicalSize, const Size(414, 896));
      expect(MatrixDevice.tablet.logicalSize, const Size(768, 1024));
    });

    test('slug is lowercased', () {
      expect(MatrixDevice.phoneSmall.slug, 'phonesmall');
      expect(MatrixDevice.androidMedium.slug, 'androidmedium');
    });
  });
}
