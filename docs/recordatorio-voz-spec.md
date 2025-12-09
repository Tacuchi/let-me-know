# Especificación UI: Crear Recordatorio por Voz

**Tipo**: Voice Input Screen  
**Plataforma**: Mobile (iOS/Android)  
**Ancho máximo**: 428px  
**Sistema de diseño**: Material 3  
**Audiencia**: Adultos y adultos mayores  

---

## 🎨 Paleta de Colores

| Token | Valor | Uso |
|-------|-------|-----|
| `--bg-primary` | `#FDF8F3` | Fondo principal (beige cálido) |
| `--bg-secondary` | `#FFFFFF` | Tarjetas y contenedores |
| `--accent-primary` | `#E88B5A` | Botón micrófono, acentos (naranja suave) |
| `--accent-secondary` | `#7DCFB6` | Botón confirmar (verde menta) |
| `--text-primary` | `#3D3D3D` | Texto principal (gris oscuro) |
| `--text-secondary` | `#6B6B6B` | Texto secundario |
| `--text-helper` | `#8B8B8B` | Placeholders y ayudas |
| `--error` | `#E57373` | Estados de error |
| `--recording` | `#FF7043` | Estado grabando (naranja intenso) |

---

## 📐 Tipografía (Accesible)

| Elemento | Tamaño | Peso | Line-height |
|----------|--------|------|-------------|
| Título header | 24px | 600 | 1.3 |
| Instrucción principal | 20px | 500 | 1.4 |
| Texto transcripción | 18px | 400 | 1.5 |
| Botones acción | 18px | 600 | 1.2 |
| Texto ayuda | 16px | 400 | 1.4 |
| Navegación | 14px | 500 | 1.2 |

---

## 🏗️ Estructura de Componentes

### 1. Header
```
┌─────────────────────────────────────────────┐
│  🏠  Mi Asistente de Recordatorios    (?)   │
│                                       [Ayuda]│
└─────────────────────────────────────────────┘
```

**Propiedades**:
- Altura: 64px
- Padding: 16px horizontal
- Background: `--bg-secondary`
- Shadow: `0 2px 8px rgba(0,0,0,0.08)`
- Ícono ayuda: 44x44px touch target (accesibilidad)
- Al tocar ayuda: Activa guía de voz explicativa

---

### 2. Área de Instrucción y Micrófono

```
┌─────────────────────────────────────────────┐
│                                             │
│         "Toca el micrófono para             │
│          grabar tu recordatorio"            │
│                                             │
│              ┌─────────┐                    │
│              │   🎤    │  ← Botón 88x88px   │
│              │         │                    │
│              └─────────┘                    │
│                                             │
│           "Toca para hablar"                │
│                                             │
└─────────────────────────────────────────────┘
```

**Botón Micrófono**:
- Dimensiones: 88x88px
- Border-radius: 50%
- Background: `--accent-primary`
- Ícono: 40px (blanco)
- Shadow: `0 4px 16px rgba(232,139,90,0.4)`
- Touch target: 96x96px mínimo

**Estados del botón**:
| Estado | Visual | Texto instrucción |
|--------|--------|-------------------|
| Inactivo | Fondo naranja sólido | "Toca para hablar" |
| Grabando | Animación pulse + ondas | "Escuchando..." |
| Procesando | Spinner interno | "Procesando audio..." |
| Error | Borde rojo | "Intenta de nuevo" |

**Animación grabando**:
```css
@keyframes pulse-recording {
  0% { transform: scale(1); box-shadow: 0 0 0 0 rgba(255,112,67,0.7); }
  70% { transform: scale(1.05); box-shadow: 0 0 0 20px rgba(255,112,67,0); }
  100% { transform: scale(1); box-shadow: 0 0 0 0 rgba(255,112,67,0); }
}
```

---

### 3. Área de Transcripción

```
┌─────────────────────────────────────────────┐
│  📝 Tu recordatorio                         │
│  ─────────────────────────────────────────  │
│ ┌─────────────────────────────────────────┐ │
│ │                                         │ │
│ │  "Recordarme tomar las pastillas        │ │
│ │   mañana a las 8 de la mañana"          │ │
│ │                                         │ │
│ │                              ✏️ Editar  │ │
│ └─────────────────────────────────────────┘ │
│                                             │
│  ✅ Transcripción lista                     │
│                                             │
└─────────────────────────────────────────────┘
```

**Caja de texto**:
- Min-height: 120px
- Max-height: 200px (scrollable)
- Padding: 16px
- Border: 2px solid `#E0E0E0`
- Border-radius: 16px
- Background: `--bg-secondary`
- Font-size: 18px (mínimo accesible)
- Placeholder: "Tu recordatorio aparecerá aquí..."

**Indicador de estado**:
- Badge con ícono + texto
- Estados: "Esperando...", "Transcribiendo...", "✅ Listo"
- Color según estado

