# Этап 1 — Proof of Concept (v0.1.0)

## Цель

Подтвердить, что базовая матрица работает и даёт value. Показать основную ценность: декларация матрицы → автоматическое разворачивание → golden-файлы.

## Задачи

### Core модели
- [ ] `MatrixScenario` — имя, builder, tags
- [ ] `MatrixAxes` — themes, locales, textScales, devices, directions
- [ ] `MatrixCombination` — одна конкретная комбинация осей
- [ ] `MatrixSampling.full` — полная декартова матрица
- [ ] `MatrixRule.exclude` — базовое исключение комбинаций
- [ ] Naming strategy v1 — `<scenario>/<theme>_<locale>_<direction>_<textScale>_<device>.png`
- [ ] Result model — pass/fail/skip per combination

### Flutter layer
- [ ] Wrapping widget в app shell (Theme, Locale, Directionality, MediaQuery)
- [ ] Themes: light/dark
- [ ] Locales injection
- [ ] Text scale injection
- [ ] Device presets: 2–3 базовых (phoneSmall, phoneLarge, tablet)
- [ ] State support через scenarios
- [ ] Deterministic pump helpers
- [ ] Отключение анимаций

### Public API
- [ ] `matrixGolden(...)` — базовая функция для компонентов
- [ ] `screenMatrixGolden(...)` — простая версия для экранов

### Output
- [ ] Baseline PNG генерация
- [ ] Actual PNG генерация
- [ ] Diff PNG при несовпадении
- [ ] Текстовый summary в консоль

### Тесты и примеры
- [ ] Unit tests для matrix generation (комбинации, фильтрация, naming)
- [ ] 2–3 demo компонента в `example/`
- [ ] Матрица 2 темы × 2 локали × 2 textScale × 2 devices

## Что НЕ входит

- HTML report
- JSON report
- Pairwise sampling
- Overflow detection
- Long text / pseudo localization
- CLI
- Backend adapters

## Критерии готовности

- Можно описать компонент и получить несколько golden snapshots
- Naming стабилен и предсказуем
- Структура файлов понятна
- API выглядит как продукт, а не internal prototype
- Видно, что идея жизнеспособна и API приятно использовать
