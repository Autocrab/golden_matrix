import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../core/matrix_generator.dart';
import '../core/naming_strategy.dart';
import '../flutter/matrix_widget_wrapper.dart';
import '../flutter/pump_helpers.dart';
import '../models/matrix_axes.dart';
import '../models/matrix_combination.dart';
import '../models/matrix_rule.dart';
import '../models/matrix_sampling.dart';
import '../models/matrix_scenario.dart';

/// Creates a group of golden tests for each combination in the matrix.
///
/// This is the primary API for component-level golden testing.
/// The widget from each scenario is automatically wrapped in a [MaterialApp]
/// shell with the appropriate theme, locale, direction, and text scale.
///
/// Example:
/// ```dart
/// matrixGolden(
///   'PrimaryButton',
///   scenarios: [
///     MatrixScenario('default', builder: () => const PrimaryButton(label: 'OK')),
///     MatrixScenario('disabled', builder: () => const PrimaryButton(label: 'OK', enabled: false)),
///   ],
///   axes: MatrixAxes(
///     themes: [MatrixTheme.light, MatrixTheme.dark],
///     locales: [Locale('en'), Locale('ru')],
///   ),
/// );
/// ```
void matrixGolden(
  String name, {
  required List<MatrixScenario> scenarios,
  required MatrixAxes axes,
  MatrixSampling sampling = MatrixSampling.full,
  List<MatrixRule> rules = const [],
  List<LocalizationsDelegate<dynamic>> extraLocalizationsDelegates = const [],
}) {
  final combinations = MatrixGenerator.generate(
    scenarios: scenarios,
    axes: axes,
    sampling: sampling,
    rules: rules,
  );

  group('matrixGolden: $name', () {
    for (final combination in combinations) {
      final goldenPath = NamingStrategy.goldenPath(combination);

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

String _testDescription(MatrixCombination c) {
  final dir = c.direction == TextDirection.ltr ? 'ltr' : 'rtl';
  return '${c.scenario.name} | ${c.theme.name} ${c.locale} $dir ${c.textScale}x ${c.device.name}';
}
