# Design System Document

## 1. Overview & Creative North Star: "The Modern Commons"

This design system is built to move beyond the utilitarian "grid of boxes" typical of marketplace apps. Our Creative North Star is **"The Modern Commons"**—an editorial-inspired digital space that feels as tactile and trustworthy as a local community garden. 

We reject the "template" look. Instead of rigid borders and heavy shadows, we use **Tonal Layering** and **Intentional Asymmetry**. By leveraging Material 3 logic through a high-end editorial lens, we create a sense of "Organic Brutalism"—where the structure is clear and bold, but the edges are soft, breathable, and human. The experience should feel like a premium lifestyle magazine: authoritative yet deeply accessible.

---

## 2. Colors & Surface Philosophy

The palette moves away from sterile whites into "Warm Neutrals" and "Living Greens." We treat color not just as decoration, but as the primary architectural tool.

### The "No-Line" Rule
**Explicit Instruction:** Designers are prohibited from using 1px solid borders to define sections or containers. Boundaries must be established through:
1.  **Background Shifts:** Placing a `surface-container-low` element against a `surface` background.
2.  **Vertical Rhythm:** Using intentional white space to imply separation.

### Surface Hierarchy & Nesting
Treat the UI as a series of stacked, physical sheets of fine paper. 
*   **Base Layer:** `background` (#f9f9f8).
*   **Sectional Depth:** Use `surface-container` (#eceeed) for large grouping areas.
*   **Interactive Focus:** Use `surface-container-lowest` (#ffffff) for cards or inputs to make them "pop" against the warmer background.

### The "Glass & Gradient" Rule
To inject "soul" into the interface:
*   **Glassmorphism:** For floating headers or navigation bars, use `surface` with 80% opacity and a `24px` backdrop blur. This allows neighborhood map colors or product images to bleed through softly.
*   **Signature Gradients:** Main Action buttons or Hero sections should utilize a subtle linear gradient: `primary` (#2d6a4f) to `primary_dim` (#1f5e44) at a 135-degree angle.

---

## 3. Typography: Editorial Authority

We use **Plus Jakarta Sans** exclusively. The goal is a high-contrast scale that guides the eye through "neighborhood stories" rather than just "data points."

*   **Display (lg/md):** Reserved for high-impact community milestones or hero headers. These should use tight tracking (-0.02em) to feel bold and modern.
*   **Headline (sm/md):** Used for item titles in a swap feed. These provide the "Editorial" feel—large enough to be the focal point of a card.
*   **Title (md/lg):** Used for navigation and section headers. 
*   **Body (lg):** The primary reading weight. Ensure a line height of at least 1.5 for maximum readability for our 18-40 urban demographic.
*   **Labels (sm/md):** Used for metadata (e.g., "2 miles away"). These should utilize `on_surface_variant` (#5b605f) to maintain hierarchy without clutter.

---

## 4. Elevation & Depth: Tonal Layering

Traditional shadows are often a crutch for poor layout. In this system, depth is earned through tone.

*   **The Layering Principle:** To lift a card, place a `surface_container_lowest` (#ffffff) element on a `surface_container` (#eceeed) background. This creates a "soft lift" that feels architectural.
*   **Ambient Shadows:** If a floating action button (FAB) or a modal requires a shadow, use a "Tinted Ambient Shadow": 
    *   *Y: 8px, Blur: 24px, Spread: -4px.*
    *   *Color:* `on_surface` (#2e3333) at **6% opacity**. Never use pure black.
*   **The "Ghost Border" Fallback:** If a boundary is strictly required for accessibility (e.g., in high-glare environments), use the `outline_variant` (#aeb3b2) at **15% opacity**.
*   **Glassmorphism:** Use semi-transparent `surface_bright` with a backdrop blur for persistent elements like bottom navigation to maintain a sense of environmental awareness (the content moving behind the UI).

---

## 5. Components

### Cards & Discovery
*   **Layout:** No dividers. Use `md` (12px) or `lg` (16px) corner radius. 
*   **Separation:** Use `surface_container_low` for the card background against a `surface` page.
*   **Signature Element:** Overlap the user's avatar slightly over the edge of the product image to break the grid and feel "community-led."

### Buttons
*   **Primary:** High-gloss. Gradient of `primary` to `primary_dim`. `full` (pill) roundedness.
*   **Secondary:** `secondary_container` (#cffaed) background with `on_secondary_container` (#3b6158) text. No border.
*   **Tertiary:** Ghost style. No background. Use `primary` text weight `600` for prominence.

### Input Fields
*   **Style:** Minimalist. Use `surface_container_highest` for the background. 
*   **States:** On focus, transition the background to `surface_container_lowest` and add a 2px "Ghost Border" using `primary`.

### Neighborhood Chips
*   **Visuals:** Use `tertiary_container` (#ffa44c) for location-based alerts or "Urgent Swaps." The vibrant orange provides the "vibrant accent" needed to contrast the earthy greens.

### Navigation Bar
*   **Construction:** Use a Glassmorphism effect. `surface` at 85% opacity + Blur. This ensures the app feels "light" and "modern" as users scroll through their local feed.

---

## 6. Do's and Don'ts

### Do
*   **Do** use asymmetrical margins (e.g., a wider left margin for titles) to create an editorial, premium feel.
*   **Do** use `primary_fixed_dim` for icons to give them a sophisticated, "etched" look.
*   **Do** prioritize "Breathing Room." If you think there's enough padding, add 8px more.

### Don't
*   **Don't** use 1px solid dividers. Use a `8px` gap or a background color shift.
*   **Don't** use pure black (#000000) for text. Always use `on_surface` (#2e3333) to maintain the earthy, organic tone.
*   **Don't** use standard Material 3 "elevated" shadows. Stick to Tonal Layering.
*   **Don't** use harsh, high-contrast borders for checkboxes or radio buttons; use the `outline_variant` at low opacity.

---

*This design system is a living framework. It is intended to feel curated, not automated. When in doubt, choose the path that feels more human, more spacious, and more tactile.*