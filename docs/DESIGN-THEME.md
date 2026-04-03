# Design System Specification: The Resonant Horizon

## 1. Overview & Creative North Star
This design system is built upon the creative north star of **"The Resonant Horizon."** In a voice-first accessibility landscape, the interface should not feel like a digital barrier, but rather a seamless, atmospheric extension of the user’s environment. 

We are departing from the "boxed-in" nature of standard iOS apps. By utilizing intentional asymmetry, expansive negative space, and tonal layering, we create an editorial experience that feels premium and calm. The goal is to move beyond mere "utility" and provide a "sanctuary"—a place where high-legibility typography and soft, tactile surfaces guide the user without friction.

## 2. Colors & Tonal Architecture
The palette is rooted in soft whites and breathable grays, punctuated by deep, authoritative purples and blues.

### The "No-Line" Rule
**Strict Mandate:** Designers are prohibited from using 1px solid borders for sectioning or containment. 
Structure must be achieved through:
- **Background Shifts:** Placing a `surface_container_low` section against a `surface` background.
- **Tonal Transitions:** Using subtle shifts in the Material surface tiers to define hierarchy.

### Surface Hierarchy & Nesting
Treat the UI as a physical stack of fine paper or frosted glass. 
- **Base Layer:** `surface` (#f9f9fe)
- **Secondary Tier:** `surface_container_low` (#f2f3fa) for secondary content groups.
- **Interactive Tier:** `surface_container_lowest` (#ffffff) for the highest-priority cards or input fields.

### The Glass & Gradient Rule
To provide "soul" to the interface:
- **Floating Elements:** Use Glassmorphism (80% opacity of `surface_container_lowest` with a 20px-32px backdrop blur).
- **Primary CTAs:** Utilize a subtle linear gradient from `primary` (#504dcd) to `primary_container` (#7d7cfe) at a 135-degree angle. This adds depth that flat hex codes cannot replicate.

### Importance Tokens
- **Info (Low Importance):** `secondary` (#5d5f63) / `secondary_container`
- **Low (Active/Friendly):** `tertiary_container` (#007aff)
- **Medium (Attention):** Orange (Custom Accent: #f59e0b)
- **High/Extra-High:** `error` (#a83836) / `error_container` (#fa746f)

## 3. Typography: Editorial Utility
We utilize the system font (Inter/San Francisco) but apply it with editorial intentionality. 

- **Display Scale:** Use `display-lg` (3.5rem) and `display-md` (2.75rem) for "Welcome" or "Listening" states. This creates an authoritative, trustworthy presence.
- **The Contrast Principle:** Pair a `display-sm` headline with `label-md` uppercase sub-headers (with 5-10% letter spacing) to create a high-end, curated look.
- **Accessibility First:** `body-lg` (1rem) is the absolute minimum for interactive text. All touch targets must prioritize legibility over density.

## 4. Elevation & Depth
Depth is achieved through **Tonal Layering**, not structural shadows.

- **The Layering Principle:** Instead of a drop shadow, place a `surface_container_lowest` card on a `surface_container_low` background. The subtle 2-3% difference in luminance creates a "natural lift."
- **Ambient Shadows:** For floating elements (like a voice activation button), use a shadow with a 40px blur, 0px offset, and 6% opacity of `on_surface`. This mimics natural, ambient light.
- **The "Ghost Border" Fallback:** If a container requires further definition (e.g., in high-glare environments), use the `outline_variant` (#aeb2bb) at **15% opacity**. Never use 100% opaque outlines.

## 5. Components

### Voice Interaction Hub (The Signature Component)
The core of this system. This should be a large, circular element using `primary` gradients and Glassmorphism. It does not sit in a box; it floats with an ambient shadow to signify it is "listening."

### Buttons
- **Primary:** Rounded `full` or `xl`. Uses the Primary-to-Primary-Container gradient. Height: Min 64px for accessibility.
- **Secondary:** `surface_container_highest` background with `on_surface` text. No border.
- **Tertiary:** Text-only using `primary` color, with a large hit area (min 44x44px).

### Cards & Lists
- **The No-Divider Rule:** Absolute prohibition of horizontal divider lines. 
- **Separation:** Use 24px–32px of vertical white space or a background shift to `surface_container_low`.
- **Roundedness:** Cards should use `xl` (1.5rem) corner radius to feel friendly and safe.

### Input Fields
- Use `surface_container_lowest` as the field background.
- Active states are indicated by a 2px `primary_fixed` bottom-weighted glow, rather than a full bounding box.

### Chips & Tags
- **Filter/Action Chips:** Use `secondary_container` with `on_secondary_container` text. Roundedness: `full`.

## 6. Do's and Don'ts

### Do:
- **Do** embrace asymmetry. An off-center headline can make the app feel designed rather than generated.
- **Do** use large touch targets. Accessibility is the foundation, not an afterthought.
- **Do** use `surface_bright` for areas meant to catch the user's eye without being high-alert.

### Don't:
- **Don't** use pure black (#000000) for text. Use `on_surface` (#2e333a) to maintain a soft, premium feel.
- **Don't** use standard iOS "Separator" lines. They clutter the visual field and add cognitive load.
- **Don't** cram content. If a screen feels full, it's a signal to move content to a secondary "nested" surface layer.