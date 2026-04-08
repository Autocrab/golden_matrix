import 'package:flutter/widgets.dart';

/// A builder function that creates a widget for a test scenario.
typedef ScenarioBuilder = Widget Function();

/// Represents a single test scenario in the matrix.
class MatrixScenario {
  final String name;
  final ScenarioBuilder builder;
  final List<String> tags;

  const MatrixScenario(
    this.name, {
    required this.builder,
    this.tags = const [],
  });

  String get slug => name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');

  @override
  String toString() => 'MatrixScenario($name)';
}
