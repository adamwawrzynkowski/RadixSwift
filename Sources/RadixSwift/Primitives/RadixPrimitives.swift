import SwiftUI

public struct RadixAspectRatio<Content: View>: View {
    public var ratio: CGFloat
    private let content: Content

    public init(_ ratio: CGFloat = 16 / 9, @ViewBuilder content: () -> Content) {
        self.ratio = ratio
        self.content = content()
    }

    public var body: some View {
        content.aspectRatio(ratio, contentMode: .fit)
    }
}

public struct RadixScrollArea<Content: View>: View {
    public var axes: Axis.Set
    public var showsIndicators: Bool
    private let content: Content

    public init(
        _ axes: Axis.Set = .vertical,
        showsIndicators: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.content = content()
    }

    public var body: some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            content
        }
    }
}

public struct RadixAccordion<Label: View, Content: View>: View {
    @Binding private var isExpanded: Bool
    private let label: Label
    private let content: Content

    @Environment(\.radixTheme) private var theme
    @Environment(\.radixAnimations) private var animations
    @Environment(\.colorScheme) private var colorScheme

    public init(
        isExpanded: Binding<Bool>,
        @ViewBuilder label: () -> Label,
        @ViewBuilder content: () -> Content
    ) {
        self._isExpanded = isExpanded
        self.label = label()
        self.content = content()
    }

    public var body: some View {
        let radius = theme.radius(3)

        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(animations.animation(for: .disclosure)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: theme.space(2)) {
                    label
                        .font(theme.font(.two, weight: .medium))
                        .foregroundStyle(theme.gray(12, colorScheme: colorScheme))

                    Spacer(minLength: theme.space(3))

                    RadixIcon(.chevronDown, size: 12)
                        .foregroundStyle(theme.gray(11, colorScheme: colorScheme))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(.horizontal, theme.space(3))
                .frame(minHeight: theme.space(6))
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                content
                    .font(theme.font(.two))
                    .foregroundStyle(theme.gray(11, colorScheme: colorScheme))
                    .padding(.horizontal, theme.space(3))
                    .padding(.bottom, theme.space(3))
                    .transition(animations.transition(for: .disclosure))
            }
        }
        .background(accordionBackground(radius: radius))
        .radixInteractiveGlass(in: RoundedRectangle(cornerRadius: radius, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .stroke(theme.gray(6, alpha: true, colorScheme: colorScheme), lineWidth: 1)
        )
        .accessibilityElement(children: .contain)
    }

    private func accordionBackground(radius: CGFloat) -> some View {
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)

        return shape.fill(theme.controlSurface(colorScheme: colorScheme))
    }
}

public struct RadixCollapsible<Label: View, Content: View>: View {
    @Binding private var isOpen: Bool
    private let label: Label
    private let content: Content

    public init(
        isOpen: Binding<Bool>,
        @ViewBuilder label: () -> Label,
        @ViewBuilder content: () -> Content
    ) {
        self._isOpen = isOpen
        self.label = label()
        self.content = content()
    }

    public var body: some View {
        RadixAccordion(isExpanded: $isOpen) {
            label
        } content: {
            content
        }
    }
}

public struct RadixTabs<Value: Hashable & Sendable, Content: View>: View {
    @Binding private var selection: Value
    public var tabs: [RadixSelectionOption<Value>]
    private let content: (Value) -> Content

    @Environment(\.radixTheme) private var theme

    public init(
        selection: Binding<Value>,
        tabs: [RadixSelectionOption<Value>],
        @ViewBuilder content: @escaping (Value) -> Content
    ) {
        self._selection = selection
        self.tabs = tabs
        self.content = content
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.space(3)) {
            RadixSegmentedControl(selection: $selection, options: tabs)
            content(selection)
        }
    }
}

public struct RadixTabNav<Value: Hashable & Sendable>: View {
    @Binding private var selection: Value
    public var tabs: [RadixSelectionOption<Value>]

