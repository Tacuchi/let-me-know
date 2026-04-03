---
name: check-drift
description: Regenerate Drift database code after schema changes. Use after modifying app_database.dart or any Drift table definition.
---

Run:

```
dart run build_runner build --delete-conflicting-outputs
```

This regenerates `*.g.dart` files for Drift. After completion, confirm `lib/core/database/drift/app_database.g.dart` was updated.

If the build fails, show the full error output — common causes are:
- Missing import in `app_database.dart`
- Incompatible column type changes without a migration
- Drift schema version not bumped after table changes
