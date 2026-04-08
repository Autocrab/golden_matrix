# Этап 7 — Интеграции и v1.0 (v0.9.0–1.0.0)

## v0.9.0 — Integration layer

### Цель
Упростить внедрение в существующие команды и экосистемы.

### Integrations
- [ ] `golden_matrix_alchemist` — адаптер для alchemist
- [ ] `golden_matrix_toolkit` — адаптер для golden_toolkit (опционально)
- [ ] Widgetbook bridge — экспорт сценариев из каталогов
- [ ] Import scenarios from external catalogs

### DX
- [ ] Docs для миграции с plain golden tests
- [ ] Compatibility recipes
- [ ] Migration guide

### Критерии готовности
- Пакет легко внедрять без переписывания существующих тестов
- Есть путь плавной миграции

---

## v1.0.0 — Production-ready

### Цель
Закрепить API и позиционировать как зрелый инструмент.

### API stability
- [ ] Заморозка базовых сущностей
- [ ] Migration guide from pre-1.0

### Documentation
- [ ] Полноценный README
- [ ] Cookbook с рецептами
- [ ] CI examples (GitHub Actions, GitLab CI, Codemagic)
- [ ] Best practices guide
- [ ] Troubleshooting guide

### CLI
- [ ] `golden_matrix doctor` — проверка окружения (fonts, renderer, deterministic setup)
- [ ] `golden_matrix approve` — review-oriented approval flow
- [ ] Polished baseline workflow

### Reports
- [ ] Mature HTML UI
- [ ] Search/filter в отчёте
- [ ] Side-by-side compare view
- [ ] Gallery mode

### Quality
- [ ] Benchmark suite
- [ ] Deterministic regression suite самого пакета
- [ ] Examples app
- [ ] Design system demo
- [ ] Screen-level real-world samples

### Критерии готовности
- Пакет можно рекомендовать как стандартный инструмент
- Onboarding новой команды — минимум времени
- API стабилен для продакшен-использования

## Что НЕ делать в ранних версиях

- Облачный SaaS
- Browser-based review platform
- AI-анализ diff-картинок
- Автопочинку layout
- Сложную web-renderer parity систему
- Глубокую Widgetbook интеграцию до v0.9
