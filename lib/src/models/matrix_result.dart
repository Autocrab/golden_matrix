import 'matrix_combination.dart';

/// The status of a single combination test result.
enum MatrixResultStatus { passed, failed, skipped }

/// Result of a single combination's golden test.
class MatrixCombinationResult {
  final MatrixCombination combination;
  final MatrixResultStatus status;
  final String goldenPath;
  final String? errorMessage;

  const MatrixCombinationResult({
    required this.combination,
    required this.status,
    required this.goldenPath,
    this.errorMessage,
  });
}

/// Aggregated result of a matrix golden test run.
class MatrixResult {
  final String name;
  final List<MatrixCombinationResult> results;

  const MatrixResult({required this.name, required this.results});

  int get total => results.length;
  int get passed =>
      results.where((r) => r.status == MatrixResultStatus.passed).length;
  int get failed =>
      results.where((r) => r.status == MatrixResultStatus.failed).length;
  int get skipped =>
      results.where((r) => r.status == MatrixResultStatus.skipped).length;
}
