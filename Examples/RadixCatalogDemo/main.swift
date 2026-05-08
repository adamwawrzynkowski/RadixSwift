import AppKit
import RadixSwift
import SwiftUI

@main
struct RadixCatalogDemoApp: App {
    init() {
        NSApplication.shared.setActivationPolicy(.regular)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }

    var body: some Scene {
        WindowGroup("Radix Swift Catalog") {
            RadixTheme(accentColor: .indigo, radius: .medium, hasBackground: true) {
                CatalogView()
                    .frame(minWidth: 1180, minHeight: 760)
            }
        }
        .windowResizability(.contentMinSize)
    }
}

private enum CatalogCategory: String, CaseIterable, Identifiable {
    case foundation = "Foundation"
    case layout = "Layout"
    case typography = "Typography"
    case actions = "Actions"
    case forms = "Forms"
    case navigation = "Navigation"
    case overlays = "Overlays"
    case feedback = "Feedback"
    case data = "Data Display"
    case icons = "Icons"
    case theme = "Theme"

    var id: String { rawValue }

    var icon: RadixIconName {
        switch self {
        case .foundation: .component1
        case .layout: .layout
        case .typography: .fontRoman
        case .actions: .button
        case .forms: .input
        case .navigation: .panelLeft
        case .overlays: .stack
        case .feedback: .bell
        case .data: .table
        case .icons: .star
        case .theme: .colorWheel
        }
    }
}

private enum CatalogMotionMode: String, CaseIterable, Identifiable, Sendable {
    case standard = "Default"
    case slow = "Slow"
    case none = "None"

    var id: String { rawValue }

    var settings: RadixAnimationSettings {
        switch self {
        case .standard:
            .default
        case .slow:
            .slow
        case .none:
            .none
        }
    }
}

private struct CatalogView: View {
    @State private var selection: CatalogCategory = .foundation
    @State private var appearance: RadixAppearance = .dark
    @State private var accent: RadixAccentColor = .indigo
    @State private var radius: RadixRadius = .medium
    @State private var scaling: RadixScaling = .normal
    @State private var motion: CatalogMotionMode = .standard

    var body: some View {
        RadixTheme(
            appearance: appearance,
            accentColor: accent,
            grayColor: .auto,
            radius: radius,
            scaling: scaling,
            animations: motion.settings,
            hasBackground: true
        ) {
            NavigationSplitView {
                Sidebar(selection: $selection)
            } detail: {
                DetailColumn(
                    selection: selection,
                    appearance: $appearance,
                    accent: $accent,
                    radius: $radius,
                    scaling: $scaling,
                    motion: $motion
                )
            }
        }
    }
}

private struct Sidebar: View {
    @Binding var selection: CatalogCategory

    @Environment(\.radixTheme) private var theme
    @Environment(\.radixAnimations) private var animations
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                RadixHeading("RadixSwift", size: .five)
                RadixText("Native Radix catalog", size: .one)
                    .foregroundStyle(theme.gray(11, colorScheme: colorScheme))
            }
            .padding(.horizontal, theme.space(4))
            .padding(.vertical, theme.space(4))

            RadixSeparator()

            RadixScrollArea(showsIndicators: false) {
                VStack(alignment: .leading, spacing: theme.space(1)) {
                    ForEach(CatalogCategory.allCases) { category in
                        SidebarRow(
                            category: category,
                            isSelected: selection == category
                        ) {
                            animations.perform(.presence) {
                                selection = category
                            }
                        }
                    }
                }
                .padding(theme.space(3))
            }
        }
        .frame(minWidth: 220)
        .background(theme.panel(colorScheme: colorScheme))
    }
}

private struct SidebarRow: View {
    let category: CatalogCategory
    let isSelected: Bool
    let action: () -> Void
    @State private var isHovered = false

