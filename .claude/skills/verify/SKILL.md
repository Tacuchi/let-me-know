---
name: verify
description: Run full project verification — lint, test, and format check before committing. Use after making significant changes.
---

Run the following commands in sequence, stopping on first failure:

1. `flutter analyze` — static analysis and lint
2. `flutter test` — run all tests
3. `dart format --set-exit-if-changed .` — verify formatting (exit non-zero if any file needs formatting)

Report results for each step. If a step fails, show the relevant output and stop — do not run subsequent steps.

If `dart format` fails, run `dart format .` to fix formatting, then report which files were changed.
