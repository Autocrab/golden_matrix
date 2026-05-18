## 0.13.0 — BREAKING (only if you used `tolerance:`)

- **Fix: `tolerance:` was silently looking up goldens in the wrong directory.** The `_TolerantComparator` passed the delegate's `basedir` directly to `LocalFileComparator(Uri testFile)` — which interprets its argument as a test-file URI and applies `dirname()`, shifting the effective basedir one level up. As a result, tolerance-enabled goldens were generated and matched at a path one directory above where they should have been.
- **Impact:** Tests using `tolerance:` will now look for goldens at the correct path. Pre-existing baselines on the shifted path will not be found → tests fail with `Could not be compared against non-existent file`.
- **Migration:** For every `matrixGolden` / `screenMatrixGolden` call that uses `tolerance:`, either:
  - Move existing golden files from the shifted location down one directory to the correct one, **or**
  - Run `flutter test --update-goldens` once to regenerate baselines at the correct path. The pixel content is unchanged — only the file location.
- **Bonus:** the example test suite (`example/test/golden/sample_golden_test.dart`) now applies `tolerance: 0.01 / 100` (0.01%) to every test, absorbing cross-macOS anti-aliasing noise and unblocking CI on `macos-latest`.

## 0.12.0

Post-pump-state release. Three orthogonal additions that together unlock a huge class of previously impossible tests.

- **`setup` callback** — `(WidgetTester tester, MatrixCombination combination) async {...}` runs after `pumpAndSettle` and before the golden is captured. Tap, scroll, enter text, open menus — snapshot the post-interaction state. Available on `matrixGolden` and `screenMatrixGolden`.
- **`freezeAnimations: bool = false`** — wraps the widget tree in `TickerMode(enabled: false)`, halting every `AnimationController` / `Ticker`. Use for widgets with infinite shimmer / skeleton / loader animations that otherwise hang `pumpAndSettle`. Snapshot reflects the initial frame.
- **`captureAfter: Duration?`** — pumps the test clock for the given duration *after* settling (and after `setup`), before capture. Pair with `freezeAnimations: false` to catch a specific mid-animation frame.

Pure additive — all three default to no-op behavior. Existing 140 example goldens pass without `--update-goldens`.

## 0.11.0

- **`wrapApp` — app-level decorator for `matrixGolden`.** New optional parameter that wraps the auto-built `MaterialApp` from the outside. This is the seam for dependency injection above MaterialApp: `ProviderScope` (Riverpod) with overrides, `BlocProvider` / `MultiBlocProvider`, `MultiProvider`, or any custom root-level `InheritedWidget` (e.g. brand themes that must sit above MaterialApp). The callback receives the current `MatrixCombination` so providers can vary per scenario. Pure additive — when `null`, the widget tree is byte-identical to previous versions, existing golden files unchanged.

## 0.10.0

- **More device presets** — modern phones (`iphone15Pro`, `iphone16ProMax`, `pixel8`, `pixel8Pro`, `galaxyS24`), foldables (`galaxyZFoldFolded`, `galaxyZFoldUnfolded`), and full iPad lineup (`ipadMini`, `ipadAir`, `ipadPro11`, `ipadPro11Landscape`, `ipadPro13`, `ipadPro13Landscape`).
- **`copyWith()` on models** — `MatrixAxes.copyWith`, `MatrixDevice.copyWith`, `MatrixCombination.copyWith`. Tweak a preset axes set, rotate a device into landscape, or fabricate a near-identical combination without re-declaring every field.

## 0.9.1

- **Dry-run preview** — new `previewMatrixGolden(...)` returns a `MatrixPreview` describing what the runner would do (combination counts before/after rules and sampling, golden paths, duplicate-path detection) without rendering widgets or writing files. Use it to sanity-check `scenarioTags`, estimate CI cost, or spot golden-path collisions before they overwrite each other.

## 0.9.0 — BREAKING

- **Breaking: `tags` → `scenarioTags`.** The parameter was documented as Flutter test tags but actually filtered scenarios. Renamed for clarity. **Migration:** replace `tags:` with `scenarioTags:` at call sites.
- **Fix: pairwise sampling honors rules.** Pairwise now derives its parameter domain from combinations surviving exclude/includeOnly rules, restoring coverage guarantees over the feasible set. Direction stays inferred from locale unless `axes.directions` is set explicitly.
- **Fix: `maxCombinations` is now a global cap.** Applied uniformly after any sampling strategy, not only `priorityBased`.
- **Fix: tolerance hardening.** Validates `tolerance` is in 0.0..1.0, and fails with a clear `StateError` when the active `goldenFileComparator` is not a `LocalFileComparator` instead of a force-cast crash.
- **Fix: `ErrorCapture` no longer downgrades layout-contract failures.** "RenderBox was not laid out" and similar are forwarded to the test framework. Only true overflow patterns remain whitelisted.

## 0.8.3

