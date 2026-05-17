import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_matrix/golden_matrix.dart';

void main() {
  Widget placeholder() => const SizedBox();

  group('previewMatrixGolden', () {
    test('basic counts with default axes', () {
      final preview = previewMatrixGolden(
        name: 'MyButton',
        scenarios: [MatrixScenario('default', builder: placeholder)],
      );

      expect(preview.name, 'MyButton');
      expect(preview.rawCount, 1);
      expect(preview.afterRulesCount, 1);
      expect(preview.afterSamplingCount, 1);
      expect(preview.combinations.length, 1);
      expect(preview.goldenPaths.length, 1);
      expect(preview.duplicatePaths, isEmpty);
    });

    test('Cartesian math matches axis multiplication', () {
      final preview = previewMatrixGolden(
        name: 'MyButton',
        scenarios: [MatrixScenario('default', builder: placeholder)],
        axes: const MatrixAxes(
          themes: [MatrixTheme.light, MatrixTheme.dark],
          locales: [Locale('en'), Locale('ru'), Locale('ar')],
          textScales: [1.0, 2.0],
        ),
      );

      // 1 scenario × 2 themes × 3 locales × 2 textScales × 1 device × 1 direction = 12
      expect(preview.rawCount, 12);
      expect(preview.afterRulesCount, 12);
      expect(preview.afterSamplingCount, 12);
    });

    test('rules reduce afterRulesCount', () {
      final preview = previewMatrixGolden(
        name: 'Buttons',
        scenarios: [MatrixScenario('default', builder: placeholder)],
        axes: const MatrixAxes(
          themes: [MatrixTheme.light, MatrixTheme.dark],
          locales: [Locale('en'), Locale('ru')],
        ),
        rules: [MatrixRule.exclude((c) => c.theme == MatrixTheme.dark)],
      );

      expect(preview.rawCount, 4);
      expect(preview.afterRulesCount, 2);
      expect(preview.afterSamplingCount, 2);
    });

    test('sampling reduces afterSamplingCount', () {
      final preview = previewMatrixGolden(
        name: 'Buttons',
        scenarios: [MatrixScenario('default', builder: placeholder)],
        axes: const MatrixAxes(
          themes: [MatrixTheme.light, MatrixTheme.dark],
          locales: [Locale('en'), Locale('ru'), Locale('ar')],
          textScales: [1.0, 1.5, 2.0],
          devices: [MatrixDevice.phoneSmall, MatrixDevice.tablet],
        ),
        sampling: MatrixSampling.pairwise,
      );

      expect(preview.rawCount, 36);
      expect(preview.afterRulesCount, 36);
      expect(preview.afterSamplingCount, lessThan(preview.afterRulesCount));
    });

    test('scenarioTags filtering shrinks rawCount', () {
      final preview = previewMatrixGolden(
        name: 'Buttons',
        scenarios: [
          MatrixScenario('a', builder: placeholder, tags: ['core']),
          MatrixScenario('b', builder: placeholder, tags: ['edge']),
          MatrixScenario('c', builder: placeholder, tags: ['core']),
        ],
        scenarioTags: ['core'],
      );

      expect(preview.rawCount, 2);
      expect(preview.combinations.every((c) => c.scenario.name != 'b'), isTrue);
    });

    test('golden paths match runner format', () {
      final preview = previewMatrixGolden(
        name: 'My Button',
        scenarios: [MatrixScenario('Default State', builder: placeholder)],
      );

      expect(preview.goldenPaths.single, startsWith('goldens/my_button/default_state/'));
      expect(preview.goldenPaths.single, endsWith('.png'));
    });

    test('fileNameBuilder override is used', () {
      final preview = previewMatrixGolden(
        name: 'MyButton',
        scenarios: [MatrixScenario('default', builder: placeholder)],
        fileNameBuilder: (c) => 'custom/${c.scenario.name}.png',
      );

      expect(preview.goldenPaths.single, 'custom/default.png');
    });

    test('duplicate paths are detected', () {
      var counter = 0;
      final preview = previewMatrixGolden(
        name: 'MyButton',
        scenarios: [MatrixScenario('default', builder: placeholder)],
        axes: const MatrixAxes(themes: [MatrixTheme.light, MatrixTheme.dark]),
        fileNameBuilder: (c) {
          counter++;
          return 'goldens/collision.png';
        },
      );

      expect(counter, 2);
      expect(preview.duplicatePaths, ['goldens/collision.png']);
    });

    test('no duplicates yields empty list', () {
      final preview = previewMatrixGolden(
        name: 'MyButton',
        scenarios: [MatrixScenario('default', builder: placeholder)],
        axes: const MatrixAxes(themes: [MatrixTheme.light, MatrixTheme.dark]),
      );

      expect(preview.duplicatePaths, isEmpty);
    });

    test('toString contains key sections', () {
      final preview = previewMatrixGolden(
        name: 'MyButton',
        scenarios: [
          MatrixScenario('default', builder: placeholder),
          MatrixScenario('loading', builder: placeholder),
        ],
        axes: const MatrixAxes(themes: [MatrixTheme.light, MatrixTheme.dark]),
      );

      final s = preview.toString();
      expect(s, contains('MyButton'));
      expect(s, contains('Scenarios: 2'));
      expect(s, contains('default'));
      expect(s, contains('loading'));
      expect(s, contains('Raw combinations: 4'));
      expect(s, contains('After rules: 4'));
      expect(s, contains('After sampling (full): 4'));
      expect(s, contains('goldens/mybutton/'));
    });

    test('toString includes duplicates section when collisions exist', () {
      final preview = previewMatrixGolden(
        name: 'MyButton',
        scenarios: [MatrixScenario('default', builder: placeholder)],
        axes: const MatrixAxes(themes: [MatrixTheme.light, MatrixTheme.dark]),
        fileNameBuilder: (c) => 'goldens/collision.png',
      );

      final s = preview.toString();
      expect(s, contains('duplicate path'));
      expect(s, contains('goldens/collision.png'));
    });

    test('preset is honored when axes is null', () {
      final preview = previewMatrixGolden(
        name: 'MyButton',
        scenarios: [MatrixScenario('default', builder: placeholder)],
        preset: MatrixPreset.componentSmoke,
      );

      expect(preview.afterSamplingCount, greaterThan(0));
    });

    test('maxCombinations caps the final count', () {
      final preview = previewMatrixGolden(
        name: 'MyButton',
        scenarios: [MatrixScenario('default', builder: placeholder)],
        axes: const MatrixAxes(
          themes: [MatrixTheme.light, MatrixTheme.dark],
          locales: [Locale('en'), Locale('ru'), Locale('ar')],
        ),
        maxCombinations: 3,
      );

      expect(preview.rawCount, 6);
      expect(preview.afterSamplingCount, 3);
    });

    test('samplingLabel reflects effective sampling', () {
      final preview = previewMatrixGolden(
        name: 'MyButton',
        scenarios: [MatrixScenario('default', builder: placeholder)],
        sampling: MatrixSampling.pairwise,
      );

      expect(preview.samplingLabel, 'pairwise');
    });
  });
}
