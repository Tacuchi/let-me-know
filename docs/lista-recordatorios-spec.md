# Especificación UI: Mis Recordatorios

**Tipo**: List Screen  
**Plataforma**: Mobile (iOS/Android)  
**Ancho máximo**: 428px  
**Sistema de diseño**: Material 3  
**Audiencia**: Adultos y adultos mayores  

---

## 🎨 Paleta de Colores (Heredada)

| Token | Valor | Uso |
|-------|-------|-----|
| `--bg-primary` | `#FDF8F3` | Fondo principal |
| `--bg-secondary` | `#FFFFFF` | Tarjetas |
| `--accent-primary` | `#E88B5A` | Acentos, FAB |
| `--accent-secondary` | `#7DCFB6` | Recordatorios activos |
| `--text-primary` | `#3D3D3D` | Texto principal |
| `--completed` | `#A8D5BA` | Recordatorios completados |
| `--pending` | `#FFE0B2` | Recordatorios pendientes |
| `--overdue` | `#FFCDD2` | Recordatorios vencidos |

---

## 🏗️ Estructura de Componentes

### 1. Header con Filtros

```
┌─────────────────────────────────────────────┐
│  ←   Mis Recordatorios              🔍  (?) │
├─────────────────────────────────────────────┤
│  [Todos]  [Hoy]  [Pendientes]  [Completados]│
└─────────────────────────────────────────────┘
```

**Propiedades Header**:
- Altura: 56px
- Botón atrás: 44x44px
- Título: 22px, weight 600
- Íconos: búsqueda y ayuda (44x44px touch)

**Chips de Filtro**:
- Altura: 40px
- Padding horizontal: 16px
- Border-radius: 20px
- Scroll horizontal si no caben
- Chip activo: Background `--accent-primary`, texto blanco
- Chip inactivo: Background `#F0F0F0`, texto `--text-primary`

---

### 2. Resumen del Día

```
┌─────────────────────────────────────────────┐
│  ☀️ Hoy, Lunes 9 de Diciembre               │
│                                             │
│   ┌───────┐  ┌───────┐  ┌───────┐          │
│   │   3   │  │   1   │  │   2   │          │
│   │Pendien│  │Vencido│  │Comple.│          │
│   └───────┘  └───────┘  └───────┘          │
└─────────────────────────────────────────────┘
```

**Tarjeta Resumen**:
- Padding: 16px
- Background: `--bg-secondary`
- Border-radius: 16px
- Margin: 16px
- Shadow: `0 2px 8px rgba(0,0,0,0.06)`

**Contadores**:
- Tamaño número: 28px, weight 700
- Tamaño etiqueta: 14px
- Colores según estado (pendiente/vencido/completado)

---

### 3. Lista de Recordatorios

```
┌─────────────────────────────────────────────┐
│  📅 Próximos                                │
├─────────────────────────────────────────────┤
│ ┌─────────────────────────────────────────┐ │
│ │ 💊  Tomar pastillas                     │ │
│ │     Hoy, 8:00 AM                    ⏰  │ │
│ │     ━━━━━━━━░░░░ En 2 horas            │ │
│ └─────────────────────────────────────────┘ │
│                                             │
│ ┌─────────────────────────────────────────┐ │
│ │ 🏥  Cita con el doctor                  │ │
│ │     Mañana, 10:30 AM                📍  │ │
│ │     Hospital San José                   │ │
│ └─────────────────────────────────────────┘ │
│                                             │
│ ┌─────────────────────────────────────────┐ │
│ │ 📞  Llamar a María                      │ │
│ │     Mañana, 3:00 PM                 👤  │ │
│ └─────────────────────────────────────────┘ │
├─────────────────────────────────────────────┤
│  ✅ Completados hoy                         │
├─────────────────────────────────────────────┤
│ ┌─────────────────────────────────────────┐ │
│ │ ✓  Comprar pan                     ✓    │ │
│ │     Completado a las 9:15 AM            │ │
│ └─────────────────────────────────────────┘ │
└─────────────────────────────────────────────┘
```

**Tarjeta Recordatorio**:
- Min-height: 80px
- Padding: 16px
- Background: `--bg-secondary`
- Border-radius: 16px
- Margin-bottom: 12px
- Border-left: 4px solid (color según tipo)
- Shadow: `0 2px 6px rgba(0,0,0,0.05)`

**Tipos de Recordatorio (detectados por LLM)**:

| Tipo | Ícono | Color borde | Descripción |
|------|-------|-------------|-------------|
| Medicamento | 💊 | `#7DCFB6` | Pastillas, medicinas |
| Cita médica | 🏥 | `#81D4FA` | Doctores, hospitales |
| Llamada | 📞 | `#CE93D8` | Contactar personas |
| Compras | 🛒 | `#FFE082` | Lista de compras |
| Tarea | 📝 | `#FFAB91` | Tareas generales |
| Evento | 📅 | `#90CAF9` | Eventos, reuniones |

