# RadixSwift

RadixSwift is a single Swift package that ports Radix UI concepts to native macOS SwiftUI. It packages Radix-inspired Themes, Primitives, Icons, and Colors behind one dependency so macOS apps can use a Radix-style UI layer without embedding a web view, JavaScript runtime, or CSS pipeline.

The package is a native SwiftUI implementation. It uses Radix naming, visual tokens, source inventories, and bundled resources as the reference point, while exposing Swift-friendly APIs prefixed with `Radix` to avoid collisions with SwiftUI types.

<img width="1122" height="858" alt="SCR-20260506-jdpd" src="https://github.com/user-attachments/assets/cc65f3dc-df05-4b17-a27b-a7c9e056b80d" />

## What Is Included

- `RadixTheme` and `RadixThemeValues` for appearance, accent color, gray color, panel background, radius, scaling, and motion.
- `RadixColorCatalog` with generated Radix color exports and theme color metadata.
- `RadixIcon` and `RadixIconName` with the original Radix Icons SVG set rendered as native SwiftUI shapes.
- Styled Radix Themes components such as `RadixButton`, `RadixIconButton`, `RadixSegmentedButtonGroup`, `RadixCard`, `RadixBadge`, `RadixCallout`, `RadixTextField`, `RadixSelect`, `RadixTabs`, and `RadixThemePanel`.
- Radix Primitives-style views such as `RadixAccordion`, `RadixCollapsible`, `RadixDialog`, `RadixAlertDialog`, `RadixDropdownMenu`, `RadixContextMenu`, `RadixPopover`, `RadixHoverCard`, `RadixTooltip`, `RadixToolbar`, `RadixMenubar`, and `RadixNavigationMenu`.
- Layout and typography helpers including `RadixBox`, `RadixFlex`, `RadixGrid`, `RadixContainer`, `RadixSection`, `RadixText`, `RadixHeading`, `RadixCode`, `RadixKbd`, `RadixLink`, and accessibility wrappers.
- A catalog demo executable that renders the components grouped by category and starts in dark mode.
- And... Liquid Glass support!
<img width="971" height="700" alt="SCR-20260506-kvzf" src="https://github.com/user-attachments/assets/9f68a852-d2a9-42de-a000-178287f25edb" />

## Requirements

- macOS 13 or newer.
- Swift 6.1 or newer.
- SwiftUI.

## Installation

RadixSwift is a Swift Package. Add this repository to any macOS app that uses Swift Package Manager.

### Xcode

1. Copy this repository's clone URL from the **Code** button.
2. Open your app project in Xcode.
3. Choose **File > Add Package Dependencies...**.
4. Paste the copied URL.
5. Choose a dependency rule:
   - Use **Up to Next Major Version** for tagged releases.
   - Use **Branch** while testing unreleased changes.
6. Add the `RadixSwift` product to your app target.

### Package.swift

Copy this repository's clone URL and use it as the `url` value.

For a tagged release:

```swift
dependencies: [
    .package(url: "THIS_REPOSITORY_CLONE_URL", from: "0.1.0")
]
```

For the `main` branch:

```swift
dependencies: [
    .package(url: "THIS_REPOSITORY_CLONE_URL", branch: "main")
]
```

Then add the `RadixSwift` product to the target that builds your app:

```swift
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "RadixSwift", package: "RadixSwift")
        ]
    )
]
```

Then import the package where you build UI:

```swift
import RadixSwift
```

## Quick Start

Wrap your app or feature root in `RadixTheme`. This is the SwiftUI equivalent of putting a Radix Themes `Theme` provider near the root of a web app.

