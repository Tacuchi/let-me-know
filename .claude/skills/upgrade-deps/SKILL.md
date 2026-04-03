---
name: upgrade-deps
description: Auditar y actualizar dependencias de Flutter/Dart. Separa actualizaciones menores (seguras) de mayores (breaking changes). Ejecutar cuando se quieran actualizar paquetes.
---

## Contexto del proyecto

- **SDK instalado:** Flutter 3.41.6 / Dart 3.11.4
- **Constraint en pubspec.yaml:** `sdk: '>=3.10.3 <4.0.0'`
- **Org:** `dev.tacuchi` — necesario para cualquier `flutter create`

## Paso 1 — Ver estado actual

```bash
flutter pub outdated
```

Esto muestra qué paquetes tienen versiones disponibles dentro del constraint actual ("Upgradable") y cuáles requieren cambiar el constraint ("Latest").

## Paso 2 — Actualizaciones menores (sin romper)

```bash
flutter pub upgrade
flutter analyze
flutter test
```

Actualiza todos los paquetes dentro de sus constraints actuales. No cambia `pubspec.yaml`. Luego verificar que todo sigue funcionando.

## Paso 3 — Actualizaciones mayores (breaking changes)

Para cada paquete con major update, hacer uno a uno:

```bash
# Editar pubspec.yaml manualmente para subir el constraint, luego:
flutter pub get
flutter analyze
flutter test
```

### Paquetes de alto riesgo — revisar changelogs antes de subir:

| Paquete | De | A | Qué revisar |
|---|---|---|---|
| `flutter_bloc` | ^8.1.6 | ^9.1.1 | API de Cubit/BlocListener puede cambiar. Revisar: https://bloclibrary.dev/migration/v9 |
| `go_router` | ^14.6.2 | ^17.2.0 | `GoRoute`, `ShellRoute`, redirects. Revisar changelog en pub.dev |
| `flutter_local_notifications` | ^18.0.1 | ^21.0.0 | Android 15 targeting changes. Revisar migration guide |
| `get_it` | ^8.0.3 | ^9.2.1 | Async initialization API puede cambiar |

### Paquetes de bajo riesgo — se pueden subir en batch:

- `flutter_timezone` ^3.0.0 → ^5.0.2
- `timezone` ^0.9.4 → ^0.11.0
- `drift` ^2.30.0 → ^2.32.1 (también subir `drift_dev` igual versión)
- `drift_flutter` ^0.2.8 → ^0.3.0
- `permission_handler` ^11.3.0 → ^12.0.1
- `flutter_lints` ^5.0.0 → ^6.0.0
- `bloc_test` ^9.1.7 → ^10.0.0 (sincronizar con `flutter_bloc`)

### Nota sobre `sqlite3_flutter_libs`

La versión `0.6.0` está marcada como **EOL** (End of Life). Revisar si hay sucesor o si `drift_flutter` ya incluye SQLite bundled.

## Paso 4 — Actualizar constraint del SDK en pubspec.yaml

Si el constraint de Dart está desfasado:

```yaml
# pubspec.yaml
environment:
  sdk: '>=3.11.0 <4.0.0'
```

## Paso 5 — Regenerar código de Drift si se actualizó drift/drift_dev

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Notas

- Siempre hacer commit antes de empezar actualizaciones
- Probar en dispositivo físico si se actualizan: `alarm`, `speech_to_text`, `flutter_tts`, `permission_handler` (dependen de comportamiento nativo)
- `pubspec.lock` está en `.gitignore` en este proyecto — no hay lock comprometido
