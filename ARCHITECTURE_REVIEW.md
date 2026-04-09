# Architecture Review: `golden_matrix`

Date: 2026-04-09

Scope:
- Architectural review only
- No code changes
- Focus areas: SOLID, DRY, KISS, magic numbers, Dart/Flutter best practices

Reviewed artifacts:
- `lib/`
- `test/`
- `example/`
- `pubspec.yaml`
- `analysis_options.yaml`
- Static analysis and test run results

Validation performed:
- `dart analyze` via Dart MCP
- `flutter test` via Dart MCP

High-level result:
- The project is generally compact, readable, and not overengineered.
- Core matrix generation logic is reasonably isolated and has good unit-test coverage.
- The main problems are in the test infrastructure and public API orchestration layers:
  - duplicated control flow
  - tight coupling to `MaterialApp`
  - incomplete cleanup of mutable test environment state
  - filesystem/environment heuristics embedded in runtime APIs
  - a few weakly typed or brittle implementation details

---

## 1. Executive Summary

The package has a good basic structure for its size:
- `models/` contains lightweight data structures
- `core/` contains generation, naming, reporting logic
- `flutter/` contains Flutter-specific helpers
- `api/` exposes public entry points

That layering is directionally correct. The main issue is that the current layers are not fully enforced by the implementation. Some public APIs over-promise flexibility but are internally tied to a specific widget root (`MaterialApp`), while some infrastructure code mixes domain concerns with side effects such as file discovery and SDK probing.

The result is a codebase that looks clean on the surface, but has several architectural seams that will become expensive as the package evolves:
- adding more app-root types
- supporting more output structures
- improving report handling
- testing on different CI and local environments
- maintaining identical behavior between `matrixGolden` and `screenMatrixGolden`

The code passes tests and analysis, but the most risky parts are also the least covered by tests.

---

## 2. What Is Good

### 2.1 Sensible module split

The separation into `api`, `core`, `flutter`, and `models` is appropriate for a small Flutter package.

Strengths:
- matrix generation logic is not embedded directly in test declarations
- naming strategy is extracted from execution logic
- pairwise generation is isolated into its own file
- simple models keep the public API easy to understand

This is aligned with KISS:
- the code is small
- classes are narrowly scoped in many places
- there is no unnecessary abstraction stack

### 2.2 Good unit-test coverage for core combinatorics

The strongest part of the codebase is test coverage around:
- Cartesian generation
- smoke sampling
- priority-based sampling
- pairwise reduction
- naming conventions
- model serialization

This is important because matrix combinatorics are the highest-risk pure logic part of the library.

Covered well:
- `MatrixGenerator`
- `PairwiseGenerator`
- `NamingStrategy`
- model behaviors such as slugs and JSON serialization

### 2.3 Limited surface area

The package avoids unnecessary dependencies and keeps the API relatively small. That is a strength.

Positive signals:
- no obvious framework-level overengineering
- no unnecessary service locators, DI frameworks, or builder chains
- no speculative abstractions

For a package of this size, restraint is good.

---

## 3. Main Architectural Findings

## 3.1 Public API says “generic”, implementation says “Material-only”

Severity: High

Files:
- `lib/src/api/screen_matrix_golden.dart`
- `lib/src/api/matrix_golden.dart`
- `lib/src/flutter/matrix_widget_wrapper.dart`

### Problem

`screenMatrixGolden` presents itself as a more flexible API where the user provides a fully configured app through `appBuilder`.

That implies the library should be agnostic to the root widget type as long as the built widget is renderable and suitable for a golden comparison.

In practice, the implementation is tightly coupled to `MaterialApp`:
- golden comparison searches `find.byType(MaterialApp)`
- documentation explicitly frames the builder around `MaterialApp`
- component wrapper always creates a `MaterialApp`

This means the library does not actually honor the abstraction boundary it exposes.

### Why this is an architectural issue