```swift
import SwiftUI
import RadixSwift

struct ContentView: View {
    var body: some View {
        RadixTheme(
            appearance: .dark,
            accentColor: .indigo,
            grayColor: .auto,
            radius: .medium,
            scaling: .normal
        ) {
            RadixCard {
                RadixFlex(direction: .vertical, gap: 3, alignment: .leading) {
                    RadixHeading("Invite members", size: .five)
                    RadixText("Manage team access with native macOS controls.", size: .two)

                    RadixFlex(gap: 2) {
                        RadixButton("Invite") {}
                        RadixButton("Cancel", variant: .soft) {}
                        RadixIconButton(icon: .gear, label: "Settings", variant: .surface) {}
                    }
                }
            }
            .padding(24)
        }
    }
}
```

## Theme Configuration

`RadixTheme` configures the visual language for all child components:

- `appearance`: `.inherit`, `.light`, or `.dark`.
- `accentColor`: Radix theme accent, for example `.indigo`, `.ruby`, `.jade`, or `.amber`.
- `grayColor`: `.auto` or a fixed Radix gray family such as `.mauve`, `.slate`, `.sage`, `.olive`, or `.sand`.
- `panelBackground`: `.solid` or `.translucent`.
- `radius`: `.none`, `.small`, `.medium`, `.large`, or `.full`.
- `scaling`: `.xSmall`, `.small`, `.normal`, `.large`, or `.xLarge`.
- `animations`: shared timing for hover, toggle, popup, disclosure, dialog, toast, and loading motion.

```swift
RadixTheme(
    appearance: .dark,
    accentColor: .ruby,
    grayColor: .auto,
    panelBackground: .translucent,
    radius: .large,
    scaling: .normal
) {
    AppShell()
}
```

## Buttons, Badges, and Icons

```swift
RadixFlex(gap: 2) {
    RadixButton("Save") {
        save()
    }

    RadixButton("Preview", variant: .surface, color: .blue) {
        preview()
    }

    RadixButton(variant: .solid, size: .three) {
        goNext()
    } label: {
        RadixFlex(gap: 2) {
            Text("Next")
            RadixIcon(.arrowRight, size: 14)
        }
    }

    RadixIconButton(icon: .plus, label: "Add item", variant: .soft) {
        addItem()
    }

    RadixBadge("Live", color: .green)
    RadixBadge("Warning", variant: .surface, color: .amber)
}
```

## Forms and Selection Controls

```swift
struct SettingsForm: View {
    @State private var email = ""
    @State private var notes = ""
    @State private var plan = "basic"
    @State private var region = "eu"
    @State private var reportsEnabled = true
    @State private var automationEnabled = false
    @State private var usage = 42.0

    private let plans = [
        RadixSelectionOption("basic", label: "Basic"),
        RadixSelectionOption("growth", label: "Growth"),
        RadixSelectionOption("enterprise", label: "Enterprise")
    ]

    private let regions = [
        RadixSelectionOption("us", label: "US"),
        RadixSelectionOption("eu", label: "EU"),
        RadixSelectionOption("apac", label: "APAC")
    ]

    var body: some View {
        RadixFlex(direction: .vertical, gap: 3, alignment: .leading) {
            RadixTextField("Email", text: $email)
            RadixTextArea(text: $notes)

            RadixSelect("Region", selection: $region, options: regions)
            RadixSegmentedControl(selection: $plan, options: plans)
            RadixRadioGroup(selection: $plan, options: plans)

            RadixCheckbox("Receive reports", isOn: $reportsEnabled)
            RadixSwitch("Enable automation", isOn: $automationEnabled)

            RadixSlider(value: $usage, in: 0...100, step: 1)
            RadixProgress(value: usage, total: 100)
        }
    }
}
```

## Segmented Button Groups

Use `RadixSegmentedButtonGroup` when each segment acts like a button but the group should feel like one continuous control. It supports text-only, icon-only, icon-and-text, badges, explicit separators, and horizontal or vertical orientation.

