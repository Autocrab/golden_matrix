import 'package:flutter/widgets.dart';
import 'package:golden_matrix/golden_matrix.dart';

import 'package:golden_matrix_example/widgets/sample_button.dart';
import 'package:golden_matrix_example/widgets/sample_card.dart';

void main() {
  matrixGolden(
    'SampleButton',
    scenarios: [
      MatrixScenario(
        'default',
        builder: () => const SampleButton(label: 'Continue'),
      ),
      MatrixScenario(
        'disabled',
        builder: () => const SampleButton(label: 'Continue', enabled: false),
      ),
    ],
    axes: MatrixAxes(
      themes: const [MatrixTheme.light, MatrixTheme.dark],
      locales: const [Locale('en'), Locale('ar')],
      textScales: const [1.0, 2.0],
      devices: const [MatrixDevice.phoneSmall, MatrixDevice.phoneLarge],
    ),
  );

  matrixGolden(
    'SampleCard',
    scenarios: [
      MatrixScenario(
        'with_subtitle',
        builder: () => const SampleCard(
          title: 'Transfer Complete',
          subtitle: 'Your money has been sent',
        ),
      ),
      MatrixScenario(
        'without_subtitle',
        builder: () => const SampleCard(title: 'Transfer Complete'),
      ),
    ],
    axes: MatrixAxes(
      themes: const [MatrixTheme.light, MatrixTheme.dark],
      devices: const [MatrixDevice.phoneSmall, MatrixDevice.tablet],
    ),
  );
}