This violates the spirit of OCP and DIP:
- OCP: adding support for other app roots requires changing internal implementation instead of relying on an abstract contract
- DIP: public API accepts a generic `Widget Function(MatrixCombination)` but internal logic depends on a concrete framework type

This also creates documentation drift:
- the API appears flexible
- the implementation is not flexible

### Practical consequences

Potential breakage or limitation for users who want:
- `CupertinoApp`
- `WidgetsApp`
- custom root widget wrappers
- tests without `MaterialApp`
- nested app shells or non-standard test roots

Even if those use cases are not needed today, the API already suggests they should be possible.

### Evidence

Relevant implementation points:
- `screenMatrixGolden` uses `find.byType(MaterialApp)` for matching
- `matrixGolden` does the same
- `MatrixWidgetWrapper` hardcodes `MaterialApp`

### Better architectural direction

At a design level, the matcher target should be based on one of these ideas:
- compare the root widget passed to `pumpWidget`
- compare a configurable finder
- compare a known stable child container under package control

The key point is that the public abstraction and the internal dependency should match.

---

## 3.2 Global test view state is not reliably restored on failure

Severity: High

Files:
- `lib/src/api/matrix_golden.dart`
- `lib/src/api/screen_matrix_golden.dart`
- `lib/src/flutter/pump_helpers.dart`

### Problem

The package mutates global test view state through:
- `tester.view.physicalSize`
- `tester.view.devicePixelRatio`

That is normal for golden testing, but cleanup is not guaranteed.

Currently:
- configure view
- pump widget
- settle
- run golden expectation
- reset view

If anything throws before `resetView`, the test leaves shared mutable state behind.

Examples of throw points:
- `pumpWidget`
- `pumpAndSettle`
- `expectLater`
- widget build exceptions
- assertion failures

### Why this matters

This is an infrastructure correctness issue, not just style.

Golden and widget tests run in a shared process. If global view state leaks:
- later tests can observe the wrong size
- device pixel ratio can remain overridden
- failures become order-dependent
- debugging becomes significantly harder

This is a classic side-effect isolation problem.

### Principle impact

This conflicts with best practices for test utilities:
- infrastructure should clean up after itself even under failure
- setup and teardown of mutable environment must be exception-safe

It also weakens SRP:
- test orchestration is responsible for both execution and state mutation
- but does not robustly own the full lifecycle of that mutation

### Better architectural direction

At the design level, mutable test-environment configuration should be wrapped in a failure-safe lifecycle:
- `try/finally`
- or dedicated setup/teardown utilities with guaranteed cleanup

This should be applied uniformly to both public APIs.

---

## 3.3 `matrixGolden` and `screenMatrixGolden` duplicate the same orchestration logic

Severity: High

Files:
- `lib/src/api/matrix_golden.dart`
- `lib/src/api/screen_matrix_golden.dart`

### Problem

These two public APIs duplicate almost the entire execution pipeline:
- effective axes and sampling resolution
- rule merging
- tag filtering
- matrix generation
- grouping by scenario
- `Stopwatch` management
- result collection
- test description generation
- `testWidgets` loop
- success/failure report recording
- `tearDownAll` report writing

The main actual difference is only how the widget tree is produced:
- component API wraps scenario widget with package shell
- screen API delegates to `appBuilder`

### Why this is a problem

This is the biggest DRY violation in the package.

Consequences:
- behavior drift risk
- fixes must be applied twice
- subtle inconsistency becomes likely over time
- review burden increases
- bugs in one path may not exist in the other

This duplication is especially risky because the duplicated logic is core public behavior.

### Concrete symptoms already visible

Both files contain nearly identical:
- grouping logic
- error handling
- report creation
- golden path resolution
- test description generation

There is already duplicated private `_testDescription` logic as well.

### SOLID perspective