```swift
struct ViewModePicker: View {
    @State private var viewMode = "activity"

    private let modes = [
        RadixSegmentedButtonGroupItem(
            "activity",
            label: "Activity",
            icon: .clock,
            badge: RadixSegmentedButtonBadge("1", color: .amber)
        ),
        RadixSegmentedButtonGroupItem("docs", label: "Docs", icon: .fileText, separatorBefore: true),
        RadixSegmentedButtonGroupItem(
            "grid",
            label: "Grid",
            icon: .component1,
            badge: RadixSegmentedButtonBadge("3", color: .blue)
        )
    ]

    var body: some View {
        RadixFlex(direction: .vertical, gap: 3, alignment: .leading) {
            RadixSegmentedButtonGroup(
                selection: $viewMode,
                items: modes,
                display: .iconAndText
            )

            RadixSegmentedButtonGroup(
                selection: $viewMode,
                items: modes,
                orientation: .vertical,
                display: .icon
            )
        }
    }
}
```

Display modes:

- `.text`: shows only labels.
- `.icon`: shows only icons when an icon exists. The item label is still used for accessibility and appears in an automatic hover popup.
- `.iconAndText`: shows icon and label together.

Sizing and layout:

- Horizontal groups size each segment from its own content, so short and long labels can have different widths.
- Vertical groups use the widest segment as the shared row width, so selection and hover states line up with the container.
- Text is kept at its natural width inside the segment instead of being truncated.
- Badged items reserve trailing space for the badge, so the badge does not cover the label.

Separators:

- Normal adjacent items do not draw separator lines.
- Use `separatorBefore: true` on an item to start a new visual cluster.
- Explicit separators keep the group spacing and draw the visible line, for example `[A][B][C] | [D][E]`.

## Menus and Context Menus

Menus are rendered with Radix-style SwiftUI panels instead of default macOS menu chrome.

```swift
RadixDropdownMenu {
    RadixButton("Options", variant: .surface) {}
} content: {
    RadixMenuItem("Edit", shortcut: "Cmd E")
    RadixMenuItem("Duplicate", shortcut: "Cmd D")
    RadixMenuSeparator()
    RadixMenuItem("Archive")
    RadixMenuSubmenu("More") {
        RadixMenuItem("Move to project...")
        RadixMenuItem("Move to folder...")
        RadixMenuSeparator()
        RadixMenuItem("Advanced options...")
    }
    RadixMenuSeparator()
    RadixMenuItem("Delete", destructive: true)
}
```

```swift
RadixContextMenu {
    RadixCard {
        RadixText("Right-click this card for actions.", size: .two)
    }
} menu: {
    RadixMenuItem("Copy", shortcut: "Cmd C")
    RadixMenuItem("Paste", shortcut: "Cmd V")
    RadixMenuSeparator()
    RadixMenuItem("Delete", destructive: true)
}
```

## Dialogs and Alerts

```swift
struct DangerZone: View {
    @State private var showsDialog = false
    @State private var showsAlert = false

    var body: some View {
        RadixFlex(gap: 2) {
            RadixButton("Open Dialog", variant: .surface) {
                showsDialog = true
            }

            RadixButton("Revoke", color: .red) {
                showsAlert = true
            }
        }
        .radixDialog(isPresented: $showsDialog) {
            RadixFlex(direction: .vertical, gap: 3, alignment: .leading) {
                RadixHeading("Dialog", size: .five)
                RadixText("Native overlay styled with the active Radix theme.", size: .two)
                RadixButton("Close") {
                    showsDialog = false
                }
            }
        }
        .radixAlertDialog(
            isPresented: $showsAlert,
            title: "Revoke access",
            message: "This application will no longer be accessible.",
            confirmTitle: "Revoke",
            destructive: true
        )
    }
}
```

## Disclosure, Tabs, Popovers, and Tooltips

