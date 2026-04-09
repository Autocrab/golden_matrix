import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_matrix/golden_matrix.dart';

void main() {
  Widget placeholder() => const SizedBox();

  MatrixCombination makeCombination({
    String scenario = 'default',
    MatrixTheme theme = MatrixTheme.light,
    Locale locale = const Locale('en'),
  }) {
    return MatrixCombination(
      scenario: MatrixScenario(scenario, builder: placeholder),
      theme: theme,
      locale: locale,
      textScale: 1.0,
      device: MatrixDevice.phoneSmall,
      direction: TextDirection.ltr,
    );
  }

  group('MatrixCombinationResult.toJson', () {
    test('serializes all fields', () {
      final result = MatrixCombinationResult(
        combination: makeCombination(),
        status: MatrixResultStatus.passed,
        goldenPath: 'goldens/default/light_en_ltr_1x_phonesmall.png',
      );

      final json = result.toJson();
      expect(json['scenario'], 'default');
      expect(json['theme'], 'light');
      expect(json['locale'], 'en');
      expect(json['textScale'], 1.0);
      expect(json['device'], 'phoneSmall');
      expect(json['direction'], 'ltr');
      expect(json['status'], 'passed');
      expect(json['goldenPath'], contains('goldens/'));
      expect(json.containsKey('error'), isFalse);
    });

    test('includes error when present', () {
      final result = MatrixCombinationResult(
        combination: makeCombination(),
        status: MatrixResultStatus.failed,
        goldenPath: 'goldens/test.png',
        errorMessage: 'Golden file mismatch',
      );

      final json = result.toJson();
      expect(json['status'], 'failed');
      expect(json['error'], 'Golden file mismatch');
    });
  });

  group('MatrixResult.toJson', () {
    test('serializes with counts', () {
      final result = MatrixResult(
        name: 'TestWidget',
        results: [
          MatrixCombinationResult(
            combination: makeCombination(),
            status: MatrixResultStatus.passed,
            goldenPath: 'goldens/test1.png',
          ),
          MatrixCombinationResult(
            combination: makeCombination(theme: MatrixTheme.dark),
            status: MatrixResultStatus.failed,
            goldenPath: 'goldens/test2.png',
            errorMessage: 'mismatch',
          ),
        ],
        duration: const Duration(seconds: 5),
      );

      final json = result.toJson();
      expect(json['name'], 'TestWidget');
      expect(json['total'], 2);
      expect(json['passed'], 1);
      expect(json['failed'], 1);
      expect(json['skipped'], 0);
      expect(json['durationMs'], 5000);
      expect(json['timestamp'], isNotNull);
      expect(json['results'], isList);
      expect((json['results'] as List).length, 2);
    });
  });
}