This also touches SRP:
- each public entry point is handling too many responsibilities:
  - API argument normalization
  - matrix generation
  - widget construction
  - test execution
  - result collection
  - report flushing

A more coherent design would extract the shared orchestration into one internal runner and inject only the “build widget for combination” part.

### Better architectural direction

Architecturally, the package wants a single internal execution engine with pluggable widget-building strategy.

That would reduce:
- code duplication
- divergence risk
- number of places that must understand test/report lifecycle

---

## 3.4 Component wrapper is too opinionated and may distort tested layout

Severity: Medium-High

Files:
- `lib/src/flutter/matrix_widget_wrapper.dart`

### Problem

The wrapper does more than provide test environment dependencies. It imposes a full visual shell:
- `MaterialApp`
- `Directionality`
- `MediaQuery`
- `Scaffold`
- `Center`

That is convenient, but architecturally too opinionated for a generic component testing utility.

### Why this matters

A test wrapper should provide the minimum environment necessary for deterministic rendering.

Adding `Scaffold` and `Center` can change:
- layout constraints
- alignment
- intrinsic sizing behavior
- overflow behavior
- scroll behavior
- edge-to-edge rendering
- safe area interaction

That means the package is not only configuring environment; it is also modifying presentation semantics.

### Principle impact

This conflicts with KISS and least-surprise:
- simple component tests become easier initially
- but the wrapper silently changes the tested conditions

It also touches SRP:
- environment provisioning
- layout composition
- app shell construction

All of these are bundled into one widget.

### Concrete risk examples

Widgets that may be distorted by `Center` or `Scaffold`:
- widgets expecting max width
- widgets meant to pin to screen edges
- scrollables
- widgets depending on ambient scaffold features
- components whose parent constraints are part of the visual contract

### Better architectural direction

A cleaner architecture would distinguish:
- required environment
- optional shell/layout decisions

Those should not be inseparable by default.

---

## 3.5 Report writing mixes domain result handling with filesystem heuristics

Severity: Medium-High

Files:
- `lib/src/core/matrix_report_writer.dart`

### Problem

`MatrixReportWriter` takes a domain result object and decides where files should be written by guessing from:
- the first result path
- whether the file exists
- hardcoded search prefixes:
  - `test/`
  - `test/golden/`
  - `test/goldens/`

This is brittle.

### Why this is an architectural issue

The class is combining two separate concerns:
- report serialization/rendering
- discovery of project-specific output directory

This violates SRP.

The package currently assumes a small set of filesystem layouts. That creates hidden coupling between:
- naming strategy
- current working directory
- test file location
- report output location

### Practical consequences

This can become wrong for:
- custom `fileNameBuilder`
- monorepos
- non-standard goldens directory structures
- tests invoked from different working directories
- future support for multiple report destinations

It also means report output is inferred indirectly instead of being explicitly defined.

### Best-practice issue

Heuristic discovery may be acceptable as fallback behavior, but not as the architectural center of a writer class.

### Better architectural direction

Conceptually, the writer should receive an explicit output destination or a dedicated resolved context object, instead of inferring it from observed side effects.

---

## 3.6 Environment probing in `font_loader.dart` is tightly coupled and hard to test

Severity: Medium

Files:
- `lib/src/flutter/font_loader.dart`

### Problem

`loadAppFonts()` does several jobs:
- initializes test binding
- loads manifest-based fonts
- tracks loaded families
- finds Flutter SDK location
- probes environment variables
- runs `which flutter`
- resolves symlinks
- loads Roboto from SDK cache

This is too much responsibility for one runtime helper.

### Why this matters

This utility depends on machine state:
- environment variables
- PATH contents
- symlink layout
- SDK cache layout
- local filesystem

That makes behavior less deterministic and harder to test.

### SOLID/KISS impact

SRP:
- font manifest loading and SDK discovery are different responsibilities

KISS:
- the method does not remain simple because environment fallback logic is embedded directly into it

