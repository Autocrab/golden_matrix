import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../core/matrix_generator.dart';
import '../core/naming_strategy.dart';
import '../flutter/matrix_widget_wrapper.dart';
import '../flutter/pump_helpers.dart';
import '../models/matrix_axes.dart';
import '../models/matrix_combination.dart';
import '../models/matrix_preset.dart';
import '../models/matrix_rule.dart';
import '../models/matrix_sampling.dart';
import '../models/matrix_scenario.dart';

/// Creates a group of golden tests for each combination in the matrix.
///
/// This is the primary API for component-level golden testing.
/// The widget from each scenario is automatically wrapped in a [MaterialApp]
/// shell with the appropriate theme, locale, direction, and text scale.
///
/// Use [preset] for quick setup, or provide [axes] and [sampling] directly.
/// If both [preset] and [axes] are provided, [axes] wins.
///
/// Example:
/// ```dart
/// matrixGolden(
///   'PrimaryButton',
///   scenarios: [
///     MatrixScenario('default', builder: () => const PrimaryButton(label: 'OK')),
///     MatrixScenario('disabled', builder: () => const PrimaryButton(label: 'OK', enabled: false)),
///   ],
///   preset: MatrixPreset.componentSmoke,
/// );
/// ```
void matrixGolden(
  String name, {
  required List<MatrixScenario> scenarios,
  MatrixAxes? axes,
  MatrixPreset? preset,
  MatrixSampling? sampling,
  int? maxCombinations,
  List<MatrixRule> rules = const [],
  List<String>? tags,
  String Function(MatrixCombination)? fileNameBuilder,
  List<LocalizationsDelegate<dynamic>> extraLocalizationsDelegates = const [],
}) {
  final effectiveAxes = axes ?? preset?.axes ?? const MatrixAxes();
  final effectiveSampling =
      sampling ?? preset?.sampling ?? MatrixSampling.full;
  final effectiveRules = [...?preset?.rules, ...rules];

  // Filter scenarios by tags
  final filteredScenarios = tags != null
      ? scenarios.where((s) => s.tags.any((t) => tags.contains(t))).toList()
      : scenarios;

  final combinations = MatrixGenerator.generate(
    scenarios: filteredScenarios,
    axes: effectiveAxes,
    sampling: effectiveSampling,
    rules: effectiveRules,
    maxCombinations: maxCombinations,
  );

  // Group combinations by scenario for better output structure
  final byScenario = <String, List<MatrixCombination>>{};
  for (final c in combinations) {
    (byScenario[c.scenario.name] ??= []).add(c);
  }

  group('matrixGolden: $name', () {
    for (final entry in byScenario.entries) {
      group(entry.key, () {
        for (final combination in entry.value) {
          final goldenPath = fileNameBuilder != null
              ? fileNameBuilder(combination)
              : NamingStrategy.goldenPath(combination);

          testWidgets(
            _testDescription(combination),
            (WidgetTester tester) async {
              PumpHelpers.configureView(tester, combination.device);

              final widget = MatrixWidgetWrapper(
                combination: combination,
                extraLocalizationsDelegates: extraLocalizationsDelegates,
                child: combination.scenario.builder(),
              );

              await tester.pumpWidget(widget);
              await tester.pumpAndSettle();

              await expectLater(
                find.byType(MaterialApp),
                matchesGoldenFile(goldenPath),
              );

              PumpHelpers.resetView(tester);
            },
          );
        }
      });
    }
  });
}

String _testDescription(MatrixCombination c) {
  final dir = c.direction == TextDirection.ltr ? 'ltr' : 'rtl';
  return '${c.theme.name} ${c.locale} $dir ${c.textScale}x ${c.device.name}';
}
