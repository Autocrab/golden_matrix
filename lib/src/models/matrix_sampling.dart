/// Strategy for reducing the matrix of combinations.
enum MatrixSampling {
  /// Full Cartesian product of all axes.
  full,

  /// Minimal representative subset: base combo + one delta per axis.
  smoke,

  /// High-value combinations first, sorted by priority score.
  priorityBased,

  /// All-pairs coverage: every pair of parameter values appears in at least one test case.
  pairwise,
}