DIP:
- instead of depending on an abstract font source/provider concept, the code directly reaches into the OS and filesystem

### Additional implementation smell

The code uses synchronous process and filesystem checks in helper routines:
- `Process.runSync`
- `existsSync`
- direct `File` and `Directory` probing

This is not always wrong in test tooling, but it increases coupling to execution environment and makes failures more opaque.

### Better architectural direction

A more maintainable design would separate:
- manifest font loading
- optional Roboto fallback policy
- Flutter SDK discovery

Even without introducing full abstraction layers, separating policy from probing would improve readability and testability.

---

## 3.7 Weak typing in `MatrixGenerator._addDelta`

Severity: Medium

Files:
- `lib/src/core/matrix_generator.dart`

### Problem

The `_addDelta` helper accepts:
- `dynamic theme`
- `dynamic device`

Then later casts and accesses `.name`.

### Why this is a problem

This is unnecessary because the package already has strong types:
- `MatrixTheme`
- `MatrixDevice`

Using `dynamic` here:
- weakens compile-time safety
- makes refactoring harder
- hides the intended contract
- increases chances of runtime-only failure

### Principle impact

Dart best practices:
- avoid `dynamic` unless it is genuinely needed

KISS:
- introducing dynamic behavior where static types already exist makes the code more complex, not less

### Why it matters architecturally

This is not a catastrophic issue, but it is a sign that the core generator is starting to bend around implementation convenience instead of keeping a strong internal contract.

That is often how clean domain logic gradually becomes brittle.

---

## 3.8 Public API orchestration has too many responsibilities

Severity: Medium

Files:
- `lib/src/api/matrix_golden.dart`
- `lib/src/api/screen_matrix_golden.dart`

### Problem

Each API function currently handles all of the following:
- normalize config
- derive scenarios
- generate matrix combinations
- group combinations
- build test cases
- manage stopwatch lifecycle
- collect result objects
- perform golden matching
- write JSON report
- write HTML report

### Why this matters

For the current size, this is still manageable, but it is already at the point where a change in one policy affects many unrelated concerns.

Typical symptoms of excessive responsibility:
- identical orchestration duplicated across APIs
- hidden coupling between report collection and test execution
- difficult extension points

### SOLID impact

This is mainly an SRP problem.

Each function is acting as:
- a config adapter
- a test runner
- a result aggregator
- a report coordinator

These are separate reasons to change.

### Better architectural direction

One internal runner should own execution lifecycle. Public APIs should mostly:
- shape user input
- provide a widget-building function
- hand off to the runner

---

## 3.9 Most fragile layers are the least tested

Severity: Medium

Files:
- test coverage observation across package

### Problem

Core logic is well tested. Infrastructure and integration behavior are not.

Missing or weakly covered areas:
- `matrixGolden`
- `screenMatrixGolden`
- `MatrixReportWriter`
- `HtmlTemplate`
- `loadAppFonts`
- test-view reset behavior on failure paths

### Why this matters

The code that most directly touches:
- Flutter test runtime
- filesystem
- HTML generation
- environment discovery

is the code with the highest integration risk.

That is exactly where more contract tests would be expected.

### Consequence

The current test suite gives strong confidence in combinatorics, but lower confidence in:
- runtime behavior under failure
- report path correctness
- platform variability
- public API guarantees

---

## 4. DRY Review

### Strong DRY violation

The biggest DRY issue in the codebase is the duplication between:
- `matrixGolden`
- `screenMatrixGolden`

This is not harmless duplication. It is behavior duplication in public infrastructure.

### Minor duplication

There are also repeated patterns in:
- slug generation on multiple models
- `_testDescription` defined twice
- result recording logic repeated in both APIs

These are less urgent than the main API duplication, but still signs that common behavior wants extraction.

### DRY conclusion

The codebase is mostly compact, but the most critical execution path violates DRY in a way that will matter as the package grows.

---

