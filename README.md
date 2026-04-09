# golden_matrix

Matrix-based visual regression testing for Flutter widgets and screens.

Write one golden test declaration, run it across themes, locales, devices, text scales, and UI states.

## The Problem

Flutter golden tests check **one specific case**. When you add themes, locales, device sizes, and states — you get copy-paste and combinatorial explosion:

```dart
// Without golden_matrix: manual loops, boilerplate wrappers
for (final locale in supportedLocales) {
  for (final device in devices) {
    testGoldens('screen_${locale.languageCode}_${device.name}', (tester) async {
      // 30+ lines of wrapper setup per combination...
    });
  }
}
```

## The Solution

```dart
// With golden_matrix: one declaration, full coverage
matrixGolden(
  'PrimaryButton',
  scenarios: [
    MatrixScenario('default', builder: () => const PrimaryButton(label: 'OK')),
    MatrixScenario('disabled', builder: () => const PrimaryButton(label: 'OK', enabled: false)),
  ],
  axes: MatrixAxes(
    themes: [MatrixTheme.light, MatrixTheme.dark],
    locales: [Locale('en'), Locale('ar')],
    textScales: [1.0, 2.0],
    devices: [MatrixDevice.phoneSmall, MatrixDevice.phoneLarge],
  ),
);
// 2 scenarios x 2 themes x 2 locales x 2 scales x 2 devices = 32 golden files
```

## Features

- **Declarative matrix** — define axes (themes, locales, devices, text scales, directions), get all combinations automatically
- **Smart defaults** — `MatrixAxes()` with no arguments produces one valid test (light, en, 1.0x, phoneSmall)
- **Direction inference** — Arabic, Hebrew, Farsi automatically get RTL; no manual setup
- **Sampling strategies** — `full` (Cartesian product), `smoke` (minimal subset), `priorityBased` (high-value combos first)
- **Presets** — `MatrixPreset.componentSmoke`, `componentFull`, `screenSmoke` for quick setup
- **Exclude/include rules** — `MatrixRule.exclude(...)`, `MatrixRule.includeOnly(...)` with predicates
- **Screen-level testing** — `screenMatrixGolden()` with full control via `appBuilder`
- **6 device presets** — phoneSmall, phoneMedium, phoneLarge, androidSmall, androidMedium, tablet (+ named aliases: iphoneSE, iphone15, galaxyS20, etc.)
- **Font loading** — `loadAppFonts()` loads real fonts (Roboto + app fonts) instead of Ahem squares
- **JSON reports** — `MatrixReportWriter` exports test results
- **Zero external dependencies** — only Flutter SDK

## Quick Start

### 1. Add dependency

```yaml
# pubspec.yaml
dev_dependencies:
  golden_matrix:
    git:
      url: https://github.com/Autocrab/golden_matrix.git
```

### 2. Set up font loading

```dart
// test/flutter_test_config.dart
import 'dart:async';
import 'package:golden_matrix/golden_matrix.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await loadAppFonts();
  return testMain();
}
```

### 3. Write your first matrix test

```dart
// test/golden/my_widget_golden_test.dart
import 'package:flutter/widgets.dart';
import 'package:golden_matrix/golden_matrix.dart';
import 'package:my_app/widgets/my_button.dart';

void main() {
  matrixGolden(
    'MyButton',
    scenarios: [
      MatrixScenario('default', builder: () => const MyButton(label: 'OK')),
      MatrixScenario('disabled', builder: () => const MyButton(label: 'OK', enabled: false)),
    ],
    axes: MatrixAxes(
      themes: [MatrixTheme.light, MatrixTheme.dark],
      devices: [MatrixDevice.phoneSmall, MatrixDevice.tablet],
    ),
  );
}
```

### 4. Generate baselines

```bash
flutter test --update-goldens
```

### 5. Run regression tests

```bash
flutter test
```

## API

### matrixGolden — component testing

Auto-wraps your widget in a `MaterialApp` with theme, locale, directionality, text scale, and device configuration.

```dart
matrixGolden(
  'ProfileCard',
  scenarios: [
    MatrixScenario('loading', builder: () => const ProfileCard.loading()),
    MatrixScenario('data', builder: () => ProfileCard(user: fakeUser)),
    MatrixScenario('error', builder: () => const ProfileCard.error('Timeout')),
  ],
  axes: MatrixAxes(
    themes: [MatrixTheme.light, MatrixTheme.dark],
    locales: [Locale('en'), Locale('ru'), Locale('ar')],
    textScales: [1.0, 2.0],
    devices: [MatrixDevice.iphoneSE, MatrixDevice.galaxyA51, MatrixDevice.tablet],
  ),
  rules: [
    MatrixRule.exclude((c) => c.locale.languageCode != 'ar' && c.direction == TextDirection.rtl),
  ],
);
```

