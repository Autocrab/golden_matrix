import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_matrix/golden_matrix.dart';

void main() {
  Widget placeholder() => const SizedBox();

  group('MatrixRule', () {
    test('exclude rule has correct type', () {
      final rule = MatrixRule.exclude((c) => c.theme.name == 'dark');
      expect(rule.type, MatrixRuleType.exclude);
    });

    test('exclude predicate matches correctly', () {
      final rule = MatrixRule.exclude((c) => c.theme.name == 'dark');

      final darkCombo = MatrixCombination(
        scenario: MatrixScenario('test', builder: placeholder),
        theme: MatrixTheme.dark,
        locale: const Locale('en'),
        textScale: 1.0,
        device: MatrixDevice.phoneSmall,
        direction: TextDirection.ltr,
      );

      final lightCombo = MatrixCombination(
        scenario: MatrixScenario('test', builder: placeholder),
        theme: MatrixTheme.light,
        locale: const Locale('en'),
        textScale: 1.0,
        device: MatrixDevice.phoneSmall,
        direction: TextDirection.ltr,
      );

      expect(rule.predicate(darkCombo), isTrue);
      expect(rule.predicate(lightCombo), isFalse);
    });

    test('exclude rule for RTL + non-Arabic locale', () {
      final rule = MatrixRule.exclude(
        (c) => c.locale.languageCode != 'ar' && c.direction == TextDirection.rtl,
      );

      final enRtl = MatrixCombination(
        scenario: MatrixScenario('test', builder: placeholder),
        theme: MatrixTheme.light,
        locale: const Locale('en'),
        textScale: 1.0,
        device: MatrixDevice.phoneSmall,
        direction: TextDirection.rtl,
      );

      final arRtl = MatrixCombination(
        scenario: MatrixScenario('test', builder: placeholder),
        theme: MatrixTheme.light,
        locale: const Locale('ar'),
        textScale: 1.0,
        device: MatrixDevice.phoneSmall,
        direction: TextDirection.rtl,
      );

      expect(rule.predicate(enRtl), isTrue);  // excluded: en + RTL
      expect(rule.predicate(arRtl), isFalse);  // kept: ar + RTL
    });
  });
}
