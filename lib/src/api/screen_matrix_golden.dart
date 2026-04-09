import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../core/matrix_generator.dart';
import '../core/naming_strategy.dart';
import '../flutter/pump_helpers.dart';
import '../models/matrix_axes.dart';
import '../models/matrix_combination.dart';
import '../models/matrix_preset.dart';
import '../models/matrix_rule.dart';
import '../models/matrix_sampling.dart';
import '../models/matrix_scenario.dart';

/// A builder that receives a [MatrixCombination] and returns a fully
/// configured app widget (typically a [MaterialApp]).
typedef MatrixAppBuilder = Widget Function(MatrixCombination combination);

/// Creates a group of golden tests for full screens.
///
/// Unlike [matrixGolden], the user provides their own app shell via
/// [appBuilder], which receives the full [MatrixCombination] for
/// configuring theme, locale, and state.
///
/// Use [preset] for quick setup, or provide [axes] and [sampling] directly.
/// If both [preset] and [axes] are provided, [axes] wins.
///
/// Example:
/// ```dart
/// screenMatrixGolden(
///   'TransferScreen',
///   appBuilder: (combination) => MaterialApp(
///     theme: combination.theme.resolve(),
///     locale: combination.locale,
///     home: TransferScreen(),
///   ),
///   preset: MatrixPreset.screenSmoke,
/// );
/// ```
void screenMatrixGolden(
  String name, {
  required MatrixAppBuilder appBuilder,
  MatrixAxes? axes,
  MatrixPreset? preset,
  List<MatrixScenario>? states,
  MatrixSampling? sampling,
  int? maxCombinations,
  List<MatrixRule> rules = const [],
  List<String>? tags,
  String Function(MatrixCombination)? fileNameBuilder,
}) {
  final effectiveAxes = axes ?? preset?.axes ?? const MatrixAxes();
  final effectiveSampling =
      sampling ?? preset?.sampling ?? MatrixSampling.full;
  final effectiveRules = [...?preset?.rules, ...rules];

  var scenarios = states ??
      [MatrixScenario('default', builder: () => const SizedBox.shrink())];

  // Filter scenarios by tags
  if (tags != null) {
    scenarios =
        scenarios.where((s) => s.tags.any((t) => tags.contains(t))).toList();
  }

  final combinations = MatrixGenerator.generate(
    scenarios: scenarios,
    axes: effectiveAxes,
    sampling: effectiveSampling,
    rules: effectiveRules,
    maxCombinations: maxCombinations,
  );

  // Group combinations by scenario
  final byScenario = <String, List<MatrixCombination>>{};
  for (final c in combinations) {
    (byScenario[c.scenario.name] ??= []).add(c);
  }

  group('screenMatrixGolden: $name', () {
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

              final widget = appBuilder(combination);

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