**Contenido Tarjeta**:
- Título: 18px, weight 500
- Fecha/hora: 16px, color `--text-secondary`
- Barra de progreso: 4px altura (para recordatorios con tiempo)
- Ícono tipo: 24px (izquierda)
- Ícono acción: 20px (derecha)

**Estados Visuales**:
| Estado | Estilo |
|--------|--------|
| Activo | Background blanco, texto normal |
| Próximo (< 2h) | Borde pulsante suave, badge "Pronto" |
| Vencido | Background `--overdue` suave, texto rojo |
| Completado | Texto tachado, opacity 0.7 |

---

### 4. FAB (Botón Flotante)

```
┌─────────────────────────────────────────────┐
│                                             │
│                                      ┌────┐ │
│                                      │ 🎤 │ │
│                                      └────┘ │
└─────────────────────────────────────────────┘
```

**Propiedades FAB**:
- Dimensiones: 64x64px
- Border-radius: 32px
- Background: `--accent-primary`
- Ícono: 28px (micrófono blanco)
- Shadow: `0 4px 12px rgba(232,139,90,0.4)`
- Posición: bottom 80px, right 16px
- Animación: Bounce suave al cargar

---

### 5. Barra de Navegación Inferior

```
┌─────────────────────────────────────────────┐
│    🏠         📋           ⚙️              │
│   Inicio   Recordatorios  Configuración     │
│             [activo]                        │
└─────────────────────────────────────────────┘
```

(Mismas propiedades que pantalla principal, con "Recordatorios" activo)

---

## 🔄 Interacciones

### Swipe en Tarjeta

```
← Deslizar izquierda: [Eliminar] (rojo)
→ Deslizar derecha: [Completar] (verde)
```

**Acciones Swipe**:
- Threshold: 100px para activar
- Feedback háptico al activar
- Íconos grandes (32px) en zona de swipe
- Confirmación por voz: "Recordatorio completado" / "Recordatorio eliminado"

### Tap en Tarjeta

Abre detalle del recordatorio con opciones:
- Editar
- Posponer (15min, 1h, mañana)
- Marcar completado
- Eliminar

### Pull to Refresh

- Indicador circular naranja
- Texto: "Actualizando..."

---

## 🔍 Búsqueda

```
┌─────────────────────────────────────────────┐
│  🔍  Buscar recordatorio...           ✕    │
├─────────────────────────────────────────────┤
│                                             │
│  Búsquedas recientes:                       │
│  • pastillas                                │
│  • doctor                                   │
│                                             │
└─────────────────────────────────────────────┘
```

**Campo Búsqueda**:
- Altura: 52px
- Border-radius: 26px
- Background: `#F5F5F5`
- Ícono búsqueda: 24px
- Placeholder: 18px
- Búsqueda en tiempo real (debounce 300ms)

---

## 📱 Estados de Pantalla

### Estado Vacío

```
┌─────────────────────────────────────────────┐
│                                             │
│              📭                             │
│                                             │
│      No tienes recordatorios aún            │
│                                             │
│    Toca el micrófono para crear             │
│         tu primer recordatorio              │
│                                             │
│         [🎤 Crear recordatorio]             │
│                                             │
└─────────────────────────────────────────────┘
```

### Estado Cargando

- Skeleton cards (3 placeholders animados)
- Indicador de carga central si tarda > 2s

### Estado Error

```
┌─────────────────────────────────────────────┐
│              😕                             │
│                                             │
│   No pudimos cargar tus recordatorios       │
│                                             │
│         [Intentar de nuevo]                 │
└─────────────────────────────────────────────┘
```

---

## ♿ Accesibilidad

### Anuncios de Voz

| Acción | Anuncio |
|--------|---------|
| Abrir pantalla | "Mis recordatorios. Tienes [N] pendientes para hoy" |
| Navegar lista | "[Tipo]. [Título]. [Fecha y hora]" |
| Completar swipe | "Recordatorio [título] marcado como completado" |
| Eliminar swipe | "Recordatorio [título] eliminado" |

### Agrupación Lógica

- Recordatorios agrupados por sección (Próximos, Completados)
- Navegación por encabezados disponible
- Orden de lectura: Filtros → Resumen → Lista

---

## 💡 Notas de Implementación

1. **Ordenamiento**: Por defecto ordenar por fecha/hora más próxima
2. **Agrupación**: Agrupar por día cuando hay múltiples días
3. **Caché**: Mantener lista en memoria para navegación rápida
4. **Sincronización**: Actualizar en background cada 5 minutos
5. **Notificaciones**: Badge en ícono de app con conteo de vencidos
