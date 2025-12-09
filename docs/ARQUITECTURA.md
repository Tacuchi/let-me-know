# 🏗️ Arquitectura del Proyecto Let Me Know

**Versión**: 1.0  
**Fecha**: 9 de diciembre de 2025  
**Plataforma**: Flutter (iOS/Android)

---

## 📋 Índice

1. [Visión General](#visión-general)
2. [Principios de Diseño](#principios-de-diseño)
3. [Clean Architecture Adaptada a Flutter](#clean-architecture-adaptada-a-flutter)
4. [Estructura de Carpetas](#estructura-de-carpetas)
5. [Gestión de Estado](#gestión-de-estado)
6. [Inyección de Dependencias](#inyección-de-dependencias)
7. [Navegación](#navegación)
8. [Dependencias Recomendadas](#dependencias-recomendadas)
9. [Convenciones de Código](#convenciones-de-código)
10. [Testing](#testing)

---

## 🎯 Visión General

**Let Me Know** es una aplicación móvil de recordatorios por voz diseñada para adultos y adultos mayores. La arquitectura debe ser:

- **Simple**: Fácil de entender y mantener (KISS)
- **Escalable**: Preparada para crecer sin refactorizaciones mayores
- **Testeable**: Capas desacopladas que facilitan pruebas unitarias e integración
- **Robusta**: Manejo de errores consistente y estados predecibles

---

## 🧱 Principios de Diseño

### Clean Architecture

Separación en capas concéntricas donde las dependencias apuntan **hacia adentro**:

```
┌─────────────────────────────────────────────────────┐
│                   PRESENTATION                       │
│              (UI, Widgets, Controllers)              │
├─────────────────────────────────────────────────────┤
│                    APPLICATION                       │
│                (Use Cases, BLoCs)                    │
├─────────────────────────────────────────────────────┤
│                      DOMAIN                          │
│           (Entities, Repositories Interfaces)        │
├─────────────────────────────────────────────────────┤
│                   INFRASTRUCTURE                     │
│        (Data Sources, APIs, Local Storage)           │
└─────────────────────────────────────────────────────┘
```

### Principios SOLID

| Principio | Aplicación en el Proyecto |
|-----------|---------------------------|
| **S** - Responsabilidad Única | Cada clase/widget tiene una sola razón de cambio |
| **O** - Abierto/Cerrado | Extender comportamiento sin modificar código existente |
| **L** - Sustitución de Liskov | Interfaces bien definidas para repositorios |
| **I** - Segregación de Interfaces | Interfaces pequeñas y específicas por funcionalidad |
| **D** - Inversión de Dependencias | Dependemos de abstracciones, no implementaciones |

### KISS (Keep It Simple, Stupid)

- Evitar abstracciones innecesarias
- Preferir soluciones directas sobre patrones complejos
- Documentar decisiones cuando hay trade-offs
- No sobre-ingeniar para casos hipotéticos

---

## 🏛️ Clean Architecture Adaptada a Flutter

### Capa de Dominio (Domain Layer)

**Propósito**: Contiene la lógica de negocio pura. No depende de ninguna otra capa.

```dart
// Entidad
class Reminder {
  final String id;
  final String title;
  final String description;
  final DateTime scheduledAt;
  final ReminderType type;
  final ReminderStatus status;
  
  const Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.scheduledAt,
    required this.type,
    required this.status,
  });
}

// Interfaz del Repositorio (contrato)
abstract class ReminderRepository {
  Future<List<Reminder>> getAll();
  Future<Reminder?> getById(String id);
  Future<void> save(Reminder reminder);
  Future<void> delete(String id);
  Stream<List<Reminder>> watchAll();
}
```

### Capa de Aplicación (Application Layer)

**Propósito**: Orquesta casos de uso. Contiene la lógica de aplicación.

```dart
// Use Case
class CreateReminderFromVoice {
  final ReminderRepository _repository;
  final SpeechToTextService _speechService;
  final AIClassificationService _aiService;
  
  CreateReminderFromVoice(
    this._repository,
    this._speechService,
    this._aiService,
  );
  
  Future<Reminder> execute(String audioPath) async {
    final transcription = await _speechService.transcribe(audioPath);
    final classification = await _aiService.classify(transcription);
    
    final reminder = Reminder(
      id: _generateId(),
      title: classification.title,
      description: transcription,
      scheduledAt: classification.suggestedTime,
      type: classification.type,
      status: ReminderStatus.pending,
    );
    
    await _repository.save(reminder);
    return reminder;
  }
}
```

### Capa de Infraestructura (Infrastructure Layer)

**Propósito**: Implementaciones concretas de repositorios y servicios externos.

```dart
// Implementación del Repositorio
class LocalReminderRepository implements ReminderRepository {
  final Database _database;
  
  LocalReminderRepository(this._database);
  
  @override
  Future<List<Reminder>> getAll() async {
    final records = await _database.query('reminders');
    return records.map(ReminderMapper.fromMap).toList();
  }
  
  // ... otras implementaciones
}
```

### Capa de Presentación (Presentation Layer)

**Propósito**: UI, widgets y controladores de estado.

```dart
// Widget de presentación
class ReminderListPage extends StatelessWidget {
  const ReminderListPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReminderListCubit, ReminderListState>(
      builder: (context, state) {
        return switch (state) {
          ReminderListLoading() => const LoadingIndicator(),
          ReminderListLoaded(:final reminders) => ReminderListView(reminders),
          ReminderListError(:final message) => ErrorView(message),
        };
      },
    );
  }
}
```

---

## 📁 Estructura de Carpetas

```
lib/
├── main.dart                    # Punto de entrada
├── app.dart                     # Widget raíz (MaterialApp)
│
├── core/                        # Código compartido
│   ├── constants/               # Constantes de la app
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   └── app_spacing.dart
│   ├── errors/                  # Excepciones y failures
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── extensions/              # Extensiones de Dart/Flutter
│   │   ├── context_extensions.dart
│   │   └── string_extensions.dart
│   ├── utils/                   # Utilidades
│   │   ├── date_utils.dart
│   │   └── validators.dart
│   └── widgets/                 # Widgets reutilizables
│       ├── app_button.dart
│       ├── app_card.dart
│       └── loading_indicator.dart
│
├── features/                    # Funcionalidades por módulo
│   │
│   ├── reminders/               # Feature: Recordatorios
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── reminder.dart
│   │   │   ├── repositories/
│   │   │   │   └── reminder_repository.dart
│   │   │   └── value_objects/
│   │   │       └── reminder_type.dart
│   │   │
│   │   ├── application/
│   │   │   ├── use_cases/
│   │   │   │   ├── create_reminder.dart
│   │   │   │   ├── get_reminders.dart
│   │   │   │   └── delete_reminder.dart
│   │   │   └── cubit/
│   │   │       ├── reminder_list_cubit.dart
│   │   │       └── reminder_list_state.dart
│   │   │
│   │   ├── infrastructure/
│   │   │   ├── datasources/
│   │   │   │   └── local_reminder_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── reminder_model.dart
│   │   │   └── repositories/
│   │   │       └── reminder_repository_impl.dart
│   │   │
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── reminder_list_page.dart
│   │       │   └── reminder_detail_page.dart
│   │       └── widgets/
│   │           ├── reminder_card.dart
│   │           └── reminder_filters.dart
│   │
│   ├── voice_recording/         # Feature: Grabación de voz
│   │   ├── domain/
│   │   ├── application/
│   │   ├── infrastructure/
│   │   └── presentation/
│   │
│   └── settings/                # Feature: Configuración
│       ├── domain/
│       ├── application/
│       ├── infrastructure/
│       └── presentation/
│
├── services/                    # Servicios externos
│   ├── speech_to_text/
│   │   ├── speech_to_text_service.dart
│   │   └── speech_to_text_service_impl.dart
│   ├── ai_classification/
│   │   ├── ai_service.dart
│   │   └── ai_service_impl.dart
│   └── notifications/
│       ├── notification_service.dart
│       └── notification_service_impl.dart
│
├── di/                          # Inyección de dependencias
│   └── injection_container.dart
│
└── router/                      # Navegación
    └── app_router.dart
```

---

## 🔄 Gestión de Estado

### Recomendación: **flutter_bloc** (Cubit/BLoC)

Para este proyecto se recomienda **flutter_bloc** por las siguientes razones:

| Criterio | flutter_bloc | Riverpod | Provider |
|----------|--------------|----------|----------|
| Curva de aprendizaje | Media | Media-Alta | Baja |
| Escalabilidad | Excelente | Excelente | Limitada |
| Testing | Excelente | Excelente | Bueno |
| Documentación | Extensa | Buena | Buena |
| Comunidad | Muy grande | Grande | Muy grande |
| Separación UI/Lógica | Excelente | Buena | Básica |

### Patrón Cubit (Simplificado de BLoC)

Usaremos **Cubit** en lugar de BLoC completo para mantener la simplicidad (KISS):

```dart
// Estado inmutable con sealed class (Dart 3)
sealed class ReminderListState {}

class ReminderListInitial extends ReminderListState {}

class ReminderListLoading extends ReminderListState {}

class ReminderListLoaded extends ReminderListState {
  final List<Reminder> reminders;
  final ReminderFilter filter;
  
  ReminderListLoaded({
    required this.reminders,
    this.filter = ReminderFilter.all,
  });
}

class ReminderListError extends ReminderListState {
  final String message;
  ReminderListError(this.message);
}

// Cubit
class ReminderListCubit extends Cubit<ReminderListState> {
  final GetReminders _getReminders;
  final DeleteReminder _deleteReminder;
  
  ReminderListCubit({
    required GetReminders getReminders,
    required DeleteReminder deleteReminder,
  })  : _getReminders = getReminders,
        _deleteReminder = deleteReminder,
        super(ReminderListInitial());
  
  Future<void> loadReminders() async {
    emit(ReminderListLoading());
    
    try {
      final reminders = await _getReminders();
      emit(ReminderListLoaded(reminders: reminders));
    } catch (e) {
      emit(ReminderListError('No se pudieron cargar los recordatorios'));
    }
  }
  
  Future<void> deleteReminder(String id) async {
    try {
      await _deleteReminder(id);
      await loadReminders();
    } catch (e) {
      emit(ReminderListError('No se pudo eliminar el recordatorio'));
    }
  }
}
```

### Cuándo usar BLoC completo vs Cubit

| Usar Cubit | Usar BLoC |
|------------|-----------|
| Operaciones simples | Muchos eventos diferentes |
| UI -> Acción -> Estado | Necesitas transformar eventos |
| CRUD básico | Debounce, throttle, switchMap |
| Menos código | Trazabilidad de eventos |

---

## 💉 Inyección de Dependencias

### Recomendación: **get_it** + **injectable**

```dart
// di/injection_container.dart
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  // Services
  getIt.registerLazySingleton<SpeechToTextService>(
    () => SpeechToTextServiceImpl(),
  );
  
  getIt.registerLazySingleton<NotificationService>(
    () => NotificationServiceImpl(),
  );
  
  // Data Sources
  getIt.registerLazySingleton<LocalReminderDataSource>(
    () => LocalReminderDataSource(getIt()),
  );
  
  // Repositories
  getIt.registerLazySingleton<ReminderRepository>(
    () => ReminderRepositoryImpl(getIt()),
  );
  
  // Use Cases
  getIt.registerFactory(() => CreateReminder(getIt()));
  getIt.registerFactory(() => GetReminders(getIt()));
  getIt.registerFactory(() => DeleteReminder(getIt()));
  
  // Cubits
  getIt.registerFactory(
    () => ReminderListCubit(
      getReminders: getIt(),
      deleteReminder: getIt(),
    ),
  );
}
```

### Uso con BlocProvider

```dart
// En el widget
BlocProvider(
  create: (context) => getIt<ReminderListCubit>()..loadReminders(),
  child: const ReminderListPage(),
)
```

---

## 🧭 Navegación

### Recomendación: **go_router**

Go_router es la solución oficial recomendada por el equipo de Flutter para navegación declarativa.

```dart
// router/app_router.dart
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/reminders',
      name: 'reminders',
      builder: (context, state) => const ReminderListPage(),
      routes: [
        GoRoute(
          path: ':id',
          name: 'reminder-detail',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ReminderDetailPage(reminderId: id);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/record',
      name: 'record',
      builder: (context, state) => const VoiceRecordingPage(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);
```

### Navegación en la App

```dart
// Navegar
context.go('/reminders');
context.goNamed('reminder-detail', pathParameters: {'id': '123'});

// Push (mantiene historial)
context.push('/record');

// Pop
context.pop();
```

---

## 📦 Dependencias Recomendadas

### pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Estado
  flutter_bloc: ^8.1.6
  
  # Inyección de dependencias
  get_it: ^8.0.2
  
  # Navegación
  go_router: ^14.6.2
  
  # Base de datos local
  drift: ^2.22.1
  sqlite3_flutter_libs: ^0.5.28
  path_provider: ^2.1.5
  path: ^1.9.1
  
  # Utilidades
  equatable: ^2.0.7           # Comparación de objetos
  fpdart: ^1.1.1              # Functional programming (Either, Option)
  intl: ^0.19.0               # Internacionalización
  
  # Audio/Voz
  record: ^5.1.2              # Grabación de audio
  speech_to_text: ^7.0.0      # Transcripción
  
  # Notificaciones
  flutter_local_notifications: ^18.0.1
  
  # UI
  cupertino_icons: ^1.0.8
  flutter_animate: ^4.5.0     # Animaciones

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # Linting
  flutter_lints: ^5.0.0
  
  # Testing
  bloc_test: ^9.1.7
  mocktail: ^1.0.4
  
  # Code generation (drift)
  drift_dev: ^2.22.1
  build_runner: ^2.4.13
```

---

## 📝 Convenciones de Código

### Nomenclatura

| Tipo | Convención | Ejemplo |
|------|------------|---------|
| Archivos | snake_case | `reminder_list_page.dart` |
| Clases | PascalCase | `ReminderListCubit` |
| Variables | camelCase | `reminderList` |
| Constantes | camelCase/SCREAMING_SNAKE | `defaultTimeout` / `MAX_RETRIES` |
| Privados | _camelCase | `_loadReminders()` |

### Organización de Imports

```dart
// 1. Dart SDK
import 'dart:async';

// 2. Flutter
import 'package:flutter/material.dart';

// 3. Paquetes externos (alfabético)
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// 4. Imports del proyecto (por capa)
import 'package:let_me_know/core/constants/app_colors.dart';
import 'package:let_me_know/features/reminders/domain/entities/reminder.dart';
import 'package:let_me_know/features/reminders/presentation/widgets/reminder_card.dart';
```

### Widgets

```dart
// ✅ Preferir const constructors
const ReminderCard({super.key, required this.reminder});

// ✅ Separar lógica de UI
// ❌ No hacer esto:
onPressed: () async {
  await repository.delete(id);
  await repository.getAll();
  setState(() { ... });
}

// ✅ Hacer esto:
onPressed: () => context.read<ReminderListCubit>().deleteReminder(id),
```

---

## 🧪 Testing

### Estructura de Tests

```
test/
├── core/
│   └── utils/
│       └── date_utils_test.dart
│
├── features/
│   └── reminders/
│       ├── domain/
│       │   └── entities/
│       │       └── reminder_test.dart
│       ├── application/
│       │   ├── use_cases/
│       │   │   └── create_reminder_test.dart
│       │   └── cubit/
│       │       └── reminder_list_cubit_test.dart
│       └── infrastructure/
│           └── repositories/
│               └── reminder_repository_impl_test.dart
│
└── widget_test.dart
```

### Ejemplo de Test para Cubit

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetReminders extends Mock implements GetReminders {}

void main() {
  late ReminderListCubit cubit;
  late MockGetReminders mockGetReminders;
  
  setUp(() {
    mockGetReminders = MockGetReminders();
    cubit = ReminderListCubit(getReminders: mockGetReminders);
  });
  
  blocTest<ReminderListCubit, ReminderListState>(
    'emite [Loading, Loaded] cuando loadReminders es exitoso',
    build: () {
      when(() => mockGetReminders())
          .thenAnswer((_) async => [testReminder]);
      return cubit;
    },
    act: (cubit) => cubit.loadReminders(),
    expect: () => [
      isA<ReminderListLoading>(),
      isA<ReminderListLoaded>(),
    ],
  );
}
```

---

## 🚀 Próximos Pasos

1. [ ] Configurar estructura de carpetas base
2. [ ] Agregar dependencias al `pubspec.yaml`
3. [ ] Implementar inyección de dependencias
4. [ ] Crear entidades del dominio
5. [ ] Implementar feature de recordatorios
6. [ ] Implementar feature de grabación de voz
7. [ ] Implementar feature de configuración
8. [ ] Agregar tests unitarios
9. [ ] Conectar con servicios de IA para clasificación

---

## 📚 Referencias

- [Flutter Bloc Documentation](https://bloclibrary.dev)
- [Go Router Documentation](https://pub.dev/packages/go_router)
- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [ResoCoder Flutter Clean Architecture](https://resocoder.com/flutter-clean-architecture-tdd/)

---

*Este documento está vivo y se actualizará conforme el proyecto evolucione.*

