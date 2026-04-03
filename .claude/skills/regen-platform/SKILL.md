---
name: regen-platform
description: Regenerar carpetas de plataforma (android, ios) con las últimas plantillas de Flutter, preservando todas las customizaciones del proyecto. Usar cuando se quiera actualizar el scaffold de plataforma a la versión actual del SDK.
disable-model-invocation: true
---

## ⚠️ ADVERTENCIA

Este proceso elimina y regenera la carpeta de plataforma. **Lee todo antes de ejecutar.**

Las customizaciones de este proyecto **se perderían** si no se restauran:
- `android/app/build.gradle.kts` — signing config, ProGuard, Java 17, desugaring
- `android/app/src/main/AndroidManifest.xml` — 15+ permisos, receivers, queries, Application class
- `android/app/src/main/kotlin/dev/tacuchi/let_me_know/MainActivity.kt` — 200+ líneas, MethodChannel, OEM handling
- `android/app/src/main/kotlin/dev/tacuchi/let_me_know/LetMeKnowApplication.kt` — app lifecycle/alarm
- `android/app/proguard-rules.pro` — reglas de ProGuard
- `android/app/src/main/res/` — splash screens, iconos adaptativos, temas night/v31
- `android/gradle.properties` — JVM args `-Xmx8G -XX:MaxMetaspaceSize=4G`
- `android/key.properties` — credenciales de signing (gitignored, solo local)

## Estrategia recomendada: Delete + Regenerate + Restore desde git

```bash
# Desde la raíz del proyecto: /Users/tacuchi/Git/let-me-know

# 1. Asegúrate de que todos tus cambios están commiteados
git status

# 2. Elimina la carpeta de plataforma
rm -rf android   # o ios

# 3. Regenera el scaffold con el Flutter instalado
flutter create \
  --org dev.tacuchi \
  --project-name let_me_know \
  --platforms android \
  .

# 4. Restaura TODAS tus customizaciones desde git
git checkout -- android/

# 5. Verifica qué cambios quedaron (debería ser solo archivos de infraestructura)
git diff android/
```

## ¿Qué archivos se regeneran distintos?

Después del paso 4, `git diff android/` mostrará solo los archivos de infraestructura que Flutter actualizó:
- `android/gradle/wrapper/gradle-wrapper.properties` (versión de Gradle)
- `android/settings.gradle.kts` (versiones de AGP y Kotlin)
- `android/gradlew` / `android/gradlew.bat` (scripts de Gradle)

Estos son los que realmente quieres actualizar. **Haz `git add` solo de esos.**

## Alternativa: Actualizar solo archivos de infraestructura

Si solo quieres actualizar Gradle/AGP/Kotlin sin regenerar toda la carpeta:

```bash
# Ver versión actual de Gradle
cat android/gradle/wrapper/gradle-wrapper.properties

# Editar manualmente para subir la versión:
# distributionUrl=https\://services.gradle.org/distributions/gradle-X.X-all.zip
```

Y en `android/settings.gradle.kts`:
```kotlin
id("com.android.application") version "X.X.X" apply false
id("org.jetbrains.kotlin.android") version "X.X.X" apply false
```

## Plataformas disponibles

```bash
# Regenerar Android
flutter create --org dev.tacuchi --project-name let_me_know --platforms android .

# Regenerar iOS
flutter create --org dev.tacuchi --project-name let_me_know --platforms ios .

# Agregar una plataforma nueva (ej. web, que no existe actualmente)
flutter create --org dev.tacuchi --project-name let_me_know --platforms web .
```

## NUNCA usar `--overwrite`

`flutter create --overwrite` sobreescribe también:
- `pubspec.yaml` (¡borra todas las dependencias!)
- `lib/main.dart` (¡reemplaza con la app counter!)
- `analysis_options.yaml`
- `README.md`

No usar nunca directamente.

## Versiones actuales del proyecto (referencia)

| Componente | Versión instalada |
|---|---|
| Flutter | 3.41.6 |
| Dart | 3.11.4 |
| AGP (Android Gradle Plugin) | 8.11.1 |
| Kotlin | 2.2.20 |
| Gradle | 8.14 |
| compileSdk / targetSdk | 36 |
| minSdk | 24 |