    @Environment(\.radixTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    public init(selection: Binding<Value>, tabs: [RadixSelectionOption<Value>]) {
        self._selection = selection
        self.tabs = tabs
    }

    public var body: some View {
        RadixGlassEffectGroup(spacing: theme.space(1)) {
            HStack(spacing: theme.space(1)) {
                ForEach(tabs) { tab in
                    let isSelected = selection == tab.id
                    let shape = RoundedRectangle(cornerRadius: theme.radius(2), style: .continuous)

                    Button {
                        selection = tab.id
                    } label: {
                        Text(tab.label)
                            .font(theme.font(.two, weight: isSelected ? .medium : .regular))
                            .padding(.horizontal, theme.space(2))
                            .padding(.vertical, theme.space(1))
                            .foregroundStyle(isSelected ? theme.accent(11, colorScheme: colorScheme) : theme.gray(11, colorScheme: colorScheme))
                            .background(shape.fill(isSelected ? theme.accent(3, alpha: true, colorScheme: colorScheme) : .clear))
                            .radixInteractiveGlass(
                                active: isSelected,
                                tint: theme.accent(9, colorScheme: colorScheme).opacity(0.16),
                                in: shape
                            )
                            .clipShape(shape)
                            .contentShape(shape)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

public struct RadixToggle<Label: View>: View {
    @Binding private var isPressed: Bool
    private let label: Label

    public init(isPressed: Binding<Bool>, @ViewBuilder label: () -> Label) {
        self._isPressed = isPressed
        self.label = label()
    }

    public var body: some View {
        RadixButton(variant: isPressed ? .solid : .soft, size: .two) {
            isPressed.toggle()
        } label: {
            label
        }
    }
}

public struct RadixToggleGroup<Value: Hashable & Sendable>: View {
    @Binding private var selection: Set<Value>
    public var items: [RadixSelectionOption<Value>]

    public init(selection: Binding<Set<Value>>, items: [RadixSelectionOption<Value>]) {
        self._selection = selection
        self.items = items
    }

    public var body: some View {
        RadixGlassEffectGroup(spacing: 4) {
            HStack(spacing: 4) {
                ForEach(items) { item in
                    RadixButton(
                        variant: selection.contains(item.id) ? .solid : .soft,
                        size: .one
                    ) {
                        if selection.contains(item.id) {
                            selection.remove(item.id)
                        } else {
                            selection.insert(item.id)
                        }
                    } label: {
                        Text(item.label)
                    }
                }
            }
        }
    }
}

public struct RadixDialog<DialogContent: View>: ViewModifier {
    @Binding private var isPresented: Bool
    private let dialogContent: DialogContent
    public var size: RadixSize

    @Environment(\.radixTheme) private var theme
    @Environment(\.radixAnimations) private var animations
    @Environment(\.colorScheme) private var colorScheme

    public init(
        isPresented: Binding<Bool>,
        size: RadixSize = .three,
        @ViewBuilder content: () -> DialogContent
    ) {
        self._isPresented = isPresented
        self.size = size
        self.dialogContent = content()
    }

    public func body(content: Content) -> some View {
        content
            .overlay {
                if isPresented {
                    ZStack {
                        theme.overlay(colorScheme: colorScheme)
                            .ignoresSafeArea()
                            .onTapGesture {
                                isPresented = false
                            }

                        RadixTheme(animations: animations, hasBackground: false) {
                            dialogContent
                                .padding(dialogPadding)
                                .frame(minWidth: 360, idealWidth: 520, maxWidth: 640, alignment: .leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .background(theme.solidPanel(colorScheme: colorScheme))
                                .clipShape(RoundedRectangle(cornerRadius: dialogRadius, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: dialogRadius, style: .continuous)
                                        .stroke(theme.gray(6, alpha: true, colorScheme: colorScheme), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(colorScheme == .dark ? 0.22 : 0.08), radius: 18, x: 0, y: 12)
                                .transition(animations.transition(for: .dialog))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .zIndex(1000)
                    .transition(.opacity)
                }
            }
            .animation(animations.animation(for: .dialog), value: isPresented)
    }

    private var dialogPadding: CGFloat {
        switch size {
        case .one: theme.space(3)
        case .two: theme.space(4)
        case .three: theme.space(5)
        case .four: theme.space(6)
        default: theme.space(5)
        }
    }

    private var dialogRadius: CGFloat {
        theme.radius(size.rawValue <= 2 ? 4 : 5)
    }
}

public struct RadixAlertDialog: ViewModifier {
    @Binding private var isPresented: Bool
    public var title: String
    public var message: String
    public var confirmTitle: String
    public var cancelTitle: String
    public var destructive: Bool
    public var onConfirm: () -> Void

    @Environment(\.radixTheme) private var theme
    @Environment(\.radixAnimations) private var animations
    @Environment(\.colorScheme) private var colorScheme

    public init(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        confirmTitle: String = "OK",
        cancelTitle: String = "Cancel",
        destructive: Bool = false,
        onConfirm: @escaping () -> Void = {}
    ) {
        self._isPresented = isPresented
        self.title = title
        self.message = message
        self.confirmTitle = confirmTitle
        self.cancelTitle = cancelTitle
        self.destructive = destructive
        self.onConfirm = onConfirm
    }

    public func body(content: Content) -> some View {
        content
            .overlay {
                if isPresented {
                    ZStack {
                        theme.overlay(colorScheme: colorScheme)
                            .ignoresSafeArea()
                            .onTapGesture {
                                isPresented = false
                            }

                        RadixTheme(animations: animations, hasBackground: false) {
                            VStack(alignment: .leading, spacing: theme.space(4)) {
                                VStack(alignment: .leading, spacing: theme.space(3)) {
                                    Text(title)
                                        .font(theme.font(.six, weight: .bold))
                                        .foregroundStyle(theme.gray(12, colorScheme: colorScheme))

                                    Text(message)
                                        .font(theme.font(.three))
                                        .lineSpacing(2)
                                        .foregroundStyle(theme.gray(12, colorScheme: colorScheme))
                                        .fixedSize(horizontal: false, vertical: true)
                                }

                                HStack(spacing: theme.space(3)) {
                                    Spacer()
                                    RadixButton(cancelTitle.localizedKey, variant: .soft) {
                                        isPresented = false
                                    }
                                    RadixButton(confirmTitle.localizedKey, variant: .solid, color: destructive ? .red : nil) {
                                        isPresented = false
                                        onConfirm()
                                    }
                                }
                            }
                            .padding(theme.space(6))
                            .frame(minWidth: 440, idealWidth: 520, maxWidth: 620, alignment: .leading)
                            .background(theme.solidPanel(colorScheme: colorScheme))
                            .clipShape(RoundedRectangle(cornerRadius: theme.radius(5), style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: theme.radius(5), style: .continuous)
                                    .stroke(theme.gray(6, alpha: true, colorScheme: colorScheme), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.12), radius: 22, x: 0, y: 14)
                            .transition(animations.transition(for: .dialog))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .zIndex(1000)
                    .transition(.opacity)
                }
            }
            .animation(animations.animation(for: .dialog), value: isPresented)
    }
}

public struct RadixPopover<Label: View, Content: View>: View {
    private let label: Label
    private let content: Content
    @State private var isPresented = false
    @Environment(\.radixTheme) private var theme
    @Environment(\.radixAnimations) private var animations

    public init(@ViewBuilder label: () -> Label, @ViewBuilder content: () -> Content) {
        self.label = label()
        self.content = content()
    }

    public var body: some View {
        Button {
            isPresented.toggle()
        } label: {
            label
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .background(
            RadixFloatingPanel(isPresented: $isPresented, placement: .belowAnchor(offset: 4)) {
                RadixTheme(
                    appearance: theme.appearance,
                    accentColor: theme.accentColor,
                    grayColor: theme.grayColor,
                    panelBackground: theme.panelBackground,
                    radius: theme.radius,
                    scaling: theme.scaling,
                    animations: animations,
                    hasBackground: false
                ) {
                    RadixPopupPanel {
                        content
                    }
                }
            }
        )
    }
}

public struct RadixHoverCard<Label: View, Content: View>: View {
    private let label: Label
    private let content: Content
    @State private var isPresented = false
    @Environment(\.radixTheme) private var theme
    @Environment(\.radixAnimations) private var animations

    public init(@ViewBuilder label: () -> Label, @ViewBuilder content: () -> Content) {
        self.label = label()
        self.content = content()
    }

    public var body: some View {
        label
            .contentShape(Rectangle())
            .onHover { isPresented = $0 }
            .background(
                RadixFloatingPanel(isPresented: $isPresented, placement: .belowAnchor(offset: 4)) {
                    RadixTheme(
                        appearance: theme.appearance,
                        accentColor: theme.accentColor,
                        grayColor: theme.grayColor,
                        panelBackground: theme.panelBackground,
                        radius: theme.radius,
                        scaling: theme.scaling,
                        animations: animations,
                        hasBackground: false
                    ) {
                        RadixPopupPanel {
                            content
                        }
                    }
                }
            )
    }
}

struct RadixMenuDismissAction: Sendable {
    private let action: @MainActor @Sendable () -> Void

    init(_ action: @escaping @MainActor @Sendable () -> Void = {}) {
        self.action = action
    }

    @MainActor func callAsFunction() {
        action()
    }
}

private struct RadixMenuDismissActionKey: EnvironmentKey {
    static let defaultValue = RadixMenuDismissAction()
}

extension EnvironmentValues {
    var radixMenuDismiss: RadixMenuDismissAction {
        get { self[RadixMenuDismissActionKey.self] }
        set { self[RadixMenuDismissActionKey.self] = newValue }
    }
}

public struct RadixMenuItem: View {
    public var title: String
    public var shortcut: String?
    public var icon: RadixIconName?
    public var trailingIcon: RadixIconName?
    public var destructive: Bool
    public var selected: Bool
    public var highlighted: Bool
    public var disabled: Bool
    private let action: () -> Void

    @State private var isHovered = false
    @Environment(\.radixTheme) private var theme
    @Environment(\.radixAnimations) private var animations
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.radixMenuDismiss) private var dismissMenu

    public init(
        _ title: String,
        shortcut: String? = nil,
        icon: RadixIconName? = nil,
        trailingIcon: RadixIconName? = nil,
        destructive: Bool = false,
        selected: Bool = false,
        highlighted: Bool = false,
        disabled: Bool = false,
        action: @escaping () -> Void = {}
    ) {
        self.title = title
        self.shortcut = shortcut
        self.icon = icon
        self.trailingIcon = trailingIcon
        self.destructive = destructive
        self.selected = selected
        self.highlighted = highlighted
        self.disabled = disabled
        self.action = action
    }

    public var body: some View {
        let active = !disabled && (highlighted || isHovered)
        let palette = RadixComponentPalette(theme: theme, colorScheme: colorScheme, overrideColor: destructive ? .red : nil)

        Button {
            guard !disabled else { return }
            action()
            dismissMenu()
        } label: {
            HStack(spacing: theme.space(2)) {
                if let icon {
                    RadixIcon(icon, size: 14)
                        .frame(width: 16)
                } else if selected {
                    RadixIcon(.check, size: 10)
                        .frame(width: 16)
                }

                Text(title)
                    .lineLimit(1)

                Spacer(minLength: theme.space(4))

                if let shortcut {
                    Text(shortcut)
                        .foregroundStyle(active ? menuForeground(active: true, palette: palette) : theme.gray(11, alpha: true, colorScheme: colorScheme))
                }

                if let trailingIcon {
                    RadixIcon(trailingIcon, size: 13)
                }
            }
            .font(theme.font(.two))
            .foregroundStyle(menuForeground(active: active, palette: palette))
            .frame(height: theme.space(6))
            .padding(.horizontal, theme.space(3))
            .background(menuBackground(active: active, palette: palette))
            .radixInteractiveGlass(
                active: active,
                enabled: !disabled,
                tint: palette.accent(9).opacity(0.22),
                in: RoundedRectangle(cornerRadius: theme.radius(2), style: .continuous)
            )
            .clipShape(RoundedRectangle(cornerRadius: theme.radius(2), style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: theme.radius(2), style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(disabled)
        .opacity(disabled ? 0.55 : 1)
        .onHover { isHovered = $0 }
        .animation(animations.animation(for: .hover), value: active)
    }

    private func menuForeground(active: Bool, palette: RadixComponentPalette) -> Color {
        if active {
            return destructive ? palette.contrast() : palette.contrast()
        }
        if destructive {
            return palette.accent(11, alpha: true)
        }
        return theme.gray(12, colorScheme: colorScheme)
    }

    private func menuHighlight(palette: RadixComponentPalette) -> Color {
        destructive ? palette.accent(9) : palette.accent(9)
    }

    @ViewBuilder
    private func menuBackground(active: Bool, palette: RadixComponentPalette) -> some View {
        let shape = RoundedRectangle(cornerRadius: theme.radius(2), style: .continuous)

        shape.fill(active ? menuHighlight(palette: palette) : .clear)
    }
}

public struct RadixMenuSeparator: View {
    @Environment(\.radixTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    public init() {}

    public var body: some View {
        Rectangle()
            .fill(theme.gray(6, alpha: true, colorScheme: colorScheme))
            .frame(height: 1)
            .padding(.vertical, theme.space(2))
            .padding(.leading, theme.space(3))
            .padding(.trailing, theme.space(3))
    }
}

public struct RadixMenuSubmenu<Content: View>: View {
    public var title: String
    private let content: Content

    @State private var isOpen = false
    @State private var rowHovered = false
    @State private var panelHovered = false
    @Environment(\.radixTheme) private var theme
    @Environment(\.radixAnimations) private var animations
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.radixMenuDismiss) private var dismissMenu

    public init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    public var body: some View {
        let palette = RadixComponentPalette(theme: theme, colorScheme: colorScheme, overrideColor: nil)

        Button {
            isOpen = true
        } label: {
            HStack(spacing: theme.space(2)) {
                Text(title)
                    .lineLimit(1)

                Spacer(minLength: theme.space(4))

                RadixIcon(.chevronRight, size: 13)
            }
            .font(theme.font(.two))
            .foregroundStyle(isOpen ? palette.contrast() : theme.gray(12, colorScheme: colorScheme))
            .frame(height: theme.space(6))
            .padding(.horizontal, theme.space(3))
            .background(submenuBackground(isOpen: isOpen, palette: palette))
            .radixInteractiveGlass(
                active: isOpen,
                tint: palette.accent(9).opacity(0.22),
                in: RoundedRectangle(cornerRadius: theme.radius(2), style: .continuous)
            )
            .clipShape(RoundedRectangle(cornerRadius: theme.radius(2), style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: theme.radius(2), style: .continuous))
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            rowHovered = hovering
            if hovering {
                isOpen = true
            } else {
                closeIfIdleSoon()
            }
        }
        .background(
            RadixFloatingPanel(isPresented: $isOpen, placement: .rightOfAnchor(offset: 4)) {
                RadixTheme(
                    appearance: theme.appearance,
                    accentColor: theme.accentColor,
                    grayColor: theme.grayColor,
                    panelBackground: theme.panelBackground,
                    radius: theme.radius,
                    scaling: theme.scaling,
                    animations: animations,
                    hasBackground: false
                ) {
                    RadixPopupPanel(minWidth: 240) {
                        content
                            .environment(\.radixMenuDismiss, RadixMenuDismissAction {
                                isOpen = false
                                dismissMenu()
                            })
                    }
                    .onHover { hovering in
                        panelHovered = hovering
                        if hovering {
                            isOpen = true
                        } else {
                            closeIfIdleSoon()
                        }
                    }
                }
            }
        )
        .animation(animations.animation(for: .popup), value: isOpen)
    }

    private func closeIfIdleSoon() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
            if !rowHovered && !panelHovered {
                isOpen = false
            }
        }
    }

    @ViewBuilder
    private func submenuBackground(isOpen: Bool, palette: RadixComponentPalette) -> some View {
        let shape = RoundedRectangle(cornerRadius: theme.radius(2), style: .continuous)

        shape.fill(isOpen ? palette.accent(9) : .clear)
    }
}

public struct RadixMenuLabel: View {
    public var title: String

    @Environment(\.radixTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    public init(_ title: String) {
        self.title = title
    }

    public var body: some View {
        Text(title)
            .font(theme.font(.two))
            .foregroundStyle(theme.gray(10, alpha: true, colorScheme: colorScheme))
            .frame(height: theme.space(6), alignment: .center)
            .padding(.horizontal, theme.space(3))
    }
}

public struct RadixDropdownMenu<Label: View, Content: View>: View {
    private let label: Label
    private let content: Content
    @State private var isPresented = false
    @Environment(\.radixTheme) private var theme
    @Environment(\.radixAnimations) private var animations

    public init(@ViewBuilder label: () -> Label, @ViewBuilder content: () -> Content) {
        self.label = label()
        self.content = content()
    }

    public var body: some View {
        Button {
            isPresented.toggle()
        } label: {
            label
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .background(
            RadixFloatingPanel(isPresented: $isPresented, placement: .belowAnchor(offset: 6)) {
                RadixTheme(
                    appearance: theme.appearance,
                    accentColor: theme.accentColor,
                    grayColor: theme.grayColor,
                    panelBackground: theme.panelBackground,
                    radius: theme.radius,
                    scaling: theme.scaling,
                    animations: animations,
                    hasBackground: false
                ) {
                    RadixPopupPanel(minWidth: 220) {
                        content
                            .environment(\.radixMenuDismiss, RadixMenuDismissAction {
                                isPresented = false
                            })
                    }
                }
            }
        )
    }
}

public struct RadixContextMenu<MenuContent: View, Content: View>: View {
    private let content: Content
    private let menu: MenuContent
    @State private var isPresented = false
    @State private var menuLocation = CGPoint.zero
    @Environment(\.radixTheme) private var theme
    @Environment(\.radixAnimations) private var animations

    public init(@ViewBuilder content: () -> Content, @ViewBuilder menu: () -> MenuContent) {
        self.content = content()
        self.menu = menu()
    }

    public var body: some View {
        RadixSecondaryClickHost {
            content
        } onRightClick: { location in
            menuLocation = location
            isPresented = true
        }
        .background(
            RadixFloatingPanel(isPresented: $isPresented, placement: .point(menuLocation)) {
                RadixTheme(
                    appearance: theme.appearance,
                    accentColor: theme.accentColor,
                    grayColor: theme.grayColor,
                    panelBackground: theme.panelBackground,
                    radius: theme.radius,
                    scaling: theme.scaling,
                    animations: animations,
                    hasBackground: false
                ) {
                    RadixPopupPanel(minWidth: 220) {
                        menu
                            .environment(\.radixMenuDismiss, RadixMenuDismissAction {
                                isPresented = false
                            })
                    }
                }
            }
        )
    }
}

public struct RadixTooltip<Content: View>: View {
    public var text: String
    private let content: Content
    @State private var isPresented = false

    @Environment(\.radixTheme) private var theme
    @Environment(\.radixAnimations) private var animations
    @Environment(\.colorScheme) private var colorScheme

    public init(_ text: String, @ViewBuilder content: () -> Content) {
        self.text = text
        self.content = content()
    }

    public var body: some View {
        content
            .contentShape(Rectangle())
            .onHover { isPresented = $0 }
            .overlay(alignment: .top) {
                if isPresented {
                    Text(text)
                        .font(theme.font(.one, weight: .medium))
                        .foregroundStyle(theme.gray(1, colorScheme: colorScheme))
                        .padding(.horizontal, theme.space(2))
                        .frame(height: theme.space(5))
                        .background(theme.gray(12, colorScheme: colorScheme))
                        .clipShape(RoundedRectangle(cornerRadius: theme.radius(2), style: .continuous))
                        .shadow(color: .black.opacity(colorScheme == .dark ? 0.16 : 0.07), radius: 7, x: 0, y: 4)
                        .offset(y: -theme.space(7))
                        .transition(animations.transition(for: .tooltip))
                        .allowsHitTesting(false)
                }
            }
            .animation(animations.animation(for: .tooltip), value: isPresented)
    }
}

public struct RadixToolbar<Content: View>: View {
    private let content: Content

    @Environment(\.radixTheme) private var theme

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        RadixGlassEffectGroup(spacing: theme.space(2)) {
            HStack(spacing: theme.space(2)) {
                content
            }
        }
    }
}

public struct RadixMenubar<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        RadixGlassEffectGroup(spacing: 8) {
            HStack(spacing: 8) {
                content
            }
        }
    }
}

public struct RadixNavigationMenu<Content: View>: View {
    private let content: Content

    @Environment(\.radixTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        RadixGlassEffectGroup(spacing: theme.space(3)) {
            HStack(spacing: theme.space(3)) {
                content
            }
        }
        .padding(theme.space(2))
        .background(theme.panel(colorScheme: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: theme.radius(3), style: .continuous))
    }
}

public struct RadixPortal<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
    }
}

public struct RadixSlot<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
    }
}

public struct RadixToast: Identifiable, Equatable, Sendable {
    public let id: UUID
    public var title: String
    public var message: String?

    public init(id: UUID = UUID(), title: String, message: String? = nil) {
        self.id = id
        self.title = title
        self.message = message
    }
}

public struct RadixToastViewport: View {
    public var toasts: [RadixToast]

    @Environment(\.radixTheme) private var theme

    public init(_ toasts: [RadixToast]) {
        self.toasts = toasts
    }

    public var body: some View {
        VStack(alignment: .trailing, spacing: theme.space(2)) {
            ForEach(toasts) { toast in
                RadixCard(size: .two) {
                    VStack(alignment: .leading, spacing: theme.space(1)) {
                        Text(toast.title).font(theme.font(.two, weight: .medium))
                        if let message = toast.message {
                            Text(message).font(theme.font(.one))
                        }
                    }
                }
                .frame(maxWidth: 320, alignment: .trailing)
            }
        }
    }
}

public struct RadixOneTimePasswordField: View {
    @Binding private var text: String
    public var length: Int

    public init(text: Binding<String>, length: Int = 6) {
        self._text = text
        self.length = length
    }

    public var body: some View {
        RadixTextField("Code", text: Binding {
            text
        } set: { newValue in
            text = String(newValue.prefix(length))
        })
        .textContentType(.oneTimeCode)
    }
}

public struct RadixPasswordToggleField: View {
    public var title: LocalizedStringKey
    @Binding private var text: String
    @State private var isVisible = false
    @FocusState private var isFocused: Bool

    @Environment(\.radixTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    public init(_ title: LocalizedStringKey = "Password", text: Binding<String>) {
        self.title = title
        self._text = text
    }

    public var body: some View {
        let radius = theme.radius(2)

        HStack(spacing: theme.space(2)) {
            if isVisible {
                TextField(title, text: $text)
                    .textFieldStyle(.plain)
                    .focused($isFocused)
            } else {
                SecureField(title, text: $text)
                    .textFieldStyle(.plain)
                    .focused($isFocused)
            }

            RadixIconButton(
                icon: isVisible ? .eyeOpen : .eyeClosed,
                label: isVisible ? "Hide password" : "Show password",
                variant: .ghost,
                size: .one
            ) {
                isVisible.toggle()
            }
        }
        .font(theme.font(.two))
        .foregroundStyle(theme.gray(12, colorScheme: colorScheme))
        .padding(.leading, theme.space(3) - 1)
        .padding(.trailing, theme.space(1))
        .frame(minHeight: theme.space(6))
        .background(theme.controlSurface(colorScheme: colorScheme))
        .overlay(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .stroke(theme.gray(isFocused ? 8 : 7, alpha: true, colorScheme: colorScheme), lineWidth: 1)
        )
        .overlay {
            if isFocused {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(theme.accent(8, alpha: true, colorScheme: colorScheme), lineWidth: 2)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
}

public extension View {
    func radixDialog<DialogContent: View>(
        isPresented: Binding<Bool>,
        size: RadixSize = .three,
        @ViewBuilder content: () -> DialogContent
    ) -> some View {
        modifier(RadixDialog(isPresented: isPresented, size: size, content: content))
    }

    func radixAlertDialog(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        confirmTitle: String = "OK",
        cancelTitle: String = "Cancel",
        destructive: Bool = false,
        onConfirm: @escaping () -> Void = {}
    ) -> some View {
        modifier(
            RadixAlertDialog(
                isPresented: isPresented,
                title: title,
                message: message,
                confirmTitle: confirmTitle,
                cancelTitle: cancelTitle,
                destructive: destructive,
                onConfirm: onConfirm
            )
        )
    }
}

private extension String {
    var localizedKey: LocalizedStringKey {
        LocalizedStringKey(self)
    }
}
