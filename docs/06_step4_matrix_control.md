# Этап 4 — Pairwise и управление матрицей (v0.4.0)

## Цель

Решить проблему комбинаторного взрыва. Сделать матрицу масштабируемой для средних и больших приложений.

## Задачи

### Sampling
- [ ] `MatrixSampling.pairwise` — покрытие всех пар параметров без полного перебора
- [ ] Optional weighted pairwise — приоритет определённых пар
- [ ] Deterministic combination order — стабильный порядок для воспроизводимости

### Rules
- [ ] Улучшенная фильтрация комбинаций
- [ ] Axis priority ordering
- [ ] Exclude по tags / scenario metadata

### Presets
- [ ] `MatrixPreset.releaseGate` — минимальный набор для release gate
- [ ] `MatrixPreset.localization` — фокус на локалях
- [ ] `MatrixPreset.accessibility` — фокус на a11y

### CLI
- [ ] Matrix preview / dry-run — показать комбинации без выполнения
- [ ] List generated combinations before execution

## Критерии готовности

- Пользователь может запустить большую матрицу без катастрофического роста времени
- Pairwise реально сокращает количество кейсов (например, 360 → ~30)
- Dry-run позволяет понять будущий объём прогона
- Пакет подходит для средних и больших приложений
