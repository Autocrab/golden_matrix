# Этап 3 — HTML Report + CLI (v0.3.0)

## Цель

Сделать результаты удобными для ревью. Поднять adoption через review-friendly output и CLI.

## Задачи

### HTML report
- [ ] Index page со summary
- [ ] Группировка по scenario/state
- [ ] Baseline / actual / diff preview (thumbnails + полноразмерные)
- [ ] Artifact links
- [ ] Timestamps и execution duration
- [ ] Warnings section
- [ ] Per-combination metadata

### CLI v1
- [ ] `golden_matrix run` — запуск матричных golden tests
- [ ] `golden_matrix update` — обновление baseline
- [ ] `golden_matrix report` — генерация HTML report из артефактов
- [ ] `golden_matrix clean` — удаление orphaned artifacts
- [ ] `golden_matrix list` — показ сценариев, комбинаций, пресетов

### Artifact structure
- [ ] Предсказуемые директории
- [ ] Базовый orphan cleanup

### CI support
- [ ] Корректные exit codes
- [ ] JSON output в предсказуемую директорию
- [ ] HTML output в предсказуемую директорию
- [ ] Headless работа
- [ ] Docs для GitHub Actions

## Критерии готовности

- Отчёт можно приложить как CI artifact
- Ревьюер без IDE понимает, что именно изменилось
- Baseline update перестаёт быть ручным процессом
- Пакет становится реально удобным для работы в команде
