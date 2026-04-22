# Design System Strategy: The Nocturnal Commons

## 1. Overview & Creative North Star
The creative North Star for this design system is **"The Digital Greenhouse at Night."** We are moving away from the "utility-first" look of standard dark modes and toward a high-end editorial experience that feels architectural, organic, and intentionally layered. 

To achieve "The Modern Commons" aesthetic in a dark environment, we reject the rigid, boxed-in layouts of traditional dashboards. Instead, we use **intentional asymmetry** and **tonal depth** to guide the eye. This system treats the screen not as a flat surface, but as a glass-walled structure overlooking a dark forest. We prioritize breathing room (negative space) and use vibrant emerald accents to signify life and action against a deep, zinc-charcoal foundation.

## 2. Color Architecture
Our palette is rooted in the depth of the Earth. By using a "No-Line" philosophy, we create a sophisticated atmosphere where elements are defined by their luminosity rather than their outlines.

### The Palette (Material Design Tokens)
*   **Primary (#75DAA8):** Our "Bioluminescent Emerald." Optimized for AA accessibility against dark surfaces.
*   **Surface / Background (#131315):** A deep, charcoal base that provides the "infinite" floor for our elements.
*   **The "No-Line" Rule:** Designers are strictly prohibited from using 1px solid borders to section content. Boundaries must be defined by shifting between `surface-container-low` (#1C1B1D) and `surface-container-high` (#2A2A2C).
*   **Surface Hierarchy & Nesting:** Treat the UI as stacked sheets of tinted glass. 
    *   *Lowest:* Deepest background.
    *   *Mid-Tiers:* For content areas and sectioning.
    *   *Highest:* For interactive cards and modals that should "float" toward the user.
*   **The Glass & Gradient Rule:** For main CTAs and Hero sections, use a subtle linear gradient from `primary` (#75DAA8) to `primary_container` (#52B788). This adds a "soul" and dimension that flat hex codes lack.

## 3. Typography: Editorial Authority
We utilize **Plus Jakarta Sans** not as a system font, but as a brand voice. The hierarchy is designed to feel like a premium sustainability journal.

*   **Display (Lg/Md/Sm):** Set with tight letter-spacing (-0.02em). Use `display-lg` (3.5rem) sparingly to create dramatic entry points for hero sections.
*   **Headline & Title:** These are your navigational anchors. `headline-lg` (2.0rem) should be used to introduce major content shifts.
*   **Body (Lg/Md/Sm):** High-readability scales. `body-lg` (1rem) is our workhorse for long-form content.
*   **Label (Md/Sm):** Reserved for technical data and micro-copy. Use `on_surface_variant` (#BDCAC0) to de-emphasize labels relative to their data.

## 4. Elevation & Depth: Tonal Layering
In "The Nocturnal Commons," light is a physical material. We do not use traditional drop shadows that look like "fuzz"; we use ambient light.

*   **The Layering Principle:** Instead of a shadow, place a `surface_container_highest` (#353437) card onto a `surface` (#131315) background. The delta in luminance creates the lift.
*   **Ambient Shadows:** If an element must float (e.g., a dropdown), use a massive blur (40px+) at 6% opacity. Use a tint of the `primary` color in the shadow to simulate the emerald glow hitting the surface.
*   **The "Ghost Border" Fallback:** If a container requires a boundary (like an input field), use the `outline_variant` (#3E4942) at 20% opacity. Never use 100% opaque lines.
*   **Glassmorphism:** Apply a `backdrop-filter: blur(12px)` to floating navigation bars or overlays using a semi-transparent `surface_container` color. This ensures the "Digital Greenhouse" feels integrated and fluid.

## 5. Components: Refined Primitives

### Buttons
*   **Primary:** Solid `primary` (#75DAA8) with `on_primary` (#003823) text. Use `ROUND_EIGHT` (0.5rem) corners. For a premium touch, add a 10% inner glow on hover.
*   **Secondary:** A "Ghost" style. Use the `outline` token at 20% opacity with `primary` colored text.
*   **Tertiary:** Text-only, using `primary` color. No container.

### Cards & Lists
*   **Forbid Divider Lines:** Separate list items using 12px of vertical white space or a subtle background shift to `surface_container_low`.
*   **Cards:** Should use `surface_container_low` (#1C1B1D). On hover, shift to `surface_container_high` (#2A2A2C) and increase the corner radius slightly to create a "flexing" sensation.

### Inputs & Fields
*   **Stateful Design:** Inactive states use `surface_container_highest`. Focused states should transition the "Ghost Border" to a 100% opaque `primary` glow.

### Signature Component: The "Eco-Metric" Chip
*   A custom component for this system. A semi-transparent pill using `primary_container` at 15% opacity with a solid `primary` dot indicator. This provides high-glance value for sustainability data without cluttering the UI.

## 6. Do's and Don'ts

### Do
*   **Do** use asymmetrical margins (e.g., a wider left margin for headlines) to create an editorial, non-templated feel.
*   **Do** use `primary_fixed_dim` (#75DAA8) for icons to ensure they pop against the deep zinc background.
*   **Do** lean into "Overlapping Elements"—let a card slightly overlap a hero image to create depth.

### Don't
*   **Don't** use pure black (#000000). It kills the "organic" feel of the dark mode. Use our `surface` zinc (#131315).
*   **Don't** use 1px dividers. If you feel you need a line, use a 16px gap instead.
*   **Don't** use high-saturation reds or blues. All functional colors (error/tertiary) must be slightly desaturated to match the "Nighttime" palette.