## 5. SOLID Review

### S: Single Responsibility Principle

Good:
- `PairwiseGenerator` is focused
- `NamingStrategy` is focused
- model classes are small

Problems:
- `matrixGolden` and `screenMatrixGolden` each do too much
- `loadAppFonts()` does too much
- `MatrixReportWriter` both renders/writes and discovers output location
- `MatrixWidgetWrapper` mixes environment provisioning with layout decisions

Overall SRP status:
- mixed
- strong in small utility classes
- weak in orchestration and infrastructure classes

### O: Open/Closed Principle

Good:
- matrix rules and sampling strategies suggest extensibility

Problems:
- screen API is not truly open to non-`MaterialApp` roots
- report path logic is only open to layouts anticipated by internal heuristics
- wrapper composition is not easily adjustable without changing internals

Overall OCP status:
- moderate, but weaker than the API surface suggests

### L: Liskov Substitution Principle

Not a major factor here because there is little inheritance.

No major LSP-specific issues observed.

### I: Interface Segregation Principle

Not heavily applicable because there are few formal interfaces.

However, public API parameter sets are still somewhat overloaded:
- configuration
- report behavior
- file naming
- scenario filtering

This is not severe, but there is some creeping “do everything from one function” behavior.

### D: Dependency Inversion Principle

Weak areas:
- direct dependence on `MaterialApp`
- direct dependence on filesystem layout
- direct dependence on local environment probing

The code depends more on concrete runtime mechanisms than it needs to.

Overall SOLID conclusion:
- best score on simple data and pure logic
- weakest on SRP and DIP in orchestration/infrastructure

---

## 6. KISS Review

### What stays simple

Good:
- models are straightforward
- matrix generation logic is readable
- naming strategy is simple
- pairwise algorithm implementation is understandable

### What breaks simplicity

Areas where simplicity degrades:
- duplicated public API orchestration
- wrapper doing more than users may expect
- report writer relying on path heuristics
- font loader mixing manifest loading with platform discovery
- `dynamic` in core generation path

### KISS conclusion

The package is still relatively simple overall. The issue is that some features that started as pragmatic shortcuts are now becoming part of the architecture:
- convenience wrapper assumptions
- hardcoded report path assumptions
- environment probing assumptions

That is where KISS starts to erode.

---

## 7. Magic Numbers Review

This is not the primary weakness of the codebase, but there are several places where embedded constants should at least be acknowledged.

### In models and examples

Examples:
- device sizes and safe areas in `MatrixDevice`
- text scale defaults
- spacing and sizing in example widgets/screens

Assessment:
- In `MatrixDevice`, these numbers are expected and justified because they represent preset device specs.
- In example code, hardcoded dimensions are acceptable because examples are illustrative, not framework internals.

### In scoring logic

In `MatrixGenerator._applyPriorityBased`, score weights are hardcoded:
- `+3`
- `+2`
- `+1`

Assessment:
- this is a true policy encoded as magic numbers
- it is acceptable for an initial implementation
- but the rationale is implicit, not explicit

Why it matters:
- users cannot understand why one combination outranks another except by reading implementation
- future tweaking risks accidental behavioral changes

### In HTML template

There are many style constants in `_css`.

Assessment:
- normal for a self-contained HTML report
- not the main architecture concern

### Magic numbers conclusion

No major abuse of magic numbers in core architecture.

The notable one is priority scoring. That is not urgent, but it is the main place where policy values are embedded without explicit domain explanation.

---

## 8. Dart and Flutter Best Practices Review

## 8.1 Good practices present

- clear use of immutable models with `final`
- appropriate use of `const`
- isolated pure logic in generator classes
- explicit enums for sampling and result status
- tests are readable and scenario-based

## 8.2 Best-practice concerns

### Overuse of concrete framework assumptions

The package assumes `MaterialApp` in places where a more generic approach would be healthier.

### `dynamic` where strong typing already exists