---

### 4. Botones de Acción

```
┌─────────────────────────────────────────────┐
│                                             │
│  ┌─────────────────────────────────────┐    │
│  │     ✓  Confirmar recordatorio       │    │
│  └─────────────────────────────────────┘    │
│                                             │
│  ┌─────────────────────────────────────┐    │
│  │     🎤  Volver a grabar             │    │
│  └─────────────────────────────────────┘    │
│                                             │
└─────────────────────────────────────────────┘
```

**Botón Confirmar** (Primario):
- Width: 100%
- Height: 56px
- Background: `--accent-secondary` (#7DCFB6)
- Color: #FFFFFF
- Border-radius: 28px
- Font-size: 18px, weight: 600
- Ícono: ✓ a la izquierda

**Botón Volver a grabar** (Secundario):
- Width: 100%
- Height: 52px
- Background: transparent
- Border: 2px solid `--accent-primary`
- Color: `--accent-primary`
- Border-radius: 26px
- Margin-top: 12px

---

### 5. Barra de Navegación Inferior

```
┌─────────────────────────────────────────────┐
│    🏠         📋           ⚙️              │
│   Inicio   Recordatorios  Configuración     │
└─────────────────────────────────────────────┘
```

**Propiedades**:
- Altura: 64px
- Background: `--bg-secondary`
- Shadow top: `0 -2px 8px rgba(0,0,0,0.06)`
- Items: 3 columnas iguales
- Touch target: 48x48px mínimo por ícono
- Texto: 14px
- Íconos: 28px
- Item activo: Color `--accent-primary`

---

## ♿ Accesibilidad

### Requisitos WCAG 2.1 AA

| Criterio | Implementación |
|----------|----------------|
| Contraste texto | Mínimo 4.5:1 (texto normal), 3:1 (texto grande) |
| Touch targets | Mínimo 44x44px (recomendado 48x48px) |
| Focus visible | Outline 3px `--accent-primary` |
| Texto escalable | Soporta hasta 200% zoom |
| Feedback háptico | Vibración suave al iniciar/detener grabación |

### Guías de Voz (TalkBack/VoiceOver)

| Elemento | Anuncio |
|----------|---------|
| Botón micrófono | "Botón grabar recordatorio. Toca dos veces para comenzar a grabar" |
| Durante grabación | "Grabando. Toca dos veces para detener" |
| Transcripción | "Campo de texto editable. [contenido]. Toca dos veces para editar" |
| Botón confirmar | "Botón confirmar recordatorio. Toca dos veces para guardar" |

---

## 📱 Estados de Pantalla

### Estado 1: Inicial
- Botón micrófono visible y prominente
- Caja transcripción vacía con placeholder
- Botones de acción deshabilitados (opacity 0.5)

### Estado 2: Grabando
- Botón micrófono con animación pulse
- Texto "Escuchando..." animado
- Ondas de sonido visuales opcionales
- Vibración háptica al iniciar

### Estado 3: Procesando
- Spinner en botón micrófono
- Texto "Procesando audio..."
- Caja transcripción muestra indicador de carga

### Estado 4: Transcripción Lista
- Texto transcrito visible en caja
- Badge "✅ Listo" visible
- Botones de acción habilitados
- Botón editar visible

### Estado 5: Editando
- Caja de texto en modo edición
- Teclado visible
- Botón "Guardar cambios" adicional

---

## 🔄 Flujo de Interacción

```
[Inicio] 
    │
    ▼
[Usuario toca micrófono]
    │
    ▼
[Grabando audio] ──────► [Feedback visual + háptico]
    │
    ▼
[Usuario suelta/toca de nuevo]
    │
    ▼
[Procesando con IA] ──────► [Indicador de carga]
    │
    ▼
[Transcripción mostrada]
    │
    ├──► [Editar] ──► [Modificar texto] ──► [Guardar]
    │
    ├──► [Volver a grabar] ──► [Inicio]
    │
    └──► [Confirmar] ──► [LLM procesa tipo de recordatorio]
                              │
                              ▼
                        [Notificación programada]
                              │
                              ▼
                        [Confirmación al usuario]
```

---

## 💡 Notas de Implementación

1. **Feedback inmediato**: Cada interacción debe tener respuesta visual en < 100ms
2. **Tolerancia a errores**: Si falla la transcripción, ofrecer reintentar con mensaje amigable
3. **Modo offline**: Guardar grabación localmente si no hay conexión
4. **Historial**: Mantener últimos 3 recordatorios para acceso rápido
5. **Configuración de voz**: Permitir ajustar velocidad de guías de voz en configuración

---

## 🎯 Métricas de Éxito

- Tiempo promedio para crear recordatorio: < 30 segundos
- Tasa de éxito de transcripción: > 95%
- Tasa de abandono: < 10%
- Satisfacción de usuario (adultos mayores): > 4.5/5
