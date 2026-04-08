import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../core/matrix_generator.dart';
import '../core/naming_strategy.dart';
import '../flutter/pump_helpers.dart';
import '../models/matrix_axes.dart';
import '../models/matrix_combination.dart';
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
/// Example:
/// ```dart
/// screenMatrixGolden(
///   'TransferScreen',
///   appBuilder: (combination) => MaterialApp(
///     theme: combination.theme.resolve(),
///     locale: combination.locale,
///     home: TransferScreen(),
///   ),
///   axes: MatrixAxes(
///     themes: [MatrixTheme.light, MatrixTheme.dark],
///     devices: [MatrixDevice.phoneSmall, MatrixDevice.tablet],
///   ),
/// );
/// ```
void screenMatrixGolden(
  String name, {
  required MatrixAppBuilder appBuilder,
  required MatrixAxes axes,
  List<MatrixScenario>? states,
  MatrixSampling sampling = MatrixSampling.full,
  List<MatrixRule> rules = const [],
}) {
  final scenarios = states ??
      [MatrixScenario('default', builder: () => const SizedBox.shrink())];

  final combinations = MatrixGenerator.generate(
    scenarios: scenarios,
    axes: axes,
    sampling: sampling,
    rules: rules,
  );

  group('screenMatrixGolden: $name', () {
    for (final combination in combinations) {
      final goldenPath = NamingStrategy.goldenPath(combination);

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

String _testDescription(MatrixCombination c) {
  final dir = c.direction == TextDirection.ltr ? 'ltr' : 'rtl';
  return '${c.scenario.name} | ${c.theme.name} ${c.locale} $dir ${c.textScale}x ${c.device.name}';
}
