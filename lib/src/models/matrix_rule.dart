import 'matrix_combination.dart';

/// The type of matrix rule.
enum MatrixRuleType {
  /// Excludes combinations matching the predicate.
  exclude,

  /// Keeps only combinations matching the predicate.
  includeOnly,
}

/// A rule for filtering matrix combinations.
class MatrixRule {
  final bool Function(MatrixCombination) predicate;
  final MatrixRuleType type;

  const MatrixRule._(this.predicate, this.type);

  /// Creates a rule that excludes combinations matching the [predicate].
  factory MatrixRule.exclude(bool Function(MatrixCombination) predicate) =>
      MatrixRule._(predicate, MatrixRuleType.exclude);

  /// Creates a rule that keeps only combinations matching the [predicate].
  factory MatrixRule.includeOnly(bool Function(MatrixCombination) predicate) =>
      MatrixRule._(predicate, MatrixRuleType.includeOnly);
}
