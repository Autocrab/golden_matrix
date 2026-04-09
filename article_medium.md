# Stop Writing Golden Tests One by One — Let the Matrix Do It

If you've worked on a Flutter app with multiple themes, locales, and device sizes, you know the pain: golden tests multiply fast. Two themes, three locales, four devices — suddenly you need 24 handwritten tests for a single widget. And when someone adds Arabic support, you double everything for RTL.

I built **golden_matrix** to fix this. One declaration, full coverage.

## The Problem

Here's what golden testing looks like in a real Flutter project with 5 locales and 10 devices:

```dart
for (final locale in supportedLocales) {
  for (final device in devices) {
    testGoldens('widget_${locale.languageCode}_${device.name}', (tester) async {
      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(devices: [device])
        ..addScenario(
          name: 'scenario',
          widget: _ScreenApp(locale: locale, child: MyWidget()),
        );
      await tester.pumpDeviceBuilder(builder);
      await screenMatchesGolden(tester, 'widget_${locale.languageCode}');
    });
  }
}
```

This pattern — nested loops, boilerplate wrappers, manual naming — was copy-pasted across 85 test files in one project I worked on. Every file had its own `_ScreenGoldenApp` wrapper. Dark mode wasn't tested. Text scale wasn't tested. RTL was ignored.

## The Solution

```dart
matrixGolden(
  'MyWidget',
  scenarios: [
    MatrixScenario('default', builder: () => const MyWidget()),
    MatrixScenario('loading', builder: () => const MyWidget.loading()),
    MatrixScenario('error', builder: () => const MyWidget.error('Timeout')),
  ],
  axes: MatrixAxes(
    themes: [MatrixTheme.light, MatrixTheme.dark],
    locales: [Locale('en'), Locale('ru'), Locale('ar')],
    textScales: [1.0, 2.0],
    devices: [MatrixDevice.phoneSmall, MatrixDevice.tablet],
  ),
);
```

3 scenarios × 2 themes × 3 locales × 2 text scales × 2 devices = **72 golden files**. One declaration. Zero loops.

Arabic locale? Automatically gets RTL. Dark mode? Already there. Large text accessibility? Covered.

## What Makes It Different

**golden_toolkit is discontinued.** It was the go-to package for golden testing, but it stopped being maintained in 2023. golden_matrix picks up where it left off — with a fundamentally different approach.

Instead of building grids of widgets in a single image, golden_matrix creates **one test per combination**. Each combination gets its own golden file with a deterministic name:

```
goldens/default/light_en_ltr_1x_phonesmall.png
goldens/default/dark_ar_rtl_2x_tablet.png
goldens/error/light_ru_ltr_1x_phonesmall.png
```

This means cleaner diffs, easier reviews, and precise failure messages.

## Controlling the Matrix Size

72 tests is fine. 720 is not. golden_matrix gives you four ways to control the size:

**Smoke sampling** — one base combo + one delta per axis:

```dart
matrixGolden('Widget', scenarios: [...], axes: axes,
  sampling: MatrixSampling.smoke); // ~5 instead of 72
```

