# 🔧 Opciones de Backend para Let Me Know

**Versión**: 1.0  
**Fecha**: 9 de diciembre de 2025  
**Autor**: Análisis técnico  

---

## 📋 Índice

1. [Resumen Ejecutivo](#resumen-ejecutivo)
2. [Análisis de Requerimientos](#análisis-de-requerimientos)
3. [Opciones de Arquitectura](#opciones-de-arquitectura)
   - [Opción A: Local + APIs Externas](#opción-a-local--apis-externas-sin-backend-propio)
   - [Opción B: Backend as a Service (BaaS)](#opción-b-backend-as-a-service-baas)
   - [Opción C: Backend Propio](#opción-c-backend-propio)
4. [Comparativa de Servicios de IA](#comparativa-de-servicios-de-ia)
5. [Matriz de Decisión](#matriz-de-decisión)
6. [Recomendación Final](#recomendación-final)
7. [Plan de Implementación](#plan-de-implementación)

---

## 📊 Resumen Ejecutivo

**Let Me Know** es una aplicación de recordatorios por voz para adultos mayores que requiere:
- Reconocimiento de voz (Speech-to-Text)
- Clasificación inteligente con IA/LLM
- Almacenamiento de datos
- Notificaciones locales
- Posible sincronización en la nube

### Conclusión Rápida

| Aspecto | Recomendación |
|---------|---------------|
| **Mejor calidad/precio** | 🥇 **Local + APIs (Opción A)** |
| **Mejor para escalar rápido** | 🥈 Supabase (Opción B) |
| **Mejor control total** | 🥉 Backend Propio (Opción C) |

**Recomendación principal**: Comenzar con la **Opción A** (arquitectura local + APIs externas) que puede funcionar con **$0/mes** para desarrollo y muy bajo costo en producción (~$5-15/mes para miles de usuarios).

---

## 📝 Análisis de Requerimientos

### Funcionalidades Core

| Funcionalidad | Componente Técnico | Requiere Backend |
|---------------|-------------------|------------------|
| Grabar audio | `record` package (local) | ❌ No |
| Transcribir voz | Speech-to-Text API | ⚡ Solo API |
| Clasificar con IA | LLM API | ⚡ Solo API |
| Almacenar recordatorios | SQLite / Cloud DB | 🔄 Opcional |
| Notificaciones | `flutter_local_notifications` | ❌ No |
| Sincronización | Cloud DB | ✅ Sí |
| Contactos emergencia | Push/SMS | ✅ Sí |
| Backup de datos | Cloud Storage | 🔄 Opcional |

### Flujo de Datos Principal

```
┌──────────────┐     ┌─────────────────┐     ┌──────────────────┐
│   Usuario    │────►│  Grabación      │────►│  Speech-to-Text  │
│   habla      │     │  Audio (local)  │     │  API (cloud)     │
└──────────────┘     └─────────────────┘     └────────┬─────────┘
                                                      │
                                                      ▼
┌──────────────┐     ┌─────────────────┐     ┌──────────────────┐
│   SQLite     │◄────│  Recordatorio   │◄────│  LLM Clasifica   │
│   (local)    │     │  Estructurado   │     │  (Gemini/GPT)    │
└──────────────┘     └─────────────────┘     └──────────────────┘
       │
       ▼
┌──────────────────────────────────────────────────────────────┐
│              Notificaciones Locales (programadas)             │
└──────────────────────────────────────────────────────────────┘
```

---

## 🏗️ Opciones de Arquitectura

### Opción A: Local + APIs Externas (Sin Backend Propio)

Esta arquitectura utiliza almacenamiento local con SQLite y llama directamente a APIs de terceros para IA.

#### Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                     FLUTTER APP                              │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│   ┌───────────────┐    ┌───────────────┐                    │
│   │    SQLite     │    │   Shared      │                    │
│   │  (reminders)  │    │  Preferences  │                    │
│   └───────────────┘    └───────────────┘                    │
│                                                              │
│   ┌───────────────────────────────────────────────────────┐ │
│   │              HTTP Client (dio/http)                   │ │
│   └───────────────┬───────────────┬───────────────────────┘ │
│                   │               │                          │
└───────────────────┼───────────────┼──────────────────────────┘
                    │               │
                    ▼               ▼
            ┌───────────────┐ ┌───────────────┐
            │ Google Gemini │ │ Whisper API   │
            │ (clasificar)  │ │ (transcribir) │
            └───────────────┘ └───────────────┘
```

#### Componentes

| Componente | Tecnología | Costo |
|------------|-----------|-------|
| **Almacenamiento** | SQLite + sqflite | **Gratis** |
| **Configuración** | SharedPreferences | **Gratis** |
| **Speech-to-Text** | OpenAI Whisper API | $0.006/min |
| **Clasificación IA** | Google Gemini Flash | **Gratis** (free tier) |
| **Notificaciones** | flutter_local_notifications | **Gratis** |
| **Backup** | Export JSON a archivo local | **Gratis** |

#### Estimación de Costos Mensuales

| Escenario | Recordatorios/mes | Costo Speech-to-Text | Costo IA | **Total** |
|-----------|-------------------|---------------------|----------|-----------|
| Desarrollo | 100 | $0.60 | $0 | **~$1** |
| Usuario individual | 150 | $0.90 | $0 | **~$1** |
| 100 usuarios | 15,000 | $90 | $0 | **~$90** |
| 1,000 usuarios | 150,000 | $900 | ~$10 | **~$910** |

*Asumiendo ~1 minuto de grabación por recordatorio*

#### Ventajas ✅

- **Simplicidad máxima**: No hay servidor que mantener
- **Costo inicial $0**: Todo funciona con free tiers
- **Privacidad**: Datos en el dispositivo del usuario
- **Funciona offline**: Excepto al crear recordatorios
- **Rápido de implementar**: 1-2 semanas

#### Desventajas ❌

- Sin sincronización entre dispositivos
- Sin backup automático en la nube
- API keys expuestas en el cliente (requiere ofuscación)
- Contactos de emergencia limitados (solo local)

#### Mitigación de Riesgos

| Riesgo | Solución |
|--------|----------|
| API keys expuestas | Usar Cloud Functions mínimas como proxy |
| Sin backup | Export/Import manual a JSON |
| Sin sync | Implementar sync manual con Google Drive |

---

### Opción B: Backend as a Service (BaaS)

Utiliza servicios administrados como Firebase o Supabase para backend completo.

#### B.1: Firebase (Google)

```
┌─────────────────────────────────────────────────────────────┐
│                     FLUTTER APP                              │
├─────────────────────────────────────────────────────────────┤
│   firebase_core, cloud_firestore, firebase_auth             │
│   firebase_storage, firebase_messaging                       │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                        FIREBASE                              │
├──────────────┬──────────────┬──────────────┬────────────────┤
│  Firestore   │   Auth       │  Cloud       │   Cloud        │
│  (NoSQL DB)  │  (usuarios)  │  Storage     │   Functions    │
└──────────────┴──────────────┴──────────────┴────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │  Cloud Functions │
                    │  (proxy IA APIs) │
                    └─────────────────┘
```

##### Precios Firebase (Diciembre 2025)

| Servicio | Free Tier (Spark) | Pay-as-you-go (Blaze) |
|----------|-------------------|----------------------|
| **Firestore Storage** | 1 GiB | $0.18/GiB/mes |
| **Firestore Reads** | 50,000/día | $0.06/100K reads |
| **Firestore Writes** | 20,000/día | $0.18/100K writes |
| **Auth (email)** | 50,000 MAU | Gratis |
| **Cloud Storage** | 5 GB | $0.026/GB |
| **Functions** | 2M invocaciones/mes | $0.40/millón |

##### Estimación Mensual Firebase

| Escenario | Costo Estimado |
|-----------|---------------|
| Desarrollo/Prototipo | **$0** (free tier) |
| 100 usuarios activos | **$0-5** |
| 1,000 usuarios activos | **$15-30** |
| 10,000 usuarios activos | **$100-200** |

#### B.2: Supabase (Open Source)

```
┌─────────────────────────────────────────────────────────────┐
│                     FLUTTER APP                              │
├─────────────────────────────────────────────────────────────┤
│   supabase_flutter, supabase_auth                           │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                       SUPABASE                               │
├──────────────┬──────────────┬──────────────┬────────────────┤
│  PostgreSQL  │    Auth      │   Storage    │    Edge        │
│  (relacional)│  (usuarios)  │  (archivos)  │   Functions    │
└──────────────┴──────────────┴──────────────┴────────────────┘
```

##### Precios Supabase (Diciembre 2025)

| Plan | Precio | Database | Storage | Bandwidth | MAUs |
|------|--------|----------|---------|-----------|------|
| **Free** | $0/mes | 500 MB | 1 GB | 5 GB | 50,000 |
| **Pro** | $25/mes | 8 GB | 100 GB | 250 GB | 100,000 |
| **Team** | $599/mes | 8 GB | 100 GB | 250 GB | Ilimitados |

> ⚠️ **Nota**: Los proyectos Free se pausan después de 1 semana de inactividad.

#### Comparativa Firebase vs Supabase

| Criterio | Firebase | Supabase |
|----------|----------|----------|
| **Base de datos** | NoSQL (Firestore) | SQL (PostgreSQL) |
| **Curva aprendizaje** | Media | Media-Baja |
| **Flutter SDK** | Excelente | Muy bueno |
| **Open Source** | ❌ No | ✅ Sí |
| **Self-hosting** | ❌ No | ✅ Sí |
| **Consultas SQL** | ❌ No | ✅ Sí |
| **Tiempo real** | ✅ Excelente | ✅ Bueno |
| **Documentación** | Extensa | Buena |
| **Vendor lock-in** | Alto | Bajo |
| **Free tier** | Generoso | Generoso |

#### Ventajas BaaS ✅

- Sincronización automática entre dispositivos
- Autenticación lista para usar
- Backup automático
- Push notifications fáciles
- Escalabilidad automática
- Seguridad incorporada (Row Level Security)

#### Desventajas BaaS ❌

- Costo mensual recurrente (después de free tier)
- Dependencia de terceros (vendor lock-in con Firebase)
- Complejidad adicional en la arquitectura
- Latencia de red en todas las operaciones

---

### Opción C: Backend Propio

Construir y mantener un servidor propio.

#### Arquitectura Backend Propio

```
┌─────────────────────────────────────────────────────────────┐
│                     FLUTTER APP                              │
├─────────────────────────────────────────────────────────────┤
│   dio HTTP client, JWT auth                                  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    LOAD BALANCER                             │
│                   (nginx / cloudflare)                       │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      API SERVER                              │
│              (Node.js / Python FastAPI / Go)                 │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│   /api/reminders    /api/auth    /api/transcribe            │
│                                                              │
└─────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┼───────────────┐
              ▼               ▼               ▼
       ┌──────────┐   ┌──────────────┐  ┌───────────┐
       │PostgreSQL│   │    Redis     │  │   S3/R2   │
       │ (datos)  │   │   (cache)    │  │ (archivos)│
       └──────────┘   └──────────────┘  └───────────┘
```

#### Opciones de Hosting

| Proveedor | Tipo | Costo Mínimo/mes | Incluye |
|-----------|------|------------------|---------|
| **Railway** | PaaS | $5 | Server + DB |
| **Render** | PaaS | $7 | Server + DB |
| **Fly.io** | PaaS | $0-5 | Server (DB separada) |
| **DigitalOcean** | VPS | $6 | 1GB RAM droplet |
| **Hetzner** | VPS | $4 | 2GB RAM (EU) |
| **Vercel/Netlify** | Serverless | $0-20 | Functions only |

#### Stack Recomendado para Backend Propio

**Opción 1: Node.js (TypeScript)**
```
- Framework: Express.js / Fastify / Hono
- ORM: Prisma / Drizzle
- Auth: Passport.js / Jose (JWT)
- Validación: Zod
```

**Opción 2: Python**
```
- Framework: FastAPI
- ORM: SQLAlchemy / Prisma
- Auth: FastAPI-Users
- Validación: Pydantic
```

#### Estimación de Costos Backend Propio

| Componente | Servicio | Costo/mes |
|------------|----------|-----------|
| **Servidor API** | Railway / Render | $5-15 |
| **Base de datos** | Railway Postgres / PlanetScale | $0-10 |
| **Almacenamiento** | Cloudflare R2 | $0-5 |
| **CDN/Proxy** | Cloudflare | $0 |
| **Monitoreo** | Sentry free tier | $0 |
| **Total** | | **$5-30/mes** |

#### Ventajas Backend Propio ✅

- Control total del código y datos
- Sin vendor lock-in
- Optimizable según necesidades
- Puede ser más barato a gran escala
- Aprendizaje técnico valioso

#### Desventajas Backend Propio ❌

- **Tiempo de desarrollo**: 4-8 semanas adicionales
- **Mantenimiento continuo**: Actualizaciones, seguridad, uptime
- **Escalabilidad manual**: Debes configurar todo
- **DevOps requerido**: Despliegues, logs, monitoreo
- **Único punto de fallo**: Si tu servidor cae, la app no funciona

---

## 🤖 Comparativa de Servicios de IA

### Speech-to-Text (Transcripción de Voz)

| Servicio | Costo/minuto | Calidad Español | Latencia | Free Tier |
|----------|--------------|-----------------|----------|-----------|
| **OpenAI Whisper API** | $0.006 | ⭐⭐⭐⭐⭐ Excelente | ~2s | No |
| **Google Cloud STT** | $0.024 | ⭐⭐⭐⭐ Muy buena | ~1s | 60 min/mes |
| **Azure Speech** | $0.017 | ⭐⭐⭐⭐ Muy buena | ~1s | 5 hrs/mes |
| **Deepgram** | $0.007 | ⭐⭐⭐⭐ Muy buena | <1s | $200 créditos |
| **AssemblyAI** | $0.012 | ⭐⭐⭐⭐ Muy buena | ~2s | 100 hrs/mes |

**🥇 Recomendación**: **OpenAI Whisper** - Mejor calidad en español, precio competitivo.

**Alternativa local**: `speech_to_text` package de Flutter usa el reconocimiento nativo del dispositivo (gratis, funciona offline, pero menor precisión).

### LLM para Clasificación

| Servicio | Costo | Free Tier | Calidad | Velocidad |
|----------|-------|-----------|---------|-----------|
| **Google Gemini Flash** | $0.075/M tokens | 1M tokens/min ✅ | ⭐⭐⭐⭐ | Rápido |
| **Google Gemini Pro** | $1.25/M tokens | 2 req/min | ⭐⭐⭐⭐⭐ | Medio |
| **OpenAI GPT-4o-mini** | $0.15/M input | No | ⭐⭐⭐⭐⭐ | Rápido |
| **Claude 3 Haiku** | $0.25/M input | No | ⭐⭐⭐⭐ | Rápido |
| **Groq (Llama 3)** | Gratis | Sí, limitado | ⭐⭐⭐ | Muy rápido |

**🥇 Recomendación**: **Google Gemini Flash** - Free tier muy generoso, excelente para clasificación simple.

### Prompt de Clasificación Sugerido

```
Analiza el siguiente recordatorio de voz y extrae información estructurada.

Texto: "{transcripción}"

Responde SOLO con JSON válido:
{
  "title": "título corto (máx 50 chars)",
  "type": "medicine|appointment|call|shopping|task|event",
  "datetime": "ISO 8601 o null si no se menciona",
  "confidence": 0.0-1.0
}

Tipos:
- medicine: medicamentos, pastillas, tratamientos
- appointment: citas médicas, doctores, hospitales
- call: llamadas telefónicas, contactar personas
- shopping: compras, supermercado, tienda
- task: tareas generales
- event: eventos, reuniones, cumpleaños
```

---

## 📊 Matriz de Decisión

### Criterios de Evaluación (1-5)

| Criterio | Peso | Opción A (Local+APIs) | Opción B1 (Firebase) | Opción B2 (Supabase) | Opción C (Propio) |
|----------|------|----------------------|---------------------|---------------------|-------------------|
| **Costo inicial** | 25% | 5 | 5 | 5 | 2 |
| **Costo escalado** | 15% | 4 | 3 | 4 | 5 |
| **Tiempo desarrollo** | 20% | 5 | 4 | 4 | 2 |
| **Mantenimiento** | 15% | 5 | 4 | 4 | 2 |
| **Funcionalidades** | 10% | 3 | 5 | 5 | 5 |
| **Privacidad datos** | 10% | 5 | 3 | 4 | 5 |
| **Vendor lock-in** | 5% | 5 | 2 | 4 | 5 |
| **TOTAL** | 100% | **4.55** | **4.00** | **4.25** | **3.25** |

### Resumen de Puntuación

| Opción | Puntuación | Mejor Para |
|--------|------------|------------|
| 🥇 **A: Local + APIs** | 4.55 | MVP, presupuesto limitado, desarrollo rápido |
| 🥈 **B2: Supabase** | 4.25 | Multi-dispositivo, equipos, SQL lovers |
| 🥉 **B1: Firebase** | 4.00 | Ecosistema Google, tiempo real crítico |
| **C: Backend Propio** | 3.25 | Control total, escala masiva, aprendizaje |

---

## ✅ Recomendación Final

### Para Let Me Know: **Opción A (Local + APIs)** con posibilidad de evolución

#### ¿Por qué?

1. **Simplicidad**: El caso de uso principal (recordatorios personales) no requiere sincronización.

2. **Costo $0 para empezar**: Gemini tiene free tier generoso, Whisper es muy barato.

3. **Privacidad**: Adultos mayores valoran que sus datos queden en su dispositivo.

4. **Offline First**: La app funciona sin internet (excepto al crear recordatorios).

5. **Time to Market**: 1-2 semanas vs 4-6 semanas con backend.

### Arquitectura Recomendada

```
┌─────────────────────────────────────────────────────────────┐
│                     LET ME KNOW APP                          │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────────────────────────────────────────────────┐│
│  │                    PRESENTATION                          ││
│  │   VoiceRecordingPage → ReminderListPage → SettingsPage  ││
│  └─────────────────────────────────────────────────────────┘│
│                              │                               │
│  ┌─────────────────────────────────────────────────────────┐│
│  │                    APPLICATION                           ││
│  │   CreateReminderUseCase    GetRemindersUseCase          ││
│  │   TranscribeAudioUseCase   ClassifyReminderUseCase      ││
│  └─────────────────────────────────────────────────────────┘│
│                              │                               │
│  ┌─────────────────────────────────────────────────────────┐│
│  │                     DOMAIN                               ││
│  │   Reminder    ReminderRepository    AIService           ││
│  └─────────────────────────────────────────────────────────┘│
│                              │                               │
│  ┌─────────────────────────────────────────────────────────┐│
│  │                  INFRASTRUCTURE                          ││
│  │                                                          ││
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  ││
│  │  │   SQLite    │  │   Whisper   │  │  Gemini Flash   │  ││
│  │  │ Repository  │  │   Service   │  │    Service      │  ││
│  │  └─────────────┘  └─────────────┘  └─────────────────┘  ││
│  │                                                          ││
│  └─────────────────────────────────────────────────────────┘│
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Costos Proyectados

| Fase | Usuarios | Costo/mes | Notas |
|------|----------|-----------|-------|
| **Desarrollo** | 1-5 | $0-5 | Testing con free tiers |
| **Beta** | 50-100 | $10-20 | Whisper + algo de Gemini |
| **Lanzamiento** | 500-1,000 | $50-100 | Whisper principalmente |
| **Crecimiento** | 5,000+ | $300-500 | Considerar migración a BaaS |

---

## 📅 Plan de Implementación

### Fase 1: MVP Local (2-3 semanas)

| Semana | Tareas |
|--------|--------|
| **1** | - Implementar grabación de audio con `record` package<br>- Integrar SQLite para persistencia<br>- Configurar flutter_local_notifications |
| **2** | - Integrar OpenAI Whisper API para transcripción<br>- Integrar Google Gemini para clasificación<br>- Implementar flujo completo crear recordatorio |
| **3** | - Pulir UI/UX de lista de recordatorios<br>- Implementar configuración (tamaño texto, sonidos)<br>- Testing con usuarios reales |

### Fase 2: Mejoras (2 semanas)

- Modo offline con cola de transcripciones pendientes
- Export/Import de recordatorios (JSON/CSV)
- Widget de iOS/Android para acceso rápido
- Guías de voz (TTS) para accesibilidad

### Fase 3: Sincronización Opcional (si se requiere)

Si los usuarios demandan sincronización entre dispositivos:

1. **Migrar a Supabase** (menor lock-in que Firebase)
2. Implementar autenticación simple (email/magic link)
3. Sincronizar recordatorios con PostgreSQL
4. Mantener SQLite como cache local

---

## 🔐 Consideraciones de Seguridad

### Para Opción A (Local + APIs)

| Riesgo | Mitigación |
|--------|------------|
| API keys en cliente | Usar variables de entorno + ofuscación con `flutter_dotenv` |
| Datos sensibles | Cifrar SQLite con `sqflite_sqlcipher` |
| Comunicación | HTTPS obligatorio para todas las APIs |

### Ofuscación de API Keys

```dart
// lib/core/config/api_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // Cargar desde .env (no commitear al repo)
  static String get whisperApiKey => dotenv.env['WHISPER_API_KEY'] ?? '';
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
}
```

```bash
# .env (agregar a .gitignore)
WHISPER_API_KEY=sk-...
GEMINI_API_KEY=AIza...
```

---

## 📚 Recursos Adicionales

### Paquetes Flutter Recomendados

```yaml
dependencies:
  # Audio
  record: ^5.1.2                    # Grabación de audio
  just_audio: ^0.9.40               # Reproducción de audio
  
  # APIs
  dio: ^5.7.0                       # HTTP client
  flutter_dotenv: ^5.2.1            # Variables de entorno
  
  # Almacenamiento
  sqflite: ^2.4.1                   # SQLite
  sqflite_sqlcipher: ^3.1.0         # SQLite cifrado (opcional)
  
  # Notificaciones
  flutter_local_notifications: ^18.0.1
  
  # Permisos
  permission_handler: ^11.3.1       # Solicitar permisos
```

### Documentación de APIs

- [OpenAI Whisper API](https://platform.openai.com/docs/guides/speech-to-text)
- [Google Gemini API](https://ai.google.dev/gemini-api/docs)
- [Flutter Record Package](https://pub.dev/packages/record)
- [SQLite en Flutter](https://docs.flutter.dev/cookbook/persistence/sqlite)

---

## 🔄 Evolución Futura

```
                    FASE 1                FASE 2              FASE 3
                    (MVP)               (Mejoras)          (Escala)
                      │                     │                  │
     ┌────────────────┼─────────────────────┼──────────────────┼─────────────►
     │                │                     │                  │
     ▼                ▼                     ▼                  ▼
┌─────────┐     ┌───────────┐        ┌───────────┐      ┌───────────┐
│ Local   │     │ + Offline │        │ + Cloud   │      │ Backend   │
│ + APIs  │ ──► │ + Export  │  ──►   │   Sync    │ ──►  │ Propio    │
│         │     │ + Widgets │        │ (Supabase)│      │ (si >10k) │
└─────────┘     └───────────┘        └───────────┘      └───────────┘
   $0-20/mes       $0-20/mes           $25-50/mes         $50-200/mes
```

---

*Este documento es una guía viva y debe actualizarse conforme el proyecto evolucione y los precios de servicios cambien.*

**Última actualización**: Diciembre 2025
