# Design System Specification: Editorial Academic Excellence

## 1. Overview & Creative North Star
### The Creative North Star: "The Curated Scholastic"
This design system rejects the "SaaS-in-a-box" aesthetic in favor of a high-end, editorial approach to internship management. We treat student career paths not as rows in a database, but as curated portfolios. By moving away from rigid grids and 1px borders, we embrace **Organic Structuralism**.

The system utilizes intentional asymmetry, generous white space (the "Breathing Room" principle), and sophisticated tonal layering. We balance the authority of an academic institution with the fluid energy of a modern tech startup. The result is a platform that feels like a premium workspace rather than a bureaucratic form.

---

## 2. Colors & Surface Philosophy
The palette is rooted in `primary (#006a39)`, a deep, trustworthy green, but its power lies in the sophisticated use of neutrals and "Ghost" tones.

### The "No-Line" Rule
**Explicit Instruction:** Traditional 1px solid borders (`#CCCCCC` or similar) are strictly prohibited for sectioning. 
- Boundaries must be defined solely through background shifts. 
- Place a `surface-container-low` card atop a `surface` background. 
- Use the 8pt spacing scale to create "Gaps of Intent" rather than "Lines of Separation."

### Surface Hierarchy & Nesting
Treat the UI as physical layers of fine stationery.
*   **Base:** `surface` (#f8f9fa) – The desk.
*   **Secondary Sections:** `surface-container-low` (#f3f4f5) – The folder.
*   **Active Workspaces:** `surface-container-lowest` (#ffffff) – The paper.
*   **Floating Elements:** Use `surface_bright` with a 70% opacity and a `24px` backdrop blur (Glassmorphism) for navigation bars and modals to ensure the content feels integrated, not "pasted on."

### Signature Textures
Apply a subtle linear gradient to main Action Buttons and Hero headers:
*   **Direction:** 135deg
*   **From:** `primary` (#006a39)
*   **To:** `primary_container` (#008649)
This adds "soul" and depth, preventing the green from appearing flat or "utility-grade."

---

## 3. Typography: The Editorial Scale
We utilize a dual-font pairing to distinguish between "The Statement" and "The Detail."

*   **Display & Headlines (Manrope):** Chosen for its geometric precision and modern academic feel. Use `display-lg` (3.5rem) with tight tracking (-0.02em) for landing pages to create an authoritative, editorial impact.
*   **Body & Labels (Inter):** The workhorse. Inter provides maximum legibility for dense internship descriptions and application forms.
*   **Hierarchy as Identity:** Use `title-lg` (1.375rem) in `on_surface_variant` for sub-headers to create a soft, sophisticated contrast against the jet-black `on_surface` titles.

---

## 4. Elevation & Depth
Depth is achieved through **Tonal Stacking**, not shadows.

*   **The Layering Principle:** To highlight a student’s application status, do not use a shadow. Instead, place the white `surface-container-lowest` card on a `surface-container-high` (#e7e8e9) background. This creates "Soft Lift."
*   **Ambient Shadows:** For high-level floating elements (modals), use an ultra-diffused shadow:
    *   `box-shadow: 0 20px 40px rgba(25, 28, 29, 0.06);` (Using a 6% tint of `on_surface`).
*   **The "Ghost Border" Fallback:** If a border is required for accessibility on inputs, use `outline_variant` at **15% opacity**. It should be felt, not seen.

---

## 5. Components

### Buttons
*   **Primary:** Gradient fill (`primary` to `primary_container`), `xl` (1.5rem) roundedness. No border.
*   **Secondary:** `surface_container_high` fill with `on_secondary_container` text. This feels like a soft tactile button.
*   **Tertiary (The Editorial Link):** No background. Bold `primary` text with a 2px underline that only appears on hover.

### Cards & Application Lists
*   **Forbid Dividers:** Do not use horizontal lines between internship listings.
*   **The Solution:** Use `spacing-6` (1.5rem) vertical padding and a subtle hover state shift to `surface_container_highest`. 
*   **Layout:** Use asymmetrical padding—more on the left than the right—to mimic a magazine layout.

### Input Fields
*   **State:** Default state uses `surface_container_low`. 
*   **Active State:** Transitions to `surface_container_lowest` with a 2px `primary` bottom-border only (Editorial underline style).
*   **Roundedness:** `md` (0.75rem) for a modern, approachable feel.

### Specialized Component: The "Progress Bloom"
Instead of a standard horizontal progress bar for application tracking, use a series of `surface_fixed_dim` chips that "bloom" into `primary` color as the student completes stages.

---

## 6. Do’s and Don’ts

### Do:
*   **Do** use `tertiary` (#a23546) sparingly for critical alerts; it is a "refined red" that maintains professional dignity.
*   **Do** embrace extreme white space. If you think there is enough space, add 16px more.
*   **Do** use `inverse_surface` for dark-mode tooltips to provide high-contrast "moments of truth."

### Don’t:
*   **Don’t** use pure black (#000000) for text. Always use `on_surface` (#191c1d) to maintain the soft-academic look.
*   **Don’t** use the `DEFAULT` (0.5rem) corner radius for everything. Use `full` for chips and `xl` for large containers to vary the visual rhythm.
*   **Don’t** use standard "drop shadows" on cards. If the background shift isn't enough, your background colors are too similar.