# 🔔 Let Me Know

> Asistente de recordatorios por voz para adultos y adultos mayores

[![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**Let Me Know** es una aplicación móvil que permite crear, gestionar y consultar recordatorios usando la voz, con inteligencia artificial que aprende patrones y responde preguntas de forma natural.

<p align="center">
  <img src="assets/icons/play_store_512.png" alt="Let Me Know" width="120"/>
</p>

---

## ✨ Características

| Funcionalidad | Descripción |
|---------------|-------------|
| 🎤 **Voz primero** | Crea recordatorios hablando naturalmente |
| 🧠 **IA inteligente** | Detecta patrones y sugiere recurrencias |
| 📍 **Notas consultables** | "¿Dónde dejé mis llaves?" y responde por voz |
| 🔔 **Alertas inteligentes** | Repetición automática para medicamentos |
| ♿ **Accesible** | Interfaz grande, clara, con feedback auditivo |

## 🎯 Casos de Uso

```
👤 "Tomar pastillas a las 3pm"     → 💊 Recordatorio + notificación
👤 "Tomar pastillas a las 9pm"     → 🔄 Detecta patrón → sugiere recurrencia
👤 "Dejé llaves en la cómoda"      → 📍 Nota guardada (sin alarma)
👤 "¿Dónde dejé mis llaves?"       → 🔊 "En la cómoda de la habitación"
```

## 🛠️ Stack Tecnológico

| Capa | Tecnología |
|------|------------|
| Frontend | Flutter |
| Estado | flutter_bloc |
| Backend | Supabase |
| IA | OpenAI Whisper + Google Gemini |
| DB Local | SQLite |

## 📁 Estructura del Proyecto

```
lib/
├── core/           # Utilidades, constantes, widgets compartidos
├── di/             # Inyección de dependencias
├── features/       # Módulos por funcionalidad
│   ├── reminders/  # Gestión de recordatorios
│   ├── voice/      # Grabación y transcripción
│   └── settings/   # Configuración
└── router/         # Navegación
```

## 🚀 Instalación

```bash
# Clonar
git clone https://github.com/tacuchi/let-me-know.git
cd let-me-know

# Instalar dependencias
flutter pub get

# Ejecutar
flutter run
```

## 📖 Documentación

| Documento | Descripción |
|-----------|-------------|
| [Requerimientos Funcionales](docs/requerimientos-funcionales.md) | Casos de uso y especificaciones |
| [Arquitectura](docs/ARQUITECTURA.md) | Clean Architecture y patrones |
| [Backend Options](docs/backend-options.md) | Análisis de opciones de backend |
| [UI Specs](docs/) | Especificaciones de pantallas |

## 🗺️ Roadmap

- [x] Estructura base (Clean Architecture)
- [x] Navegación y pantallas
- [ ] Grabación de audio
- [ ] Integración Speech-to-Text
- [ ] Clasificación con IA
- [ ] Detección de patrones
- [ ] Consultas por voz
- [ ] Backend Supabase

## 📄 Licencia

MIT © 2025

---

<p align="center">
  Hecho con ❤️ para quienes más queremos
</p>