- **Better failure messages** — warnings for `priorityBased` sampling without `maxCombinations` on large matrices, and when `loadAppFonts` cannot find Roboto.
- **Validation** — asserts on empty `MatrixScenario`, `MatrixTheme.custom`, `MatrixDevice` names and non-positive `pixelRatio`.
- **Switched to `debugPrint`** — replaces `print` in summary output and warnings.

## 0.8.2

- **Docs** — update install snippet version in README to current.

## 0.8.1

- **Docs** — expanded dartdoc across the public API: per-parameter docs on `matrixGolden`/`screenMatrixGolden`, sampling strategy comparisons, preset descriptions, complex rule examples, device preset table, custom theme system pattern, error capture pattern list.

## 0.8.0 — BREAKING

- **Breaking: golden file paths now include the test name** — fixes a silent collision bug where two `matrixGolden` calls with scenarios sharing names (e.g. `'default'`) would overwrite each other's golden files.
  - Old path: `goldens/<scenario>/<theme>_<locale>_<dir>_<scale>_<device>.png`
  - New path: `goldens/<test>/<scenario>/<theme>_<locale>_<dir>_<scale>_<device>.png`
  - **Migration:** delete your existing `goldens/` directory and run `flutter test --update-goldens` to regenerate at the new paths. If you used `fileNameBuilder` you are unaffected.

## 0.7.1

- **Fix** — overflow warnings no longer fail the test. ErrorCapture was forwarding captured layout warnings to the default handler, which marked the test as failed.

## 0.7.0

- **Console summary** — prints test counts, duration, and failed combinations in `tearDownAll`. Opt-out via `printSummary: false`.

## 0.6.3

- **Smaller package** — excluded example golden PNG files from the published package (~900 KB → much smaller). Reference outputs available in the GitHub repository.

## 0.6.2

- **Fix** — shorter description in pubspec.yaml (pub.dev recommends 60-180 characters)

## 0.6.1

- **Fix** — use `dev_dependencies` in README examples (was incorrectly `dependencies`)
- **Docs** — add pub.dev badge to README

## 0.6.0

- **Value equality** — `MatrixTheme`, `MatrixDevice`, `MatrixScenario` now use `==`/`hashCode` instead of name-string comparisons
- **Input validation** — asserts on empty axes lists in `MatrixGenerator.generate()`
- **Skipped result tracking** — combinations recorded as `skipped` when `skip: true`
- **Centralized slugify** — single `slugify()` utility used across all models and report writer
- **Runner refactoring** — `runMatrixTests` split into focused helpers (`resolveCombinations`, `groupByScenario`, `_executeGoldenTest`, etc.)
- **108 tests** — 68 unit + 30 integration + 10 runner helper tests

## 0.5.0

- **Overflow detection** — automatically captures `RenderFlex overflow` and layout errors during golden tests, reports them as warnings in JSON/HTML
- **Pairwise sampling** — `MatrixSampling.pairwise` covers all parameter pairs with minimal test cases (e.g. 270 → ~30)
- **HTML reports** — self-contained HTML report with thumbnails, filters, dark mode support
- **Tolerance** — `tolerance` parameter for pixel diff threshold (e.g. `0.05 / 100` for 0.05%)
- **Skip** — `skip` parameter to conditionally skip tests (e.g. `skip: !Platform.isMacOS`)
- **Custom wrapper** — `wrapChild` parameter to customize inner layout (remove default Scaffold+Center)
- **Theme data** — `MatrixTheme.custom('name', themeData, data: customObject)` for arbitrary context
- **Report directory** — `reportDir` parameter to control report output location

## 0.4.0

- **Pairwise sampling** — greedy all-pairs algorithm via `MatrixSampling.pairwise`

## 0.3.0

- **HTML report** — auto-generated self-contained HTML with scenario grouping, filters, thumbnails
- **Result collection** — automatic test result tracking with JSON/HTML export via `tearDownAll`

## 0.2.0

- **Sampling strategies** — `MatrixSampling.smoke`, `MatrixSampling.priorityBased` with `maxCombinations`
- **Presets** — `MatrixPreset.componentSmoke`, `componentFull`, `screenSmoke`
- **Include rules** — `MatrixRule.includeOnly(predicate)`
- **Device aliases** — `iphoneSE`, `iphone15`, `galaxyS20`, `galaxyA51`, `tabletLandscape`
- **JSON reports** — `MatrixResult.toJson()` with timestamp, duration, per-combination results
- **Tags** — filter scenarios by tags
- **Custom filename** — `fileNameBuilder` parameter

## 0.1.0

- Initial release
- `matrixGolden()` and `screenMatrixGolden()` APIs
- Full Cartesian product generation with direction inference (RTL for ar, he, fa, ur, ps, ku, yi)
- `MatrixRule.exclude()` for combination filtering
- 6 device presets with realistic pixel ratios and safe areas
- `loadAppFonts()` for real font rendering in golden tests
- Deterministic naming: `goldens/<scenario>/<theme>_<locale>_<dir>_<scale>_<device>.png`