`MatrixGenerator._addDelta` is the clearest example.

### Runtime environment probing in library helper

`font_loader.dart` depends on OS process execution and local filesystem discovery.

This is acceptable in tooling if clearly isolated, but currently it is part of a public helper with too much embedded policy.

### Failure-safety in test helpers

Failure-safe cleanup is essential in testing utilities. Current cleanup is not robust enough.

### Lack of integration tests for API contracts

For a package that exposes test infrastructure, public API contract tests matter more than usual.

---

## 9. Test and Static Analysis Findings

## 9.1 Static analysis

`dart analyze` result:
- only one issue found
- issue was an unnecessary import in example test code

Interpretation:
- lint cleanliness is good
- but lint cleanliness does not mean architectural cleanliness

## 9.2 Tests

`flutter test` result:
- all tests passed

Interpretation:
- core logic is stable for currently tested cases
- lack of failing tests does not reduce the architectural concerns above, because the main concerns are in under-tested integration layers

---

## 10. Prioritized Issue List

## Priority 1

### 1. ~~MaterialApp coupling in generic-looking APIs~~ FIXED

~~Why first:~~
- ~~user-visible abstraction mismatch~~
- ~~blocks extensibility~~
- ~~likely to surprise consumers~~

**Resolution:** Replaced `find.byType(MaterialApp)` with `find.byKey(_goldenBoundaryKey)` using a `RepaintBoundary` wrapper in `matrix_test_runner.dart`. Now works with any root widget (MaterialApp, CupertinoApp, custom).

### 2. ~~Non-guaranteed reset of mutated test view state~~ FIXED

~~Why first:~~
- ~~correctness issue~~
- ~~can create cascading failures~~
- ~~infrastructure bug potential~~

**Resolution:** Wrapped test body in `try/finally` in `matrix_test_runner.dart`. `PumpHelpers.resetView()` is now guaranteed to run even on exception.

### 3. ~~Public API orchestration duplication~~ FIXED

~~Why first:~~
- ~~major maintenance risk~~
- ~~future changes become more error-prone~~

**Resolution:** Extracted shared orchestration into `runMatrixTests()` in `lib/src/api/matrix_test_runner.dart`. Both `matrixGolden` and `screenMatrixGolden` are now thin wrappers (~20 lines each) that only differ in widget building strategy.

## Priority 2

### 4. ~~Over-opinionated `MatrixWidgetWrapper`~~ FIXED

~~Why second:~~
- ~~can distort actual golden output semantics~~
- ~~affects trustworthiness of results~~

**Resolution:** Added `wrapChild` callback parameter to `MatrixWidgetWrapper` and `matrixGolden()`. Default remains `Scaffold(body: Center(child: child))` for convenience. Users can override: `wrapChild: (child) => child` for no wrapping, or any custom layout.

### 5. ~~Report writer path heuristics~~ FIXED

~~Why second:~~
- ~~brittle behavior~~
- ~~likely to become problematic with custom paths or repo structures~~

**Resolution:** Added `reportDir` parameter to `matrixGolden()`, `screenMatrixGolden()`, and `runMatrixTests()`, threaded through to `MatrixReportWriter.write(outputDir:)` / `.writeHtml(outputDir:)`. Filesystem scan (`_findGoldensDir`) retained as default fallback; explicit `reportDir` overrides it for non-standard project layouts.

### 6. `font_loader.dart` responsibility overload

Why second:
- maintainability and portability issue
- not as immediately dangerous as state leakage

## Priority 3

### 7. ~~`dynamic` in generator helper~~ FIXED

~~Why third:~~
- ~~easy to improve~~
- ~~localized issue~~
- ~~lower impact than orchestration problems~~

**Resolution:** Replaced `dynamic theme` and `dynamic device` with `MatrixTheme` and `MatrixDevice` in `_addDelta`. Added explicit imports.