### screenMatrixGolden — screen testing

You provide the full `MaterialApp` via `appBuilder` — for DI, navigation, custom themes, etc.

```dart
screenMatrixGolden(
  'LoginScreen',
  appBuilder: (combination) => MaterialApp(
    theme: combination.theme.resolve(),
    locale: combination.locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: LoginScreen(
      errorMessage: combination.scenario.name == 'error' ? 'Invalid credentials' : null,
    ),
  ),
  states: [
    MatrixScenario('default', builder: () => const SizedBox.shrink()),
    MatrixScenario('error', builder: () => const SizedBox.shrink()),
  ],
  preset: MatrixPreset.screenSmoke,
);
```

### Presets

Skip the boilerplate — use built-in presets:

```dart
// Quick smoke test: light/dark, 1 device, smoke sampling
matrixGolden('Widget', scenarios: [...], preset: MatrixPreset.componentSmoke);

// Full coverage: light/dark, en/ar, 1x/2x, phone/tablet
matrixGolden('Widget', scenarios: [...], preset: MatrixPreset.componentFull);

// Screen smoke: light/dark, en/ar, phone/tablet, smoke sampling
screenMatrixGolden('Screen', appBuilder: ..., preset: MatrixPreset.screenSmoke);
```

### Sampling

Control the matrix size:

```dart
// Full Cartesian product (default)
matrixGolden('Widget', scenarios: [...], axes: axes);

// Smoke: base combo + one delta per axis (~5 instead of 32)
matrixGolden('Widget', scenarios: [...], axes: axes, sampling: MatrixSampling.smoke);

// Priority-based: high-value combos first, capped at N
matrixGolden('Widget', scenarios: [...], axes: axes,
  sampling: MatrixSampling.priorityBased, maxCombinations: 10);
```

### Rules

```dart
// Exclude: remove specific combinations
MatrixRule.exclude((c) => c.theme.name == 'dark' && c.textScale > 1.5)

// Include only: keep only matching combinations
MatrixRule.includeOnly((c) => c.device.name == 'phoneSmall' || c.device.name == 'tablet')
```

### Device Presets

```dart
// Generic sizes
MatrixDevice.phoneSmall    // 375x667, 2.0x (iPhone SE)
MatrixDevice.phoneMedium   // 390x844, 3.0x (iPhone 15)
MatrixDevice.phoneLarge    // 414x896, 3.0x (iPhone 15 Pro Max)
MatrixDevice.androidSmall  // 360x800, 4.0x (Galaxy S20)
MatrixDevice.androidMedium // 412x915, 2.625x (Galaxy A51)
MatrixDevice.tablet        // 768x1024, 2.0x (iPad)
MatrixDevice.tabletLandscape // 1024x768, 2.0x

// Named aliases
MatrixDevice.iphoneSE      // = phoneSmall
MatrixDevice.iphone15      // = phoneMedium
MatrixDevice.galaxyS20     // = androidSmall
MatrixDevice.galaxyA51     // = androidMedium

// Custom
MatrixDevice(name: 'pixel7', logicalSize: Size(412, 915), pixelRatio: 2.75)
```

## Golden File Structure

```
test/golden/goldens/
  default/
    light_en_ltr_1x_phonesmall.png
    dark_ar_rtl_2x_phonelarge.png
  disabled/
    light_en_ltr_1x_phonesmall.png
  error/
    dark_en_ltr_1x_tablet.png
```

Naming format: `goldens/<scenario>/<theme>_<locale>_<direction>_<textScale>_<device>.png`

## Custom Localization Delegates

If your app uses custom localization, pass delegates to `matrixGolden`:

```dart
matrixGolden(
  'MyWidget',
  scenarios: [...],
  axes: axes,
  extraLocalizationsDelegates: [
    AppLocalizations.delegate,
  ],
);
```

For `screenMatrixGolden`, configure delegates in your `appBuilder`.

## Requirements

- Flutter SDK >= 3.16.0
- Dart SDK >= 3.2.0

## License

MIT
