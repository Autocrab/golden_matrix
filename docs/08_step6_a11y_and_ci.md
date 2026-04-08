# Этап 6 — Accessibility и CI scaling (v0.7.0–0.8.0)

## v0.7.0 — Accessibility pack

### Цель
Закрыть типовые accessibility-варианты.

### Axes
- [ ] Расширенные text scales (1.3, 2.0, 2.5, 3.0)
- [ ] Reduced motion setup
- [ ] Bold text / high contrast abstractions (где технически возможно)
- [ ] Screen density presets

### Presets
- [ ] `MatrixPreset.accessibility` — базовый a11y smoke
- [ ] `MatrixPreset.accessibilityFull` — полный a11y прогон

### Report
- [ ] Accessibility tagging
- [ ] Filtered accessibility-only view

### Критерии готовности
- Команда может отдельно гонять a11y smoke suite
- Text scale и motion-sensitive кейсы — часть стандартного pipeline

---

## v0.8.0 — CI scaling

### Цель
Сделать продукт пригодным для крупных проектов и больших матриц.

### CLI
- [ ] Shard support (`--shard-index`, `--shard-count`)
- [ ] Per-scenario selection (`--scenario`)
- [ ] Tag selection (`--tags`)
- [ ] Changed-only selection (где возможно)

### Reports
- [ ] Merge partial shard reports
- [ ] Unified HTML после sharded execution

### Performance
- [ ] Caching static metadata
- [ ] Artifact cleanup improvements
- [ ] Execution grouping для лучшей runtime locality

### Критерии готовности
- Можно запускать матрицу в нескольких CI jobs параллельно
- Крупные проекты не упираются в время выполнения одной машины