### 8. ~~Missing integration coverage for infrastructure~~ FIXED

~~Why third:~~
- ~~crucial medium-term investment~~
- ~~lower urgency than fixing actual design mismatches~~

**Resolution:** Added `test/integration/` with 30 integration tests covering PumpHelpers (view state, cleanup, multi-device cycles, leak detection), MatrixWidgetWrapper (theme, locale, direction, textScale, wrapChild, debug banner), and MatrixReportWriter/HtmlTemplate (JSON/HTML file I/O, slug naming, XSS escaping, image paths, filters, empty results).

---

## 11. Recommended Refactoring Directions

This section is intentionally still at analysis level, not a patch plan.

## 11.1 Create a single internal execution engine

Target:
- one internal runner for common lifecycle

Runner responsibilities:
- resolve config
- generate combinations
- group by scenario
- manage timing
- create test cases
- collect results
- flush reports
- guarantee teardown/cleanup

Injected variation:
- widget builder for a combination
- optionally finder/target selection for golden matching

Benefits:
- major DRY reduction
- consistent behavior across APIs
- easier to extend and test

## 11.2 Separate environment provisioning from layout shell

Target:
- keep component wrapper minimal

Conceptual split:
- test environment data
- optional app shell
- optional layout framing

Benefits:
- less distortion of widget layout
- better flexibility for different component styles

## 11.3 Make report destination explicit

Target:
- reduce filesystem guessing

Benefits:
- easier reasoning
- fewer hidden assumptions
- better support for custom naming/output layouts

## 11.4 Split font loading policy from environment probing

Target:
- separate:
  - manifest loading
  - SDK fallback loading
  - SDK discovery

Benefits:
- better testability
- simpler failure modes
- easier maintenance

## 11.5 Add contract-level tests for infrastructure

Focus areas:
- cleanup on failure
- report output correctness
- generic app root handling
- wrapper behavior and layout assumptions
- path resolution behavior

Benefits:
- confidence in the actual public package contract, not only pure logic internals

---

## 12. Residual Risks If Nothing Changes

If the code remains as-is, the most likely future problems are:

- subtle divergence between `matrixGolden` and `screenMatrixGolden`
- unexpected limitations when users attempt non-`MaterialApp` roots
- flaky or order-dependent tests caused by leaked test view state
- incorrect report output locations in non-default project layouts
- font-loading issues that differ between developer machines and CI
- wrapper-induced layout artifacts being mistaken for widget behavior

---

## 13. Bottom Line

The project is in a decent state for a small package:
- small surface area
- understandable structure
- strong combinatorics coverage
- low lint noise

But the package’s core architectural weakness is this:

It presents a nicely layered testing API, while several important internal behaviors are still implemented as convenience-driven, concrete assumptions.

The most important problems are not cosmetic:
- duplicated orchestration
- hard dependency on `MaterialApp`
- unsafe cleanup of mutated test state
- filesystem and environment heuristics inside runtime helpers

Those are the issues most worth addressing before the package grows further.

---

## 14. Appendix: Reviewed File Groups

Primary library files reviewed:
- `lib/golden_matrix.dart`
- `lib/src/api/matrix_golden.dart`
- `lib/src/api/screen_matrix_golden.dart`
- `lib/src/core/matrix_generator.dart`
- `lib/src/core/matrix_report_writer.dart`
- `lib/src/core/naming_strategy.dart`
- `lib/src/core/pairwise_generator.dart`
- `lib/src/core/html_template.dart`
- `lib/src/flutter/font_loader.dart`
- `lib/src/flutter/matrix_widget_wrapper.dart`
- `lib/src/flutter/pump_helpers.dart`
- `lib/src/models/*`

Tests reviewed:
- `test/core/*`
- `test/models/*`

Example reviewed:
- `example/test/golden/sample_golden_test.dart`
- `example/lib/screens/*`
- `example/lib/widgets/*`