    @Environment(\.radixTheme) private var theme
    @Environment(\.radixAnimations) private var animations
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            HStack(spacing: theme.space(2)) {
                RadixIcon(category.icon, size: 15)
                    .frame(width: theme.space(4))

                Text(category.rawValue)
                    .font(theme.font(.two, weight: isSelected ? .medium : .regular))
                    .lineLimit(1)

                Spacer(minLength: theme.space(2))
            }
            .foregroundStyle(rowForeground)
            .padding(.horizontal, theme.space(3))
            .frame(height: theme.space(6))
            .background(rowBackground)
            .clipShape(RoundedRectangle(cornerRadius: theme.radius(2), style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: theme.radius(2), style: .continuous))
            .scaleEffect(isHovered && !isSelected ? 1.01 : 1)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            animations.perform(.hover) {
                isHovered = hovering
            }
        }
        .animation(animations.animation(for: .hover), value: isHovered)
    }

    private var rowForeground: Color {
        isSelected
            ? theme.contrast()
            : theme.gray(isHovered ? 12 : 11, colorScheme: colorScheme)
    }

    @ViewBuilder
    private var rowBackground: some View {
        if isSelected {
            RoundedRectangle(cornerRadius: theme.radius(2), style: .continuous)
                .fill(theme.accent(9, colorScheme: colorScheme))
        } else if isHovered {
            RoundedRectangle(cornerRadius: theme.radius(2), style: .continuous)
                .fill(theme.gray(3, alpha: true, colorScheme: colorScheme))
        }
    }
}

private struct DetailColumn: View {
    let selection: CatalogCategory
    @Binding var appearance: RadixAppearance
    @Binding var accent: RadixAccentColor
    @Binding var radius: RadixRadius
    @Binding var scaling: RadixScaling
    @Binding var motion: CatalogMotionMode

    @State private var tab = "components"
    @State private var tabNav = "overview"
    @State private var isAccordionOpen = true
    @State private var isCollapsibleOpen = true
    @State private var isDialogOpen = false
    @State private var isAlertOpen = false
    @State private var isTogglePressed = true
    @State private var toggleGroup: Set<String> = ["bold"]
    @State private var checkbox = true
    @State private var switchOn = true
    @State private var slider = 64.0
    @State private var email = "team@radix.local"
    @State private var notes = "RadixSwift keeps UI code native while preserving Radix naming."
    @State private var selectedPlan = "growth"
    @State private var selectedRegion = "eu"
    @State private var cardChecks: Set<String> = ["email", "push"]
    @State private var password = "radix"
    @State private var otp = "123456"
    @State private var presence = true
    @State private var toasts = [
        RadixToast(title: "Build completed", message: "RadixCatalogDemo is ready.")
    ]

    @Environment(\.radixAnimations) private var animations

    private let planOptions = [
        RadixSelectionOption("basic", label: "Basic"),
        RadixSelectionOption("growth", label: "Growth"),
        RadixSelectionOption("enterprise", label: "Enterprise")
    ]

