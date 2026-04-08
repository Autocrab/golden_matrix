# Архитектура и ключевые сущности

## Принципы дизайна

1. **Матрица — first-class concept.** Тема, локаль, text scale, device, state, directionality — встроенные сущности, а не параметры helper-функций.
2. **Декларативность.** Пользователь описывает *что* тестировать и *по каким осям*, пакет сам разворачивает в тесты.
3. **Управляемый комбинаторный рост.** Full Cartesian, pairwise, smoke, priority-based, exclude rules.
4. **Детерминированность.** Фиксированные шрифты, отключённые анимации, стабильный layout, предсказуемый naming.
5. **Совместимость.** Строится поверх стандартного Flutter golden pipeline, `alchemist`.

## Ключевые сущности

### MatrixScenario
Один бизнес- или UI-сценарий: имя, builder, tags, optional setup/teardown.

```dart
MatrixScenario(
  'error_timeout',
  builder: () => ProfileCard(error: 'Timeout'),
  tags: ['error', 'network'],
)
```

### MatrixAxes
Измерения матрицы: `themes`, `locales`, `directions`, `textScales`, `devices`, `densities`, `platformVariants`, `accessibilityPresets`.

### MatrixCombination
Одна конкретная комбинация значений осей (theme=dark, locale=ru, textScale=2.0, device=pixel7, state=error). Базовая единица выполнения.

### MatrixPreset
Готовые рекомендации: `componentSmoke`, `componentFull`, `screenSmoke`, `localization`, `accessibility`, `releaseGate`.

### MatrixRule
Правила фильтрации: exclude, include-only, prioritize, rename, grouping.

```dart
MatrixRule.exclude(
  (c) => c.locale.languageCode != 'ar' && c.direction == TextDirection.rtl,
)
```

### MatrixSampling
Стратегии: `full`, `pairwise`, `priorityBased`, `smoke`, `custom`.

### MatrixReport
Модель отчёта: total/executed/passed/failed/skipped, warnings, artifact locations, duration, per-scenario breakdown.

## Структура пакетов

На старте (v0.1–0.3) — **один пакет `golden_matrix`**. Разделение на подпакеты — после валидации с пользователями.

Планируемое разделение в будущем:
- `golden_matrix` — публичный API, оркестрация
- `golden_matrix_core` — модели, генератор комбинаций, naming, фильтрация
- `golden_matrix_flutter` — Flutter-специфика (pumping, themes, locale injection)
- `golden_matrix_cli` — CLI-инструмент
- `golden_matrix_alchemist` — адаптер для alchemist

## Pipeline выполнения

1. Пользователь объявляет сценарии и оси
2. Конфигурация нормализуется (дефолты: light, en, ltr, 1.0, default device)
3. Генерируются комбинации (декартово произведение)
4. Применяются include/exclude rules
5. Применяется sampling strategy
6. Комбинации группируются по сценариям
7. Для каждой комбинации: строится окружение → тема → locale → direction → device → textScale → golden snapshot
8. При фейле: diff, metadata, warnings
9. Генерация JSON/HTML, summary

## Naming strategy

Формат: `<scenario>/<theme>_<locale>_<direction>_<textScale>_<device>_<state>.png`

Правила:
- Всё slugified, без пробелов
- locale → `en`, `ru`, `ar`
- textScale → `1x`, `2x`
- Consistent order
- Optional custom naming callback
