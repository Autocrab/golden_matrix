# Технические риски

## Хрупкость golden-тестов
Inherent проблема golden testing. Минимизируется через дисциплину окружения: фиксированные шрифты, отключённые анимации, стабильный layout environment.

## Различия платформ
macOS / Linux / CI runner могут давать разные результаты рендеринга. Нужна документация по настройке детерминированного окружения и рекомендации по CI runners.

## Шрифты
Самая частая причина нестабильности golden tests. Решение: явная загрузка шрифтов в тестовом окружении, документация.

## Анимации
Незавершённые анимации = flaky goldens. Решение: принудительное отключение анимаций в тестовом shell.

## Размер матрицы
Полная декартова матрица на большом проекте может создать тысячи скриншотов. Решение: sampling strategies (pairwise, smoke, priority-based) — ключевая фича.

## Backend strategy
Зависимость от внешнего backend (alchemist и т.п.) может создать ограничения по API и версиям. Решение: абстрактный adapter layer, но только когда это реально нужно (не раньше v0.9).

## Метрики успеха

### Adoption
- Likes / downloads на pub.dev
- Issues и feature requests
- GitHub stars
- Реальные команды в CI

### Quality
- Median setup time
- Время первого успешного прогона
- Количество заменённых ручных golden tests

### Stability
- Flakiness rate
- Repeatability across CI runs
- False-positive diff frequency