    private let regionOptions = [
        RadixSelectionOption("us", label: "US"),
        RadixSelectionOption("eu", label: "EU"),
        RadixSelectionOption("apac", label: "APAC")
    ]

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            RadixScrollArea {
                RadixContainer(size: .four) {
                    RadixSection(size: .two) {
                        content
                            .id(selection)
                            .transition(animations.transition(for: .presence))
                    }
                    .padding(.horizontal, 28)
                }
            }
        }
        .animation(animations.animation(for: .presence), value: selection)
        .radixDialog(isPresented: $isDialogOpen) {
            RadixFlex(direction: .vertical, gap: 4, alignment: .leading) {
                RadixFlex(direction: .vertical, gap: 3, alignment: .leading) {
                    RadixHeading("Revoke access", size: .six)
                    RadixText("Are you sure? This application will no longer be accessible and any existing sessions will be expired.", size: .three)
                }

                RadixFlex(gap: 3, alignment: .center) {
                    Spacer()
                    RadixButton("Cancel", variant: .soft) {
                        isDialogOpen = false
                    }
                    RadixButton("Revoke", variant: .solid, color: .red) {
                        isDialogOpen = false
                    }
                }
            }
        }
        .radixAlertDialog(
            isPresented: $isAlertOpen,
            title: "Revoke access",
            message: "Are you sure? This application will no longer be accessible and any existing sessions will be expired.",
            confirmTitle: "Revoke",
            destructive: true
        )
    }

    private var header: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 3) {
                RadixHeading(size: .six) {
                    Text(selection.rawValue)
                }
                RadixText("Every component is grouped by role and rendered with the active theme.", size: .two)
            }
            Spacer()
            RadixSelect("Accent", selection: $accent, options: RadixAccentColor.allCases.map {
                RadixSelectionOption($0, label: $0.rawValue.capitalized)
            })
            RadixSelect("Radius", selection: $radius, options: RadixRadius.allCases.map {
                RadixSelectionOption($0, label: $0.rawValue.capitalized)
            })
            RadixSelect("Mode", selection: $appearance, options: RadixAppearance.allCases.map {
                RadixSelectionOption($0, label: $0.rawValue.capitalized)
            })
            RadixSelect("Motion", selection: $motion, options: CatalogMotionMode.allCases.map {
                RadixSelectionOption($0, label: $0.rawValue)
            })
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 18)
    }

    @ViewBuilder
    private var content: some View {
        switch selection {
        case .foundation:
            foundation
        case .layout:
            layout
        case .typography:
            typography
        case .actions:
            actions
        case .forms:
            forms
        case .navigation:
            navigation
        case .overlays:
            overlays
        case .feedback:
            feedback
        case .data:
            dataDisplay
        case .icons:
            icons
        case .theme:
            themePanel
        }
    }

    private var foundation: some View {
        CategoryStack {
            ComponentSection("Theme Provider") {
                RadixGrid(columns: 2, gap: 3) {
                    RadixCard {
                        RadixFlex(direction: .vertical, gap: 2, alignment: .leading) {
                            RadixLabel("RadixTheme")
                            RadixText("The outer provider controls appearance, accent, gray matching, radius, and scaling.", size: .two)
                            RadixThemePanel()
                        }
                    }
                    RadixCard {
                        RadixFlex(direction: .vertical, gap: 2, alignment: .leading) {
                            RadixLabel("Direction Provider")
                            RadixDirectionProvider(.rtl) {
                                RadixFlex(gap: 2) {
                                    RadixBadge("RTL")
                                    RadixButton("Mirrored", variant: .surface) {}
                                }
                            }
                            RadixDirectionProvider(.ltr) {
                                RadixFlex(gap: 2) {
                                    RadixBadge("LTR")
                                    RadixButton("Default", variant: .surface) {}
                                }
                            }
                        }
                    }
                }
            }

            ComponentSection("Low-Level Primitives") {
                RadixGrid(columns: 3, gap: 3) {
                    RadixCard {
                        RadixForm {
                            RadixLabel("RadixForm")
                            RadixTextField("Field", text: $email)
                            RadixCheckbox("Validated", isOn: $checkbox)
                            RadixReset {
                                RadixButton("Reset wrapper", variant: .ghost) {}
                            }
                        }
                    }
                    RadixCard {
                        RadixFocusScope {
                            RadixFocusGuards {
                                RadixRovingFocusGroup {
                                    RadixButton("One", variant: .soft) {}
                                    RadixButton("Two", variant: .soft) {}
                                }
                            }
                        }
                    }
                    RadixCard {
                        RadixDismissableLayer {
                            presence.toggle()
                        } content: {
                            VStack(alignment: .leading, spacing: 8) {
                                RadixLabel("Dismissable Layer")
                                RadixPresence(presence) {
                                    RadixBadge("Present", color: .green)
                                }
                                RadixButton("Toggle Presence", variant: .surface) {
                                    presence.toggle()
                                }
                            }
                        }
                    }
                    RadixCard {
                        VStack(alignment: .leading, spacing: 10) {
                            RadixLabel("RadixArrow")
                            RadixArrow()
                                .fill(.secondary)
                                .frame(width: 24, height: 14)
                            let collection = RadixCollection([
                                RadixDataListItem(label: "One", value: "A"),
                                RadixDataListItem(label: "Two", value: "B")
                            ])
                            RadixText(size: .two) {
                                Text("RadixCollection count: \(collection.elements.count)")
                            }
                        }
                    }
                }
            }

            ComponentSection("Generated Inventories") {
                RadixDataList([
                    RadixDataListItem(label: "Theme components", value: "\(RadixThemeComponentName.allCases.count)"),
                    RadixDataListItem(label: "Primitive packages", value: "\(RadixPrimitiveName.allCases.count)"),
                    RadixDataListItem(label: "Icon assets", value: "\(RadixIconName.allCases.count)"),
                    RadixDataListItem(label: "Color exports", value: "\(RadixColorCatalog.shared.exportNames.count)")
                ])
            }
        }
    }

    private var layout: some View {
        CategoryStack {
            ComponentSection("Box, Flex, Grid, Container, Section") {
                RadixBox {
                    RadixGrid(columns: 3, gap: 3) {
                        ForEach(1...6, id: \.self) { index in
                            RadixCard(size: .two) {
                                RadixFlex(direction: .vertical, gap: 2, alignment: .leading) {
                                    RadixBadge("Grid \(index)", variant: .surface)
                                    RadixText("Compact card inside RadixGrid.", size: .two)
                                }
                            }
                        }
                    }
                }
            }

            ComponentSection("Inset, Separator, Aspect Ratio, Scroll Area") {
                RadixGrid(columns: 2, gap: 3) {
                    RadixCard {
                        RadixInset(side: .all, amount: 4) {
                            RadixFlex(direction: .vertical, gap: 2, alignment: .leading) {
                                RadixText("Inset content")
                                RadixSeparator()
                                RadixText("The inset helper applies tokenized spacing.", size: .two)
                            }
                        }
                    }
                    RadixAspectRatio(16 / 9) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10).fill(.linearGradient(colors: [.indigo.opacity(0.18), .cyan.opacity(0.18)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            RadixIcon(.aspectRatio, size: 32)
                        }
                    }
                    .modifier(RadixPreviewFrame())
                }
            }
        }
    }

    private var typography: some View {
        CategoryStack {
            ComponentSection("Text, Heading, Strong, Em") {
                RadixCard {
                    VStack(alignment: .leading, spacing: 12) {
                        RadixHeading("A precise native heading", size: .six)
                        RadixText("RadixText follows the same size scale as Radix Themes.", size: .three)
                        HStack {
                            RadixStrong { Text("Strong") }
                            RadixEm { Text("Emphasis") }
                            RadixCode("RadixCode")
                            RadixKbd("⌘K")
                        }
                    }
                }
            }

            ComponentSection("Quote, Blockquote, Link, Accessibility") {
                RadixGrid(columns: 2, gap: 3) {
                    RadixCard {
                        VStack(alignment: .leading, spacing: 10) {
                            RadixQuote { Text("Design system primitives, native controls.") }
                            RadixBlockquote {
                                RadixText("Blockquote uses a Radix gray border and compact spacing.", size: .two)
                            }
                        }
                    }
                    RadixCard {
                        VStack(alignment: .leading, spacing: 10) {
                            RadixLink("Radix UI website", destination: URL(string: "https://www.radix-ui.com/")!)
                            RadixAccessibleIcon(label: "Accessible star") {
                                RadixIcon(.starFilled, size: 20)
                            }
                            RadixVisuallyHidden {
                                Text("Screen-reader-only content")
                            }
                        }
                    }
                }
            }
        }
    }

    private var actions: some View {
        CategoryStack {
            ComponentSection("Segmented Button Group") {
                SegmentedButtonGroupDemo()
            }

            ComponentSection("Buttons and Variants") {
                ButtonVariantMatrix()
            }

            ComponentSection("Icon Button, Toggle, Toggle Group, Toolbar") {
                RadixToolbar {
                    RadixIconButton(icon: .plus, label: "Add") {}
                    RadixIconButton(icon: .download, label: "Download", variant: .surface) {}
                    RadixToggle(isPressed: $isTogglePressed) {
                        RadixIcon(.fontBold)
                    }
                    RadixToggleGroup(
                        selection: $toggleGroup,
                        items: [
                            RadixSelectionOption("bold", label: "B"),
                            RadixSelectionOption("italic", label: "I"),
                            RadixSelectionOption("code", label: "{}")
                        ]
                    )
                }
            }
        }
    }

    private var forms: some View {
        CategoryStack {
            ComponentSection("Inputs") {
                RadixGrid(columns: 2, gap: 3) {
                    RadixCard {
                        RadixFlex(direction: .vertical, gap: 3, alignment: .leading) {
                            RadixTextField("Email", text: $email)
                            RadixTextArea(text: $notes)
                            RadixPasswordToggleField(text: $password)
                            RadixOneTimePasswordField(text: $otp)
                        }
                    }
                    RadixCard {
                        RadixFlex(direction: .vertical, gap: 3, alignment: .leading) {
                            RadixCheckbox("Receive email reports", isOn: $checkbox)
                            RadixSwitch("Enable automation", isOn: $switchOn)
                            RadixSlider(value: $slider, in: 0...100, step: 1)
                            RadixProgress(value: slider, total: 100)
                        }
                    }
                }
            }

            ComponentSection("Selection Controls") {
                RadixGrid(columns: 2, gap: 3) {
                    RadixCard {
                        RadixFlex(direction: .vertical, gap: 3, alignment: .leading) {
                            RadixSelect("Region", selection: $selectedRegion, options: regionOptions)
                            RadixSegmentedControl(selection: $selectedPlan, options: planOptions)
                            RadixRadioGroup(selection: $selectedPlan, options: planOptions)
                            RadixRadio("Manual radio", isSelected: selectedPlan == "enterprise") {
                                selectedPlan = "enterprise"
                            }
                        }
                    }
                    RadixCard {
                        RadixFlex(direction: .vertical, gap: 3, alignment: .leading) {
                            RadixCheckboxCards(selection: $cardChecks, options: [
                                RadixSelectionOption("email", label: "Email"),
                                RadixSelectionOption("push", label: "Push"),
                                RadixSelectionOption("audit", label: "Audit")
                            ])
                            RadixRadioCards(selection: $selectedPlan, options: planOptions)
                        }
                    }
                }
            }
        }
    }

    private var navigation: some View {
        CategoryStack {
            ComponentSection("Tabs and Navigation Menu") {
                RadixTabs(
                    selection: $tab,
                    tabs: [
                        RadixSelectionOption("components", label: "Components"),
                        RadixSelectionOption("tokens", label: "Tokens"),
                        RadixSelectionOption("icons", label: "Icons")
                    ]
                ) { value in
                    RadixCard {
                        RadixText("Selected tab: \(value)", size: .two)
                    }
                }

                RadixTabNav(selection: $tabNav, tabs: [
                    RadixSelectionOption("overview", label: "Overview"),
                    RadixSelectionOption("activity", label: "Activity"),
                    RadixSelectionOption("settings", label: "Settings")
                ])

                RadixNavigationMenu {
                    RadixButton("Docs", variant: .ghost) {}
                    RadixButton("Themes", variant: .ghost) {}
                    RadixButton("Colors", variant: .ghost) {}
                    RadixDropdownMenu {
                        DropdownTrigger(title: "More")
                    } content: {
                        RadixMenuSubmenu("Primitives") {
                            RadixMenuItem("Accordion")
                            RadixMenuItem("Dialog")
                            RadixMenuItem("Context Menu")
                            RadixMenuSeparator()
                            RadixMenuItem("View all primitives...")
                        }
                        RadixMenuItem("Icons")
                        RadixMenuSeparator()
                        RadixMenuItem("Themes")
                    }
                }
            }

            ComponentSection("Accordion, Collapsible, Menubar") {
                RadixGrid(columns: 2, gap: 3) {
                    RadixCard {
                        RadixAccordion(isExpanded: $isAccordionOpen) {
                            Text("Accordion")
                        } content: {
                            RadixText("Radix-drawn accordion content.", size: .two)
                        }
                    }
                    RadixCard {
                        RadixCollapsible(isOpen: $isCollapsibleOpen) {
                            Text("Collapsible")
                        } content: {
                            RadixText("Radix-drawn collapsible state.", size: .two)
                        }
                    }
                    RadixMenubar {
                        RadixDropdownMenu {
                            DropdownTrigger(title: "File")
                        } content: {
                            RadixMenuItem("New", shortcut: "⌘N")
                            RadixMenuItem("Open", shortcut: "⌘O")
                        }
                        RadixDropdownMenu {
                            DropdownTrigger(title: "Edit")
                        } content: {
                            RadixMenuItem("Copy", shortcut: "⌘C")
                            RadixMenuItem("Paste", shortcut: "⌘V")
                        }
                        RadixDropdownMenu {
                            DropdownTrigger(title: "View")
                        } content: {
                            RadixMenuItem("Toggle Sidebar")
                        }
                    }
                }
            }
        }
    }

    private var overlays: some View {
        CategoryStack {
            ComponentSection("Dialog, Alert Dialog, Popover, Hover Card") {
                RadixGrid(columns: 2, gap: 3) {
                    RadixCard {
                        RadixFlex(direction: .vertical, gap: 3, alignment: .leading) {
                            RadixButton("Open Dialog") {
                                isDialogOpen = true
                            }
                            RadixButton("Open Alert", variant: .surface) {
                                isAlertOpen = true
                            }
                        }
                    }
                    RadixCard {
                        RadixFlex(gap: 3) {
                            RadixPopover {
                                RadixButton("Popover", variant: .surface) {}
                            } content: {
                                RadixText("Popover content rendered by SwiftUI.", size: .two)
                            }
                            RadixHoverCard {
                                RadixBadge("Hover me")
                            } content: {
                                RadixText("Hover card preview.", size: .two)
                            }
                        }
                    }
                }
            }

            ComponentSection("Context Menu, Tooltip, Portal, Slot") {
                RadixGrid(columns: 2, gap: 3) {
                    RadixContextMenu {
                        RadixCard {
                            RadixText("Right-click this card for RadixContextMenu.", size: .two)
                        }
                    } menu: {
                        RadixMenuItem("Edit", shortcut: "⌘E")
                        RadixMenuItem("Duplicate", shortcut: "⌘D")
                        RadixMenuSeparator()
                        RadixMenuItem("Archive", shortcut: "⌘N")
                        RadixMenuSubmenu("More") {
                            RadixMenuItem("Move to project...")
                            RadixMenuItem("Move to folder...")
                            RadixMenuSeparator()
                            RadixMenuItem("Advanced options...")
                        }
                        RadixMenuSeparator()
                        RadixMenuItem("Share")
                        RadixMenuItem("Add to favorites")
                        RadixMenuSeparator()
                        RadixMenuItem("Delete", shortcut: "⌘⌫", destructive: true)
                    }
                    RadixCard {
                        RadixFlex(gap: 3) {
                            RadixTooltip("Radix themed tooltip") {
                                RadixButton("Tooltip", variant: .outline) {}
                            }
                            RadixPortal {
                                RadixBadge("Portal")
                            }
                            RadixSlot {
                                RadixBadge("Slot", color: .jade)
                            }
                        }
                    }
                }
            }
        }
    }

    private var feedback: some View {
        CategoryStack {
            ComponentSection("Callout, Progress, Spinner, Skeleton, Toast") {
                RadixGrid(columns: 2, gap: 3) {
                    RadixCard {
                        RadixFlex(direction: .vertical, gap: 3, alignment: .leading) {
                            RadixCallout(icon: .infoCircled, color: .blue) {
                                RadixText("Callout uses accent alpha background and text.", size: .two)
                            }
                            RadixProgress(value: slider, total: 100, color: .green)
                            RadixSpinner()
                            RadixSkeleton(width: 220, height: 18)
                        }
                    }
                    RadixCard {
                        RadixFlex(direction: .vertical, gap: 3, alignment: .leading) {
                            RadixButton("Announce status", variant: .surface) {
                                RadixAnnounce.polite("RadixSwift status changed")
                            }
                            RadixButton("Add toast", variant: .soft) {
                                toasts.append(RadixToast(title: "Toast \(toasts.count + 1)", message: "Native toast viewport row."))
                            }
                            RadixToastViewport(toasts)
                        }
                    }
                }
            }
        }
    }

    private var dataDisplay: some View {
        CategoryStack {
            ComponentSection("Avatar, Badge, Card, Data List") {
                RadixGrid(columns: 2, gap: 3) {
                    RadixCard {
                        RadixFlex(direction: .vertical, gap: 3, alignment: .leading) {
                            RadixFlex(gap: 2) {
                                RadixAvatar(fallback: "RS", size: 42)
                                RadixBadge("Live", color: .green)
                                RadixBadge("Warning", variant: .surface, color: .amber)
                            }
                            RadixDataList([
                                RadixDataListItem(label: "Package", value: "RadixSwift"),
                                RadixDataListItem(label: "Platform", value: "macOS"),
                                RadixDataListItem(label: "Icons", value: "\(RadixIconName.allCases.count)")
                            ])
                        }
                    }
                    RadixTable {
                        TableRow("Component", "Native backing")
                        TableRow("Select", "Radix trigger and menu")
                        TableRow("Dialog", "Radix overlay")
                        TableRow("Tooltip", "Help")
                    }
                }
            }
        }
    }

    private var icons: some View {
        CategoryStack {
            ComponentSection("Radix Icons") {
                RadixText("All 332 original SVGs are bundled as template images. Showing the first 96 here.", size: .two)
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(92), spacing: 10), count: 8), spacing: 10) {
                    ForEach(Array(RadixIconName.allCases.prefix(96))) { icon in
                        VStack(spacing: 6) {
                            RadixIcon(icon, size: 18)
                            Text(icon.rawValue)
                                .font(.system(size: 9))
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                        .frame(width: 92, height: 54)
                        .background(.quaternary.opacity(0.35))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                }
            }
        }
    }

    private var themePanel: some View {
        CategoryStack {
            ComponentSection("Theme Controls") {
                RadixGrid(columns: 2, gap: 3) {
                    RadixCard {
                        RadixFlex(direction: .vertical, gap: 3, alignment: .leading) {
                            RadixSelect("Appearance", selection: $appearance, options: RadixAppearance.allCases.map {
                                RadixSelectionOption($0, label: $0.rawValue.capitalized)
                            })
                            RadixSelect("Accent", selection: $accent, options: RadixAccentColor.allCases.map {
                                RadixSelectionOption($0, label: $0.rawValue.capitalized)
                            })
                            RadixSelect("Radius", selection: $radius, options: RadixRadius.allCases.map {
                                RadixSelectionOption($0, label: $0.rawValue.capitalized)
                            })
                            RadixSelect("Scaling", selection: $scaling, options: RadixScaling.allCases.map {
                                RadixSelectionOption($0, label: $0.rawValue)
                            })
                            RadixSelect("Motion", selection: $motion, options: CatalogMotionMode.allCases.map {
                                RadixSelectionOption($0, label: $0.rawValue)
                            })
                        }
                    }
                    RadixThemePanel()
                }
            }

            ComponentSection("Color Scales") {
                RadixGrid(columns: 2, gap: 3) {
                    ColorScaleCard(title: "Accent", color: accent.rawValue)
                    ColorScaleCard(title: "Gray", color: RadixColorCatalog.shared.matchingGrayColor(for: accent).rawValue)
                }
            }
        }
    }
}

