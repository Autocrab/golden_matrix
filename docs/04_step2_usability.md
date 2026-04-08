# Этап 2 — Usability Layer (v0.2.0)

## Цель

Сделать пакет удобным для реального локального использования. Первый pub.dev-релиз.

## Задачи

### Sampling
- [ ] `MatrixSampling.smoke` — минимальный набор комбинаций
- [ ] `MatrixSampling.priorityBased` — базовая версия (dark + large text, RTL + small device и т.д.)

### Presets
- [ ] `MatrixPreset.componentSmoke` — быстрый smoke для компонентов
- [ ] `MatrixPreset.componentFull` — полный прогон для компонентов
- [ ] `MatrixPreset.screenSmoke` — быстрый smoke для экранов

### Device presets
- [ ] Расширение списка: phoneSmall, phoneMedium, phoneLarge, tabletPortrait
- [ ] iPhone SE, iPhone 15, Pixel 5, Pixel 7
- [ ] Каждый preset: logical size, device pixel ratio, safe areas

### Reports
- [ ] JSON report v1 — scenario, state, combination, status, artifact paths, errors, warnings
- [ ] Summary model с totals (total/passed/failed/skipped)

### Rules
- [ ] Include-only rules
- [ ] Custom filename callback

### DX
- [ ] Scenario tags и фильтрация по ним
- [ ] Grouping в output
- [ ] Более понятные failure messages
- [ ] Docs и README
- [ ] Примеры использования

## Критерии готовности

- Пакет удобно использовать в небольшой команде без кастомных хаков
- Smoke/full режимы позволяют не взрывать CI по времени
- Можно строить автоматические пайплайны на основе JSON
- Пакет готов к публикации на pub.dev (v0.2.x)