**Pairwise sampling** — covers all parameter pairs with minimal tests (the algorithm used by Microsoft's PICT tool):

```dart
matrixGolden('Widget', scenarios: [...], axes: axes,
  sampling: MatrixSampling.pairwise); // ~15 instead of 72
```

**Priority-based** — dark+largeText and RTL+smallDevice scored highest:

```dart
matrixGolden('Widget', scenarios: [...], axes: axes,
  sampling: MatrixSampling.priorityBased, maxCombinations: 10);
```

**Presets** — for when you just want to get started:

```dart
matrixGolden('Widget', scenarios: [...], preset: MatrixPreset.componentSmoke);
```

## Overflow Detection

This is the feature I'm most excited about. Golden tests catch visual regressions, but they miss **functional** UI bugs.

golden_matrix intercepts `FlutterError` during rendering and captures layout warnings:

```json
{
  "scenario": "default",
  "theme": "light",
  "textScale": 2.0,
  "device": "phoneSmall",
  "status": "passed",
  "warnings": [
    "A RenderFlex overflowed by 42 pixels on the right."
  ]
}
```

The golden image looks "fine" — but the widget overflows on a small phone with large text. Without golden_matrix, you'd never know until a user reports it.

## HTML Reports

Every test run generates a self-contained HTML report alongside the golden files:

- Thumbnail grid grouped by scenario
- Pass/fail/warning badges
- Filter by theme, status, or scenario
- Dark mode support
- Click to open full-size image

No external dependencies. Just open the HTML file.

## Full Screen Testing

For screens with DI, navigation, or custom theme systems:

```dart
screenMatrixGolden(
  'LoginScreen',
  appBuilder: (combination) => MaterialApp(
    theme: combination.theme.resolve(),
    locale: combination.locale,
    home: LoginScreen(
      errorMessage: combination.scenario.name == 'error'
          ? 'Invalid credentials'
          : null,
    ),
  ),
  states: [
    MatrixScenario('default', builder: () => const SizedBox.shrink()),
    MatrixScenario('error', builder: () => const SizedBox.shrink()),
  ],
  preset: MatrixPreset.screenSmoke,
);
```

The `appBuilder` gives you full control. Use your own `MaterialApp`, custom theme wrapper, or DI container. golden_matrix only handles the matrix generation and device simulation.

## Custom Theme Systems

If your project uses a custom theme system, attach it via `data`:

```dart
axes: MatrixAxes(
  themes: [
    MatrixTheme.custom('light', ThemeData.light(), data: MyTheme.light()),
    MatrixTheme.custom('dark', ThemeData.dark(), data: MyTheme.dark()),
  ],
)

// Access in appBuilder:
final myTheme = combination.theme.data as MyTheme;
```

## Getting Started

```yaml
dev_dependencies:
  golden_matrix: ^0.6.0
```

Set up font loading (one-time):

```dart
// test/flutter_test_config.dart
import 'dart:async';
import 'package:golden_matrix/golden_matrix.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await loadAppFonts();
  return testMain();
}
```

Write your first test:

```dart
import 'package:golden_matrix/golden_matrix.dart';

void main() {
  matrixGolden(
    'MyButton',
    scenarios: [
      MatrixScenario('default', builder: () => const MyButton(label: 'OK')),
      MatrixScenario('disabled', builder: () => const MyButton(label: 'OK', enabled: false)),
    ],
    preset: MatrixPreset.componentSmoke,
  );
}
```

Run:

```bash
flutter test --update-goldens  # generate baselines
flutter test                   # run regression tests
```

## Under the Hood

A few implementation details for the curious:

**Pairwise algorithm** — uses a greedy all-pairs approach. For each test case, it picks parameter values that cover the most uncovered pairs. A 3×5×3×6 matrix (270 full Cartesian) reduces to ~30 test cases while guaranteeing every pair of parameter values appears at least once.

**Error capture** — temporarily overrides `FlutterError.onError` during each test's `pumpWidget`/`pumpAndSettle` phase. Warnings are collected per combination and restored in a `finally` block, so it never leaks state to other tests.

**View state cleanup** — every test wraps its body in `try/finally` to guarantee `PumpHelpers.resetView()` runs. Even if the golden comparison fails, the next test starts with a clean slate.

**Tolerance** — wraps `LocalFileComparator` with a threshold check on `diffPercent`. Useful for CI where rendering might differ slightly between machines:

```dart
matrixGolden('Widget', scenarios: [...], axes: axes,
  tolerance: 0.05 / 100); // 0.05% pixel diff allowed
```

## What's Next

The package is at v0.6.0 with 108 tests and zero external dependencies. I'm waiting for real-world feedback before adding more features. The candidates:

- Pseudo localization (stress strings for layout testing)
- CI sharding support
- Integration adapters for existing golden test setups

If you try it, I'd love to hear what works and what doesn't: [github.com/Autocrab/golden_matrix](https://github.com/Autocrab/golden_matrix)

---

*golden_matrix is available on [pub.dev](https://pub.dev/packages/golden_matrix). MIT licensed.*