private struct CategoryStack<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ComponentSection<Content: View>: View {
    let title: LocalizedStringKey
    private let content: Content

    @Environment(\.radixTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    init(_ title: LocalizedStringKey, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                RadixHeading(title, size: .four)
                Spacer()
            }
            content
        }
        .padding(16)
        .background(theme.panel(colorScheme: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: theme.radius(4), style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius(4), style: .continuous)
                .stroke(theme.gray(6, alpha: true, colorScheme: colorScheme), lineWidth: 1)
        )
    }
}

private struct RadixPreviewFrame: ViewModifier {
    @Environment(\.radixTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(theme.gray(2, colorScheme: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: theme.radius(4), style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: theme.radius(4), style: .continuous)
                    .stroke(theme.gray(6, alpha: true, colorScheme: colorScheme), lineWidth: 1)
            )
    }
}

private struct SegmentedButtonGroupDemo: View {
    @State private var textSelection = "a"
    @State private var iconSelection = "layers"
    @State private var mixedSelection = "activity"
    @State private var verticalTextSelection = "a"
    @State private var verticalIconSelection = "layers"
    @State private var verticalMixedSelection = "activity"

    @Environment(\.radixTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    private let textItems: [RadixSegmentedButtonGroupItem<String>] = [
        RadixSegmentedButtonGroupItem("a", label: "A"),
        RadixSegmentedButtonGroupItem("b", label: "B"),
        RadixSegmentedButtonGroupItem("c", label: "C")
    ]

    private let iconItems: [RadixSegmentedButtonGroupItem<String>] = [
        RadixSegmentedButtonGroupItem("layers", label: "Layers", icon: .layers),
        RadixSegmentedButtonGroupItem("globe", label: "World", icon: .globe),
        RadixSegmentedButtonGroupItem("bookmark", label: "Saved", icon: .bookmark),
        RadixSegmentedButtonGroupItem("box", label: "Archive", icon: .box),
        RadixSegmentedButtonGroupItem("trash", label: "Trash", icon: .trash),
        RadixSegmentedButtonGroupItem("reader", label: "Reader", icon: .reader)
    ]

    private let mixedItems: [RadixSegmentedButtonGroupItem<String>] = [
        RadixSegmentedButtonGroupItem("activity", label: "Activity", icon: .clock, badge: RadixSegmentedButtonBadge("1", color: .amber)),
        RadixSegmentedButtonGroupItem("docs", label: "Docs", icon: .fileText),
        RadixSegmentedButtonGroupItem("grid", label: "Grid", icon: .component1, badge: RadixSegmentedButtonBadge("3", color: .blue))
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: theme.space(4)) {
            HStack(alignment: .top, spacing: theme.space(6)) {
                demoColumn("Text") {
                    RadixSegmentedButtonGroup(
                        selection: $textSelection,
                        items: textItems,
                        display: .text
                    )
                }

                demoColumn("Icons") {
                    RadixSegmentedButtonGroup(
                        selection: $iconSelection,
                        items: iconItems,
                        display: .icon,
                        size: .three
                    )
                }

                demoColumn("Icon + text + badges") {
                    RadixSegmentedButtonGroup(
                        selection: $mixedSelection,
                        items: mixedItems,
                        display: .iconAndText,
                        color: .blue
                    )
                }
            }

            HStack(alignment: .top, spacing: theme.space(6)) {
                demoColumn("Vertical text") {
                    RadixSegmentedButtonGroup(
                        selection: $verticalTextSelection,
                        items: textItems,
                        orientation: .vertical,
                        display: .text
                    )
                }

                demoColumn("Vertical icons") {
                    RadixSegmentedButtonGroup(
                        selection: $verticalIconSelection,
                        items: Array(iconItems.prefix(4)),
                        orientation: .vertical,
                        display: .icon,
                        size: .three
                    )
                }

                demoColumn("Vertical badges") {
                    RadixSegmentedButtonGroup(
                        selection: $verticalMixedSelection,
                        items: mixedItems,
                        orientation: .vertical,
                        display: .iconAndText,
                        color: .amber
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func demoColumn<Content: View>(
        _ title: LocalizedStringKey,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: theme.space(2)) {
            RadixText(title, size: .one, weight: .medium)
                .foregroundStyle(theme.gray(11, colorScheme: colorScheme))
            content()
        }
    }
}

private struct DropdownTrigger: View {
    var title: String

    @Environment(\.radixTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: theme.space(2)) {
            Text(title)
            RadixIcon(.chevronDown, size: 10)
        }
        .font(theme.font(.two, weight: .medium))
        .foregroundStyle(theme.accent(11, alpha: true, colorScheme: colorScheme))
        .padding(.horizontal, theme.space(3))
        .frame(height: theme.space(6))
        .background(theme.surface(colorScheme: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: theme.radius(2), style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius(2), style: .continuous)
                .stroke(theme.accent(7, alpha: true, colorScheme: colorScheme), lineWidth: 1)
        )
    }
}

private struct ButtonVariantMatrix: View {
    @Environment(\.radixTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    private let sizes: [RadixSize] = [.one, .two, .three, .four]

    var body: some View {
        VStack(alignment: .leading, spacing: theme.space(3)) {
            Grid(alignment: .leading, horizontalSpacing: theme.space(5), verticalSpacing: theme.space(3)) {
                GridRow {
                    Text("")
                    ForEach(sizes) { size in
                        RadixText("Size \(size.rawValue)", size: .one, weight: .medium)
                            .foregroundStyle(theme.gray(11, colorScheme: colorScheme))
                    }
                }

                ForEach(RadixThemeVariant.allCases, id: \.rawValue) { variant in
                    GridRow {
                        RadixLabel(LocalizedStringKey(variant.rawValue.capitalized))
                            .frame(width: 74, alignment: .leading)

                        ForEach(sizes) { size in
                            RadixButton(variant: variant, size: size) {} label: {
                                HStack(spacing: theme.space(2)) {
                                    Text("Next")
                                    RadixIcon(.arrowRight, size: size.rawValue <= 2 ? 12 : 14)
                                }
                            }
                        }
                    }
                }
            }

            RadixFlex(gap: 2) {
                RadixText("High contrast", size: .one, weight: .medium)
                    .foregroundStyle(theme.gray(11, colorScheme: colorScheme))
                RadixButton("Button", variant: .solid, color: .crimson, highContrast: true) {}
                RadixButton("Button", variant: .soft, color: .crimson, highContrast: true) {}
                RadixButton("Button", variant: .outline, color: .crimson, highContrast: true) {}
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct TableRow: View {
    var first: String
    var second: String

    init(_ first: String, _ second: String) {
        self.first = first
        self.second = second
    }

    var body: some View {
        HStack {
            Text(first).fontWeight(.medium)
            Spacer()
            Text(second)
        }
        .padding(.vertical, 6)
        Divider()
    }
}

private struct ColorScaleCard: View {
    var title: String
    var color: String

    @Environment(\.radixTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        RadixCard {
            VStack(alignment: .leading, spacing: 10) {
                RadixHeading(LocalizedStringKey(title), size: .four)
                HStack(spacing: 4) {
                    ForEach(1...12, id: \.self) { step in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(RadixColorCatalog.shared.color(
                                scale: color,
                                step: step,
                                appearance: theme.resolvedAppearance(for: colorScheme)
                            ))
                            .frame(height: 34)
                    }
                }
                RadixText(size: .two) {
                    Text(color)
                }
            }
        }
    }
}
