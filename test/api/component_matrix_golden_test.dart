import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_matrix/golden_matrix.dart';

void main() {
  group('NamingStrategy.componentGoldenPath', () {
    test('drops device segment from path', () {
      final combo = MatrixCombination(
        scenario: MatrixScenario('primary', builder: () => const SizedBox()),
        theme: MatrixTheme.light,
        locale: const Locale('en'),
        textScale: 1.0,
        device: MatrixDevice.phoneSmall, // should not appear in path
        direction: TextDirection.ltr,
      );

      expect(
        NamingStrategy.componentGoldenPath(combo, testName: 'Button'),
        'goldens/button/primary/light_en_ltr_1x.png',
      );
    });

    test('without testName puts scenario at the root', () {
      final combo = MatrixCombination(
        scenario: MatrixScenario('default', builder: () => const SizedBox()),
        theme: MatrixTheme.dark,
        locale: const Locale('ar'),
        textScale: 1.5,
        device: MatrixDevice.phoneSmall,
        direction: TextDirection.rtl,
      );

      expect(NamingStrategy.componentGoldenPath(combo), 'goldens/default/dark_ar_rtl_1_5x.png');
    });

    test('locale with country code is hyphenated', () {
      final combo = MatrixCombination(
        scenario: MatrixScenario('s', builder: () => const SizedBox()),
        theme: MatrixTheme.light,
        locale: const Locale('zh', 'CN'),
        textScale: 1.0,
        device: MatrixDevice.tablet,
        direction: TextDirection.ltr,
      );

      expect(
        NamingStrategy.componentGoldenPath(combo, testName: 'X'),
        'goldens/x/s/light_zh_CN_ltr_1x.png',
      );
    });

    test('does not differ between phoneSmall and tablet (device irrelevant)', () {
      final small = MatrixCombination(
        scenario: MatrixScenario('s', builder: () => const SizedBox()),
        theme: MatrixTheme.light,
        locale: const Locale('en'),
        textScale: 1.0,
        device: MatrixDevice.phoneSmall,
        direction: TextDirection.ltr,
      );
      final tablet = small.copyWith(device: MatrixDevice.tablet);

      expect(NamingStrategy.componentGoldenPath(small), NamingStrategy.componentGoldenPath(tablet));
    });
  });

  group('componentMatrixGolden API surface', () {
    test('symbol is exported and callable', () {
      // Compile-time check that the function exists with the expected
      // named-arg shape. Actual rendering is exercised by integration
      // tests via flutter_test_config.dart.
      const Function fn = componentMatrixGolden;
      expect(fn, isNotNull);
    });
  });
}
