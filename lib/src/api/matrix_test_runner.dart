import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../core/matrix_generator.dart';
import '../core/matrix_report_writer.dart';
import '../core/naming_strategy.dart';
import '../flutter/error_capture.dart';
import '../flutter/pump_helpers.dart';
import '../models/matrix_axes.dart';
import '../models/matrix_combination.dart';
import '../models/matrix_preset.dart';
import '../models/matrix_result.dart';
import '../models/matrix_rule.dart';
import '../models/matrix_sampling.dart';
import '../models/matrix_scenario.dart';

/// Builds a widget tree for a given [MatrixCombination].
typedef MatrixWidgetBuilder = Widget Function(MatrixCombination combination);

/// Key used for the [RepaintBoundary] that wraps the golden capture target.
const _goldenBoundaryKey = ValueKey('__golden_matrix_boundary__');

/// Internal test runner shared by [matrixGolden] and [screenMatrixGolden].
///
/// Handles: config resolution, matrix generation, test execution,
/// result collection, report writing, and view state cleanup.
void runMatrixTests(
  String name, {
  required List<MatrixScenario> scenarios,
  required MatrixWidgetBuilder widgetBuilder,
  MatrixAxes? axes,
  MatrixPreset? preset,
  MatrixSampling? sampling,
  int? maxCombinations,
  List<MatrixRule> rules = const [],
  List<String>? tags,
  String Function(MatrixCombination)? fileNameBuilder,
  bool report = true,
  String? reportDir,
  bool skip = false,
  double? tolerance,
}) {
  // Resolve config from preset + explicit params
  final effectiveAxes = axes ?? preset?.axes ?? const MatrixAxes();
  final effectiveSampling = sampling ?? preset?.sampling ?? MatrixSampling.full;
  final effectiveRules = [...?preset?.rules, ...rules];

  // Filter scenarios by tags
  final filteredScenarios = tags != null
      ? scenarios.where((s) => s.tags.any((t) => tags.contains(t))).toList()
      : scenarios;

  // Generate combinations
  final combinations = MatrixGenerator.generate(
    scenarios: filteredScenarios,
    axes: effectiveAxes,
    sampling: effectiveSampling,
    rules: effectiveRules,
    maxCombinations: maxCombinations,
  );

  // Group by scenario
  final byScenario = <String, List<MatrixCombination>>{};
  for (final c in combinations) {
    (byScenario[c.scenario.name] ??= []).add(c);
  }

  final List<MatrixCombinationResult> combinationResults = [];
  final stopwatch = Stopwatch()..start();

  group(name, () {
    GoldenFileComparator? originalComparator;

    if (tolerance != null) {
      setUp(() {
        originalComparator = goldenFileComparator;
        goldenFileComparator = _TolerantComparator(
          goldenFileComparator as LocalFileComparator,
          tolerance,
        );
      });

      tearDown(() {
        if (originalComparator != null) {
          goldenFileComparator = originalComparator!;
        }
      });
    }

    for (final entry in byScenario.entries) {
      group(entry.key, () {
        for (final combination in entry.value) {
          final goldenPath = fileNameBuilder != null
              ? fileNameBuilder(combination)
              : NamingStrategy.goldenPath(combination);

          // Record skipped results for accurate reporting
          if (skip && report) {
            combinationResults.add(
              MatrixCombinationResult(
                combination: combination,
                status: MatrixResultStatus.skipped,
                goldenPath: goldenPath,
              ),
            );
          }

          testWidgets(_testDescription(combination), skip: skip, (WidgetTester tester) async {
            PumpHelpers.configureView(tester, combination.device);
            final capture = ErrorCapture()..start();
            try {
              final widget = RepaintBoundary(
                key: _goldenBoundaryKey,
                child: widgetBuilder(combination),
              );

              await tester.pumpWidget(widget);
              await tester.pumpAndSettle();
              capture.stop();

              if (report) {
                try {
                  await expectLater(find.byKey(_goldenBoundaryKey), matchesGoldenFile(goldenPath));
                  combinationResults.add(
                    MatrixCombinationResult(
                      combination: combination,
                      status: MatrixResultStatus.passed,
                      goldenPath: goldenPath,
                      warnings: List.unmodifiable(capture.warnings),
                    ),
                  );
                } catch (e) {
                  combinationResults.add(
                    MatrixCombinationResult(
                      combination: combination,
                      status: MatrixResultStatus.failed,
                      goldenPath: goldenPath,
                      errorMessage: e.toString(),
                      warnings: List.unmodifiable(capture.warnings),
                    ),
                  );
                  rethrow;
                }
              } else {
                await expectLater(find.byKey(_goldenBoundaryKey), matchesGoldenFile(goldenPath));
              }
            } finally {
              capture.stop();
              PumpHelpers.resetView(tester);
            }
          });
        }
      });
    }

    if (report) {
      tearDownAll(() async {
        stopwatch.stop();
        final result = MatrixResult(
          name: name,
          results: combinationResults,
          duration: stopwatch.elapsed,
        );
        await MatrixReportWriter.write(result, outputDir: reportDir);
        await MatrixReportWriter.writeHtml(result, outputDir: reportDir);
      });
    }
  });
}

String _testDescription(MatrixCombination c) {
  final dir = c.direction == TextDirection.ltr ? 'ltr' : 'rtl';
  return '${c.theme.name} ${c.locale} $dir ${c.textScale}x ${c.device.name}';
}

/// A [LocalFileComparator] wrapper that allows a percentage of pixels to differ.
class _TolerantComparator extends LocalFileComparator {
  final double _tolerance;

  _TolerantComparator(LocalFileComparator delegate, this._tolerance) : super(delegate.basedir);

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );

    if (!result.passed && result.diffPercent <= _tolerance) {
      return true;
    }

    if (!result.passed) {
      final error = await generateFailureOutput(result, golden, basedir);
      throw FlutterError(error);
    }

    return result.passed;
  }
}
