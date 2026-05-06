# Design System: RadixSwift
**Project ID:** local Swift package port of Radix UI

## 1. Visual Theme & Atmosphere
RadixSwift follows Radix’s quiet, utilitarian application aesthetic: compact controls, restrained contrast, precise spacing, and surfaces that feel native on macOS while preserving Radix’s web token names.

## 2. Color Palette & Roles
- **Accent scales:** All Radix accent families are available, including Indigo, Blue, Crimson, Ruby, Grass, Amber, and Sky. Each scale exposes steps 1-12 and alpha variants.
- **Gray scales:** Auto gray matching follows Radix’s helper: cool accents map to Slate, warm accents map to Sand, green accents map to Sage or Olive, and red/purple accents map to Mauve.
- **Panel surfaces:** Cards and panels use solid or translucent backgrounds from the active `RadixTheme`.
- **Contrast colors:** Button and badge foregrounds use the upstream theme contrast metadata.

## 3. Typography Rules
The package mirrors Radix font-size steps 1-9, defaulting to the platform system font for native macOS rendering. Headings use stronger weight and retain the same size scale as Radix Themes.

## 4. Component Stylings
* **Buttons:** Solid, soft, surface, outline, ghost, and classic variants share one palette resolver for background, foreground, border, pressed, and disabled states.
* **Cards/Containers:** Rounded surfaces use Radix radius steps and theme panel backgrounds.
* **Inputs/Forms:** Text fields and text areas use subtle gray fills, one-pixel borders, and the active radius setting.
* **Icons:** Original Radix SVGs render as template images so SwiftUI foreground color behaves like web `currentColor`.

## 5. Layout Principles
Spacing is based on Radix’s 1-9 space scale and theme scaling factor. Layout wrappers such as `RadixFlex`, `RadixGrid`, `RadixContainer`, and `RadixSection` keep structure separate from control behavior.

