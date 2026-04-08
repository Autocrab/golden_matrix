import 'package:flutter/widgets.dart';

import '../models/matrix_axes.dart';
import '../models/matrix_combination.dart';
import '../models/matrix_rule.dart';
import '../models/matrix_sampling.dart';
import '../models/matrix_scenario.dart';

/// Generates all combinations from scenarios and axes.
class MatrixGenerator {
  /// Generates a list of [MatrixCombination]s based on the given parameters.
  static List<MatrixCombination> generate({
    required List<MatrixScenario> scenarios,
    required MatrixAxes axes,
    MatrixSampling sampling = MatrixSampling.full,
    List<MatrixRule> rules = const [],
  }) {
    var combinations = <MatrixCombination>[];

    for (final scenario in scenarios) {
      for (final theme in axes.themes) {
        for (final locale in axes.locales) {
          for (final textScale in axes.textScales) {
            for (final device in axes.devices) {
              if (axes.directions.isEmpty) {
                // Direction inferred from locale
                final direction = directionForLocale(locale);
                combinations.add(MatrixCombination(
                  scenario: scenario,
                  theme: theme,
                  locale: locale,
                  textScale: textScale,
                  device: device,
                  direction: direction,
                ));
              } else {
                // Direction is an explicit axis
                for (final direction in axes.directions) {
                  combinations.add(MatrixCombination(
                    scenario: scenario,
                    theme: theme,
                    locale: locale,
                    textScale: textScale,
                    device: device,
                    direction: direction,
                  ));
                }
              }
            }
          }
        }
      }
    }

    // Apply exclusion rules
    for (final rule in rules) {
      if (rule.type == MatrixRuleType.exclude) {
        combinations =
            combinations.where((c) => !rule.predicate(c)).toList();
      }
    }

    return combinations;
  }

  /// Returns the text direction for a given locale.
  static TextDirection directionForLocale(Locale locale) {
    const rtlLanguages = {'ar', 'he', 'fa', 'ur', 'ps', 'ku', 'yi'};
    return rtlLanguages.contains(locale.languageCode)
        ? TextDirection.rtl
        : TextDirection.ltr;
  }
}
