import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_matrix/golden_matrix.dart';
import 'package:golden_matrix/src/api/matrix_test_runner.dart';

void main() {
  Widget placeholder() => const SizedBox();

  group('resolveCombinations', () {
    test('uses axes directly when no preset', () {
      final result = resolveCombinations(
        scenarios: [MatrixScenario('test', builder: placeholder)],
        axes: const MatrixAxes(
          themes: [MatrixTheme.light, MatrixTheme.dark],
          devices: [MatrixDevice.phoneSmall],
        ),
      );

      expect(result.length, 2);
    });

    test('uses preset axes when axes is null', () {
      final result = resolveCombinations(
        scenarios: [MatrixScenario('test', builder: placeholder)],
        preset: MatrixPreset.componentSmoke,
      );

      expect(result, isNotEmpty);
      // componentSmoke has light+dark themes, smoke sampling
    });

    test('explicit axes wins over preset', () {
      final result = resolveCombinations(
        scenarios: [MatrixScenario('test', builder: placeholder)],
        axes: const MatrixAxes(themes: [MatrixTheme.light], devices: [MatrixDevice.tablet]),
        preset: MatrixPreset.componentFull,
      );

      // All combinations should use tablet (from explicit axes)
      expect(result.every((c) => c.device == MatrixDevice.tablet), isTrue);
    });

    test('explicit sampling wins over preset', () {
      final full = resolveCombinations(
        scenarios: [MatrixScenario('test', builder: placeholder)],
        axes: const MatrixAxes(
          themes: [MatrixTheme.light, MatrixTheme.dark],
          locales: [Locale('en'), Locale('ar')],
        ),
        preset: MatrixPreset.componentSmoke, // smoke sampling
        sampling: MatrixSampling.full, // override to full
      );

      // full = 4 combos, smoke would be less
      expect(full.length, 4);
    });

    test('filters scenarios by tags', () {
      final result = resolveCombinations(
        scenarios: [
          MatrixScenario('a', builder: placeholder, tags: ['core']),
          MatrixScenario('b', builder: placeholder, tags: ['edge']),
          MatrixScenario('c', builder: placeholder, tags: ['core']),
        ],
        tags: ['core'],
      );

      expect(result.length, 2);
      expect(result.every((c) => c.scenario.name != 'b'), isTrue);
    });

    test('merges preset rules with explicit rules', () {
      final presetWithRule = MatrixPreset(
        axes: const MatrixAxes(themes: [MatrixTheme.light, MatrixTheme.dark]),
        rules: [MatrixRule.exclude((c) => c.theme == MatrixTheme.dark)],
      );

      final result = resolveCombinations(
        scenarios: [MatrixScenario('test', builder: placeholder)],
        preset: presetWithRule,
      );

      expect(result.length, 1);
      expect(result.first.theme, MatrixTheme.light);
    });

    test('defaults to MatrixAxes() when no axes and no preset', () {
      final result = resolveCombinations(scenarios: [MatrixScenario('test', builder: placeholder)]);

      expect(result.length, 1);
      expect(result.first.theme, MatrixTheme.light);
      expect(result.first.locale, const Locale('en'));
      expect(result.first.device, MatrixDevice.phoneSmall);
    });
  });

  group('groupByScenario', () {
    test('groups combinations by scenario name', () {
      final combos = MatrixGenerator.generate(
        scenarios: [
          MatrixScenario('alpha', builder: placeholder),
          MatrixScenario('beta', builder: placeholder),
        ],
        axes: const MatrixAxes(themes: [MatrixTheme.light, MatrixTheme.dark]),
      );

      final grouped = groupByScenario(combos);

      expect(grouped.keys, containsAll(['alpha', 'beta']));
      expect(grouped['alpha']!.length, 2);
      expect(grouped['beta']!.length, 2);
    });

    test('returns empty map for empty input', () {
      expect(groupByScenario([]), isEmpty);
    });

    test('single scenario produces one group', () {
      final combos = MatrixGenerator.generate(
        scenarios: [MatrixScenario('only', builder: placeholder)],
        axes: const MatrixAxes(
          themes: [MatrixTheme.light, MatrixTheme.dark],
          devices: [MatrixDevice.phoneSmall, MatrixDevice.tablet],
        ),
      );

      final grouped = groupByScenario(combos);

      expect(grouped.keys.length, 1);
      expect(grouped['only']!.length, 4);
    });
  });
}
