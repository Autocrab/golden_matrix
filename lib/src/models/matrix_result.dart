import 'package:flutter/widgets.dart';

import 'matrix_combination.dart';

/// The status of a single combination test result.
enum MatrixResultStatus { passed, failed, skipped }

/// Result of a single combination's golden test.
class MatrixCombinationResult {
  final MatrixCombination combination;
  final MatrixResultStatus status;
  final String goldenPath;
  final String? errorMessage;
  final List<String> warnings;

  const MatrixCombinationResult({
    required this.combination,
    required this.status,
    required this.goldenPath,
    this.errorMessage,
    this.warnings = const [],
  });

  Map<String, dynamic> toJson() => {
    'scenario': combination.scenario.name,
    'theme': combination.theme.name,
    'locale': combination.locale.toLanguageTag(),
    'textScale': combination.textScale,
    'device': combination.device.name,
    'direction': combination.direction == TextDirection.ltr ? 'ltr' : 'rtl',
    'status': status.name,
    'goldenPath': goldenPath,
    if (errorMessage != null) 'error': errorMessage,
    if (warnings.isNotEmpty) 'warnings': warnings,
  };
}

/// Aggregated result of a matrix golden test run.
class MatrixResult {
  final String name;
  final List<MatrixCombinationResult> results;
  final DateTime timestamp;
  final Duration duration;

  MatrixResult({
    required this.name,
    required this.results,
    DateTime? timestamp,
    this.duration = Duration.zero,
  }) : timestamp = timestamp ?? DateTime.now();

  int get total => results.length;
  int get passed => results.where((r) => r.status == MatrixResultStatus.passed).length;
  int get failed => results.where((r) => r.status == MatrixResultStatus.failed).length;
  int get skipped => results.where((r) => r.status == MatrixResultStatus.skipped).length;
  int get warningCount => results.fold(0, (sum, r) => sum + r.warnings.length);

  Map<String, dynamic> toJson() => {
    'name': name,
    'timestamp': timestamp.toIso8601String(),
    'durationMs': duration.inMilliseconds,
    'total': total,
    'passed': passed,
    'failed': failed,
    'skipped': skipped,
    'warnings': warningCount,
    'results': results.map((r) => r.toJson()).toList(),
  };
}
