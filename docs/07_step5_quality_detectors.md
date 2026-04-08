# Этап 5 — Детекторы качества UI (v0.5.0–0.6.0)

## Цель

Перейти от "скриншотного" инструмента к инструменту качества UI. Ловить реальные баги, а не только пиксельные отличия.

## v0.5.0 — Overflow detection и runtime diagnostics

### Detectors
- [ ] `RenderFlex overflow` detection
- [ ] Framework layout exceptions
- [ ] Logged `FlutterError` capture
- [ ] Missing font / asset warnings

### Реализация
- [ ] Перехват `FlutterError.onError` во время теста
- [ ] Перехват debug messages и framework assertions
- [ ] Классификация: hard fail / warning / report annotation

### Report integration
- [ ] Warnings и errors per combination в отчёте
- [ ] `failOnWarning` config
- [ ] `failOnOverflow` mode
- [ ] Human-readable diagnostics
- [ ] Корреляция ошибок с combination metadata

## v0.6.0 — Long text / pseudo localization

### Localization stress modes
- [ ] Long text x1.5 / x2
- [ ] Pseudo locale (`Continue` → `[Çôñţíñüè —— long text sample]`)
- [ ] Bracketed pseudo strings
- [ ] Accented pseudo locale
- [ ] RTL pseudo locale

### API
- [ ] `textStressMode` parameter
- [ ] Localization delegate override support
- [ ] `MatrixPreset.localizationStress`

### Report
- [ ] Отдельная маркировка stress-generated комбинаций

## Критерии готовности

- Пакет находит проблемы, которые не проявились бы как очевидный diff
- UI quality checks product-oriented (overflow, clipped text, missing translations)
- Локализационные regressions ловятся до релиза
- Можно массово прогонять UI на устойчивость к длинным строкам
