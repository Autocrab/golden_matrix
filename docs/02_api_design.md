# Публичный API

## Базовый API для компонентов

```dart
matrixGolden(
  'PrimaryButton',
  scenarios: [
    MatrixScenario(
      'default',
      builder: () => const PrimaryButton(label: 'Continue'),
    ),
    MatrixScenario(
      'disabled',
      builder: () => const PrimaryButton(label: 'Continue', enabled: false),
    ),
    MatrixScenario(
      'loading',
      builder: () => const PrimaryButton.loading(label: 'Continue'),
    ),
  ],
  axes: MatrixAxes(
    themes: [MatrixTheme.light, MatrixTheme.dark],
    locales: [Locale('en'), Locale('ru')],
    textScales: [1.0, 2.0],
    devices: [MatrixDevice.phoneSmall, MatrixDevice.phoneLarge],
  ),
);
```

## Screen API

```dart
screenMatrixGolden(
  'TransferDetailsScreen',
  appBuilder: (ctx) => TestApp(
    home: TransferDetailsScreen(data: fakeTransfer),
  ),
  axes: MatrixAxes(
    themes: [MatrixTheme.light, MatrixTheme.dark],
    locales: [Locale('en'), Locale('ru'), Locale('ar')],
    textScales: [1.0, 1.3, 2.0],
    devices: [
      MatrixDevice.iphoneSe,
      MatrixDevice.pixel7,
      MatrixDevice.ipad,
    ],
    directions: [TextDirection.ltr, TextDirection.rtl],
  ),
  states: [
    ScreenState('loading'),
    ScreenState('success'),
    ScreenState('error'),
  ],
  sampling: MatrixSampling.pairwise,
);
```

## API с rules и sampling

```dart
matrixGolden(
  'ProfileCard',
  scenarios: [
    MatrixScenario('loading', builder: () => const ProfileCard.loading()),
    MatrixScenario('data', builder: () => ProfileCard.data(fakeUser)),
    MatrixScenario('error', builder: () => const ProfileCard.error('Timeout')),
  ],
  axes: MatrixAxes(
    themes: [MatrixTheme.light, MatrixTheme.dark],
    locales: [Locale('en'), Locale('ru')],
    textScales: [1.0, 2.0],
    devices: [MatrixDevice.phoneSmall, MatrixDevice.phoneLarge],
  ),
  sampling: MatrixSampling.pairwise,
  rules: [
    MatrixRule.exclude((c) =>
      c.locale.languageCode != 'ar' &&
      c.direction == TextDirection.rtl),
  ],
);
```

## App shell helper

```dart
MatrixAppShell(
  theme: myTheme,
  darkTheme: myDarkTheme,
  localizationsDelegates: [...],
  supportedLocales: [...],
)
```

## State orchestration

```dart
stateBuilder: (state) {
  switch (state.name) {
    case 'loading':
      return FakeTransferRepo.loading();
    case 'error':
      return FakeTransferRepo.error();
    default:
      return FakeTransferRepo.success();
  }
}
```

## Ожидаемая структура артефактов

```
goldens/
  TransferDetailsScreen/
    success/
      light_en_1x_pixel7_ltr.png
      dark_ru_2x_iphoneSe_ltr.png
      dark_ar_2x_pixel7_rtl.png
    loading/
      light_en_1x_pixel7_ltr.png
    error/
      dark_ru_1.3x_ipad_ltr.png
```