```swift
struct PrimitiveExamples: View {
    @State private var accordionOpen = true
    @State private var tab = "overview"

    private let tabs = [
        RadixSelectionOption("overview", label: "Overview"),
        RadixSelectionOption("activity", label: "Activity"),
        RadixSelectionOption("settings", label: "Settings")
    ]

    var body: some View {
        RadixFlex(direction: .vertical, gap: 3, alignment: .leading) {
            RadixAccordion(isExpanded: $accordionOpen) {
                Text("Accordion")
            } content: {
                RadixText("Grouped accordion content.", size: .two)
            }

            RadixTabs(selection: $tab, tabs: tabs) { selected in
                RadixText("Selected tab: \(selected)", size: .two)
            }

            RadixPopover {
                RadixButton("Popover", variant: .surface) {}
            } content: {
                RadixText("Popover content rendered by SwiftUI.", size: .two)
            }

            RadixTooltip("Radix themed tooltip") {
                RadixBadge("Hover me")
            }
        }
    }
}
```

## Icons and Colors

Use `RadixIconName` for compile-time icon names and `RadixColorCatalog` when you need raw Radix token colors.

```swift
RadixFlex(gap: 2) {
    RadixIcon(.accessibility, size: 18, accessibilityLabel: "Accessibility")
    RadixIcon(.checkCircled, size: 18)
    RadixIcon(.arrowRight, size: 18)
}
```

```swift
let ruby9 = RadixColorCatalog.shared.color(
    scale: "ruby",
    step: 9,
    appearance: .dark
)

let rubyA6 = RadixColorCatalog.shared.color(
    scale: "ruby",
    step: 6,
    appearance: .dark,
    alpha: true
)
```

## Animation API

Motion is configured at the theme boundary and inherited by controls, menus, dialogs, tooltips, disclosure surfaces, and loading indicators.

```swift
RadixTheme(
    accentColor: .indigo,
    animations: RadixAnimationSettings(
        durationScale: 1.2,
        popup: RadixAnimationSpec(duration: 0.22, curve: .spring),
        disclosure: RadixAnimationSpec(duration: 0.2, curve: .interactiveSpring)
    )
) {
    RadixDropdownMenu {
        RadixButton("Options", variant: .surface) {}
    } content: {
        RadixMenuItem("Edit")
        RadixMenuSubmenu("More") {
            RadixMenuItem("Archive")
        }
    }
}
```

Use `RadixAnimationSettings.none` to disable component motion, or apply `.radixAnimations(...)` to a subtree when only part of an interface needs different timing. The default hover, press, toggle, popup, and disclosure roles use spring-based curves so repeated pointer and Liquid Glass state changes keep their momentum.

## Demo App

Run the component catalog from SwiftPM:

```bash
swift run RadixCatalogDemo
```

The demo is a native macOS executable that shows the components grouped by category, uses dark mode by default, and includes theme controls for appearance, accent, radius, scaling, and motion.

## Verification

```bash
swift build
swift test
```

## Included Upstream Surface

The package includes generated inventories for the upstream Radix source surface:

- `RadixIconName`: 332 icons from `radix-ui/icons`.
- `RadixThemeComponentName`: 59 Radix Themes component names.
- `RadixPrimitiveName`: 58 Radix Primitives package names.
- `RadixColorCatalog.shared.exportNames`: 252 color exports from `radix-ui/colors`.

The styled components are prefixed with `Radix` to keep imports predictable in SwiftUI projects.

## Upstream Source Snapshot

These are the upstream revisions used when the current generated resources and inventories were checked:

- Website: `02a760e`
- Primitives: `22473d1`
- Icons: `112af91`
- Themes: `1faff10`
- Colors: `dbdb854`

## Project Notes

- RadixSwift is not a binary-compatible port of the React packages. It is a native SwiftUI package that follows Radix Themes visuals and Radix Primitives interaction patterns where they map cleanly to macOS.
- The package avoids default macOS menu and control styling for the Radix component surface so visuals stay consistent with the active Radix theme.
- Colors and icons are bundled as package resources, so consumer apps do not need a separate asset copy step.
- Components are designed to be used directly by app targets or by another Swift package that provides an app-specific design layer.

## License

RadixSwift is released under the MIT License. See [LICENSE](LICENSE).

Radix-derived resources, inventories, and visual references come from MIT-licensed Radix UI repositories maintained by WorkOS and the Radix UI contributors. See [NOTICE.md](NOTICE.md) for attribution details.
