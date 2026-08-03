import AppKit
import SwiftUI

struct RadixComponentPalette {
    let theme: RadixThemeValues
    let colorScheme: ColorScheme
    let overrideColor: RadixAccentColor?

    var color: RadixAccentColor {
        overrideColor ?? theme.accentColor
    }

    func accent(_ step: Int, alpha: Bool = false) -> Color {
        RadixColorCatalog.shared.color(
            scale: color.rawValue,
            step: step,
            appearance: theme.resolvedAppearance(for: colorScheme),
            alpha: alpha
        )
    }

    func gray(_ step: Int, alpha: Bool = false) -> Color {
        theme.gray(step, alpha: alpha, colorScheme: colorScheme)
    }

    func contrast() -> Color {
        RadixColorCatalog.shared.themeContrast(for: color)
    }

    func surface() -> Color {
        RadixColorCatalog.shared.themeSurface(
            for: color,
            appearance: theme.resolvedAppearance(for: colorScheme)
        )
    }
}

struct RadixControlMetrics {
    let size: RadixSize
    let theme: RadixThemeValues

    var height: CGFloat {
        switch size {
        case .one: theme.space(5)
        case .two: theme.space(6)
        case .three: theme.space(7)
        case .four: theme.space(8)
        default: theme.space(7)
        }
    }

    var buttonHorizontalPadding: CGFloat {
        switch size {
        case .one: theme.space(2)
        case .two: theme.space(3)
        case .three: theme.space(4)
        case .four: theme.space(5)
        default: theme.space(4)
        }
    }

    var controlHorizontalPadding: CGFloat {
        switch size {
        case .one: theme.space(2)
        case .two: theme.space(3)
        case .three: theme.space(4)
        default: theme.space(3)
        }
    }

    var radius: CGFloat {
        theme.radius(min(max(size.rawValue, 1), 4))
    }
}

extension RadixThemeValues {
    func solidPanel(colorScheme: ColorScheme) -> Color {
        resolvedAppearance(for: colorScheme) == .dark ? gray(2, colorScheme: colorScheme) : .white
    }

    func controlSurface(colorScheme: ColorScheme) -> Color {
        resolvedAppearance(for: colorScheme) == .dark
            ? gray(2, alpha: true, colorScheme: colorScheme)
            : Color.white.opacity(0.82)
    }
}

struct RadixGlassEffectGroup<Content: View>: View {
    var spacing: CGFloat
    private let content: Content

    init(spacing: CGFloat, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    var body: some View {
        if #available(iOS 26.0, macOS 26.0, macCatalyst 26.0, tvOS 26.0, watchOS 26.0, *) {
            GlassEffectContainer(spacing: resolvedSpacing) {
                content
            }
        } else {
            content
        }
    }

    private var resolvedSpacing: CGFloat {
        max(spacing + 1, 1)
    }
}

struct RadixInsetRoundedRectangle: Shape {
    var cornerRadius: CGFloat
    var horizontalInset: CGFloat = 0
    var verticalInset: CGFloat

    func path(in rect: CGRect) -> Path {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .path(in: rect.insetBy(dx: horizontalInset, dy: verticalInset))
    }
}

extension View {
    @ViewBuilder
    func radixInteractiveGlass<S: Shape>(
        active: Bool = true,
        enabled: Bool = true,
        tint: Color? = nil,
        in shape: S
    ) -> some View {
        if active, #available(iOS 26.0, macOS 26.0, macCatalyst 26.0, tvOS 26.0, watchOS 26.0, *) {
            if let tint {
                glassEffect(.regular.tint(tint).interactive(enabled), in: shape)
                    .glassEffectTransition(.materialize)
            } else {
                glassEffect(.regular.interactive(enabled), in: shape)
                    .glassEffectTransition(.materialize)
            }
        } else {
            self
        }
    }

    @ViewBuilder
    func radixInteractiveGlass<S: Shape, ID: Hashable & Sendable>(
        active: Bool = true,
        enabled: Bool = true,
        tint: Color? = nil,
        in shape: S,
        effectID: ID,
        namespace: Namespace.ID
    ) -> some View {
        if active, #available(iOS 26.0, macOS 26.0, macCatalyst 26.0, tvOS 26.0, watchOS 26.0, *) {
            if let tint {
                glassEffect(.regular.tint(tint).interactive(enabled), in: shape)
                    .glassEffectTransition(.materialize)
                    .glassEffectID(effectID, in: namespace)
            } else {
                glassEffect(.regular.interactive(enabled), in: shape)
                    .glassEffectTransition(.materialize)
                    .glassEffectID(effectID, in: namespace)
            }
        } else {
            self
        }
    }

    func radixResponsiveHover(active: Bool = true, scale: CGFloat = 1.012) -> some View {
        modifier(RadixResponsiveHoverModifier(active: active, scale: scale))
    }
}

private struct RadixResponsiveHoverModifier: ViewModifier {
    var active: Bool
    var scale: CGFloat

    @State private var isHovered = false
    @Environment(\.radixAnimations) private var animations

    func body(content: Content) -> some View {
        content
            .scaleEffect(active && isHovered ? scale : 1)
            .animation(animations.animation(for: .hover), value: isHovered)
            .onHover { hovering in
                animations.perform(.hover) {
                    isHovered = hovering
                }
            }
    }
}

struct RadixPopupPanel<Content: View>: View {
    var size: RadixSize = .two
    var minWidth: CGFloat?
    private let content: Content

    @Environment(\.radixTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    init(
        size: RadixSize = .two,
        minWidth: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.size = size
        self.minWidth = minWidth
        self.content = content()
    }

    var body: some View {
        let radius = theme.radius(size == .one ? 3 : 4)

        RadixGlassEffectGroup(spacing: size == .one ? theme.space(1) : theme.space(2)) {
            VStack(alignment: .leading, spacing: 0) {
                content
            }
        }
        .padding(size == .one ? theme.space(1) : theme.space(2))
        .frame(minWidth: minWidth, alignment: .leading)
        .background(theme.solidPanel(colorScheme: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .stroke(theme.gray(6, alpha: true, colorScheme: colorScheme), lineWidth: 1)
        )
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.18 : 0.07), radius: 14, x: 0, y: 8)
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.08 : 0.03), radius: 1, x: 0, y: 1)
    }
}

@MainActor
final class RadixDismissalMonitor {
    private var eventMonitor: Any?
    private var deactivationObserver: NSObjectProtocol?
    private weak var anchor: NSView?
    private weak var allowedWindow: NSWindow?
    private var onDismiss: (@MainActor () -> Void)?

    /// <summary>
    /// Watches for app-level interactions that land outside the active layer, then asks its owner to dismiss.
    /// </summary>
    func update(
        anchor: NSView,
        allowedWindow: NSWindow? = nil,
        onDismiss: @escaping @MainActor () -> Void
    ) {
        self.anchor = anchor
        self.allowedWindow = allowedWindow
        self.onDismiss = onDismiss
        installEventMonitor()
        installDeactivationObserver()
    }

    func close() {
        if let eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
            self.eventMonitor = nil
        }

        if let deactivationObserver {
            NotificationCenter.default.removeObserver(deactivationObserver)
            self.deactivationObserver = nil
        }

        anchor = nil
        allowedWindow = nil
        onDismiss = nil
    }

    private func installEventMonitor() {
        guard eventMonitor == nil else { return }

        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown, .otherMouseDown, .keyDown]) { [weak self] event in
            guard let self else { return event }

            if event.type == .keyDown {
                guard event.keyCode == 53 else { return event }
                dismiss()
                return nil
            }

            if isEventInsideLayer(event) {
                return event
            }

            dismiss()
            return event
        }
    }

    private func installDeactivationObserver() {
        guard deactivationObserver == nil else { return }

        deactivationObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didResignActiveNotification,
            object: NSApp,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.dismiss()
            }
        }
    }

    private func dismiss() {
        onDismiss?()
    }

    private func isEventInsideLayer(_ event: NSEvent) -> Bool {
        if event.window === allowedWindow {
            return true
        }

        return isEventInsideAnchor(event)
    }

    private func isEventInsideAnchor(_ event: NSEvent) -> Bool {
        guard let anchor, event.window === anchor.window else { return false }

        let frame = anchor.convert(anchor.bounds, to: nil)
        return frame.contains(event.locationInWindow)
    }
}

enum RadixFloatingPanelPlacement {
    case belowAnchor(offset: CGFloat = 4)
    case rightOfAnchor(offset: CGFloat = 4)
    case point(CGPoint)
}

struct RadixFloatingPanel<PanelContent: View>: NSViewRepresentable {
    @Binding var isPresented: Bool
    var placement: RadixFloatingPanelPlacement
    private let panelContent: PanelContent

    @Environment(\.radixAnimations) private var animations

    init(
        isPresented: Binding<Bool>,
        placement: RadixFloatingPanelPlacement = .belowAnchor(),
        @ViewBuilder content: () -> PanelContent
    ) {
        self._isPresented = isPresented
        self.placement = placement
        self.panelContent = content()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        view.postsFrameChangedNotifications = true
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        context.coordinator.update(
            anchor: nsView,
            isPresented: isPresented,
            binding: $isPresented,
            placement: placement,
            animations: animations,
            content: panelContent
        )
    }

    static func dismantleNSView(_ nsView: NSView, coordinator: Coordinator) {
        coordinator.close()
    }

    @MainActor final class Coordinator {
        private var panel: NSPanel?
        private var hostingView: NSHostingView<PanelContent>?
        private let dismissalMonitor = RadixDismissalMonitor()
        private weak var anchor: NSView?

        func update(
            anchor: NSView,
            isPresented: Bool,
            binding: Binding<Bool>,
            placement: RadixFloatingPanelPlacement,
            animations: RadixAnimationSettings,
            content: PanelContent
        ) {
            self.anchor = anchor

            guard isPresented, anchor.window != nil else {
                close(animations: animations)
                return
            }

            let popup = panel ?? makePanel()
            let hostingView = hostingView ?? NSHostingView(rootView: content)
            self.hostingView = hostingView
            hostingView.rootView = content
            hostingView.layoutSubtreeIfNeeded()
            let fittingSize = hostingView.fittingSize
            let panelSize = NSSize(width: max(fittingSize.width, 1), height: max(fittingSize.height, 1))

            if popup.contentView !== hostingView {
                popup.contentView = hostingView
            }
            popup.setContentSize(panelSize)
            popup.setFrameOrigin(origin(for: anchor, placement: placement, size: panelSize))
            dismissalMonitor.update(anchor: anchor, allowedWindow: popup) {
                binding.wrappedValue = false
            }

            if panel == nil {
                panel = popup
                orderFront(popup, animations: animations)
            } else if !popup.isVisible {
                orderFront(popup, animations: animations)
            }
        }

        private func orderFront(_ popup: NSPanel, animations: RadixAnimationSettings) {
            guard animations.isEnabled else {
                popup.alphaValue = 1
                popup.orderFront(nil)
                return
            }

            popup.alphaValue = 0
            popup.orderFront(nil)

            NSAnimationContext.runAnimationGroup { context in
                context.duration = animations.spec(for: .popup).duration * max(animations.durationScale, 0)
                context.allowsImplicitAnimation = true
                popup.animator().alphaValue = 1
            }
        }

        private func makePanel() -> NSPanel {
            let popup = NSPanel(
                contentRect: .zero,
                styleMask: [.borderless, .nonactivatingPanel],
                backing: .buffered,
                defer: false
            )
            popup.isOpaque = false
            popup.backgroundColor = .clear
            popup.hasShadow = false
            popup.level = .popUpMenu
            popup.collectionBehavior = [.transient, .ignoresCycle]
            popup.hidesOnDeactivate = true
            return popup
        }

        private func origin(for anchor: NSView, placement: RadixFloatingPanelPlacement, size: NSSize) -> NSPoint {
            guard let window = anchor.window else { return .zero }

            let anchorFrame = window.convertToScreen(anchor.convert(anchor.bounds, to: nil))
            guard let visibleFrame = window.screen?.visibleFrame ?? NSScreen.main?.visibleFrame else {
                return fallbackOrigin(for: anchor, placement: placement, size: size)
            }

            let margin: CGFloat = 4
            let rawOrigin: NSPoint

            switch placement {
            case .belowAnchor(let offset):
                let belowY = anchorFrame.minY - size.height - offset
                let aboveY = anchorFrame.maxY + offset
                let preferredY = belowY >= visibleFrame.minY + margin || aboveY + size.height > visibleFrame.maxY - margin
                    ? belowY
                    : aboveY

                rawOrigin = NSPoint(x: anchorFrame.minX, y: preferredY)
            case .rightOfAnchor(let offset):
                let rightX = anchorFrame.maxX + offset
                let leftX = anchorFrame.minX - size.width - offset
                let preferredX = rightX + size.width <= visibleFrame.maxX - margin || leftX < visibleFrame.minX + margin
                    ? rightX
                    : leftX

                rawOrigin = NSPoint(x: preferredX, y: anchorFrame.maxY - size.height)
            case .point(let point):
                let pointInWindow = anchor.convert(NSRect(origin: point, size: .zero), to: nil)
                let pointRect = window.convertToScreen(pointInWindow)
                rawOrigin = NSPoint(x: pointRect.minX, y: pointRect.minY - size.height)
            }

            return clampedOrigin(rawOrigin, size: size, visibleFrame: visibleFrame, margin: margin)
        }

        private func fallbackOrigin(for anchor: NSView, placement: RadixFloatingPanelPlacement, size: NSSize) -> NSPoint {
            guard let window = anchor.window else { return .zero }

            let anchorFrame = window.convertToScreen(anchor.convert(anchor.bounds, to: nil))
            switch placement {
            case .belowAnchor(let offset):
                return NSPoint(x: anchorFrame.minX, y: anchorFrame.minY - size.height - offset)
            case .rightOfAnchor(let offset):
                return NSPoint(x: anchorFrame.maxX + offset, y: anchorFrame.maxY - size.height)
            case .point(let point):
                let pointInWindow = anchor.convert(NSRect(origin: point, size: .zero), to: nil)
                let pointRect = window.convertToScreen(pointInWindow)
                return NSPoint(x: pointRect.minX, y: pointRect.minY - size.height)
            }
        }

        private func clampedOrigin(_ origin: NSPoint, size: NSSize, visibleFrame: NSRect, margin: CGFloat) -> NSPoint {
            NSPoint(
                x: min(max(origin.x, visibleFrame.minX + margin), visibleFrame.maxX - size.width - margin),
                y: min(max(origin.y, visibleFrame.minY + margin), visibleFrame.maxY - size.height - margin)
            )
        }

        /// <summary>
        /// Tears down the panel immediately for cleanup, or fades it out for normal UI dismissals.
        /// </summary>
        func close(animations: RadixAnimationSettings? = nil) {
            dismissalMonitor.close()

            guard let popup = panel else {
                hostingView = nil
                return
            }

            panel = nil
            hostingView = nil

            guard let animations, animations.isEnabled, popup.isVisible else {
                popup.close()
                return
            }

            NSAnimationContext.runAnimationGroup { context in
                context.duration = animations.spec(for: .popup).duration * max(animations.durationScale, 0)
                context.allowsImplicitAnimation = true
                popup.animator().alphaValue = 0
            } completionHandler: {
                Task { @MainActor in
                    popup.close()
                }
            }
        }
    }
}

struct RadixSecondaryClickHost<Content: View>: NSViewRepresentable {
    var content: Content
    var onRightClick: (CGPoint) -> Void

    init(@ViewBuilder content: () -> Content, onRightClick: @escaping (CGPoint) -> Void) {
        self.content = content()
        self.onRightClick = onRightClick
    }

    func makeNSView(context: Context) -> RadixSecondaryClickHostingView<Content> {
        RadixSecondaryClickHostingView(rootView: content, onRightClick: onRightClick)
    }

    func updateNSView(_ nsView: RadixSecondaryClickHostingView<Content>, context: Context) {
        nsView.rootView = content
        nsView.onRightClick = onRightClick
    }
}

final class RadixSecondaryClickHostingView<Content: View>: NSHostingView<Content> {
    var onRightClick: (CGPoint) -> Void

    @MainActor @preconcurrency required init(rootView: Content) {
        self.onRightClick = { _ in }
        super.init(rootView: rootView)
    }

    init(rootView: Content, onRightClick: @escaping (CGPoint) -> Void) {
        self.onRightClick = onRightClick
        super.init(rootView: rootView)
    }

    @MainActor @preconcurrency required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func rightMouseDown(with event: NSEvent) {
        onRightClick(convert(event.locationInWindow, from: nil))
    }
}

public struct RadixButtonStyle: ButtonStyle {
    public var variant: RadixThemeVariant
    public var size: RadixSize
    public var color: RadixAccentColor?
    public var highContrast: Bool

    @Environment(\.radixTheme) private var theme
    @Environment(\.radixAnimations) private var animations
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.isEnabled) private var isEnabled

    public init(
        variant: RadixThemeVariant = .solid,
        size: RadixSize = .two,
        color: RadixAccentColor? = nil,
        highContrast: Bool = false
    ) {
        self.variant = variant
        self.size = size
        self.color = color
        self.highContrast = highContrast
    }

    public func makeBody(configuration: Configuration) -> some View {
        let palette = RadixComponentPalette(theme: theme, colorScheme: colorScheme, overrideColor: color)
        let metrics = RadixControlMetrics(size: size, theme: theme)
        let pressed = configuration.isPressed
        let shape = RoundedRectangle(cornerRadius: metrics.radius, style: .continuous)

        configuration.label
            .font(theme.font(size, weight: variant == .ghost ? .regular : .medium))
            .lineLimit(1)
            .foregroundStyle(foreground(palette: palette))
            .padding(.horizontal, horizontalPadding(metrics: metrics))
            .frame(height: metrics.height)
            .background(backgroundLayer(palette: palette, metrics: metrics, pressed: pressed))
            .radixInteractiveGlass(
                active: usesButtonGlass,
                enabled: isEnabled,
                tint: buttonGlassTint(palette: palette),
                in: shape
            )
            .overlay(border(palette: palette, metrics: metrics))
            .clipShape(shape)
            .contentShape(shape)
            .shadow(color: classicShadow(palette: palette), radius: variant == .classic ? 1 : 0, x: 0, y: 1)
            .opacity(isEnabled ? 1 : 0.58)
            .scaleEffect(pressed && isEnabled ? 0.985 : 1)
            .radixResponsiveHover(active: isEnabled && !pressed, scale: variant == .ghost ? 1.008 : 1.012)
            .animation(animations.animation(for: .press), value: pressed)
    }

    private func horizontalPadding(metrics: RadixControlMetrics) -> CGFloat {
        variant == .ghost ? max(theme.space(2), metrics.buttonHorizontalPadding - theme.space(1)) : metrics.buttonHorizontalPadding
    }

    private func foreground(palette: RadixComponentPalette) -> Color {
        switch variant {
        case .classic, .solid:
            highContrast ? palette.gray(1) : palette.contrast()
        case .soft, .surface, .outline, .ghost:
            highContrast ? palette.accent(12) : palette.accent(11, alpha: true)
        }
    }

    private func backgroundColor(palette: RadixComponentPalette, pressed: Bool) -> Color {
        guard isEnabled else {
            return variant == .ghost ? .clear : palette.gray(3, alpha: true)
        }

        switch variant {
        case .classic, .solid:
            if highContrast { return palette.accent(12).opacity(pressed ? 0.92 : 1) }
            return palette.accent(pressed ? 10 : 9)
        case .soft:
            return palette.accent(pressed ? 5 : 3, alpha: true)
        case .surface:
            return pressed ? palette.accent(3, alpha: true) : palette.surface()
        case .outline:
            return pressed ? palette.accent(3, alpha: true) : .clear
        case .ghost:
            return pressed ? palette.accent(4, alpha: true) : .clear
        }
    }

    @ViewBuilder
    private func backgroundLayer(palette: RadixComponentPalette, metrics: RadixControlMetrics, pressed: Bool) -> some View {
        let shape = RoundedRectangle(cornerRadius: metrics.radius, style: .continuous)

        shape
            .fill(backgroundColor(palette: palette, pressed: pressed))
            .overlay {
                if variant == .classic && isEnabled {
                    shape
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(colorScheme == .dark ? 0.18 : 0.22),
                                    Color.white.opacity(0.04),
                                    Color.black.opacity(colorScheme == .dark ? 0.22 : 0.08)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .blendMode(.overlay)
                }
            }
    }

    private var usesButtonGlass: Bool {
        isEnabled && variant != .ghost
    }

    private func buttonGlassTint(palette: RadixComponentPalette) -> Color? {
        switch variant {
        case .classic, .solid:
            highContrast ? palette.accent(12) : palette.accent(9)
        case .soft:
            palette.accent(9).opacity(0.2)
        case .surface, .outline, .ghost:
            nil
        }
    }

    @ViewBuilder
    private func border(palette: RadixComponentPalette, metrics: RadixControlMetrics) -> some View {
        switch variant {
        case .surface:
            RoundedRectangle(cornerRadius: metrics.radius, style: .continuous)
                .stroke(palette.accent(7, alpha: true), lineWidth: 1)
        case .outline:
            RoundedRectangle(cornerRadius: metrics.radius, style: .continuous)
                .stroke(highContrast ? palette.gray(11, alpha: true) : palette.accent(8, alpha: true), lineWidth: 1)
        case .classic:
            RoundedRectangle(cornerRadius: metrics.radius, style: .continuous)
                .stroke(colorScheme == .dark ? Color.white.opacity(0.12) : palette.gray(5, alpha: true), lineWidth: 1)
        default:
            EmptyView()
        }
    }

    private func classicShadow(palette: RadixComponentPalette) -> Color {
        variant == .classic ? palette.gray(12, alpha: true).opacity(colorScheme == .dark ? 0.18 : 0.06) : .clear
    }
}

struct RadixCardChrome: ViewModifier {
    var variant: RadixThemeVariant = .surface
    var color: RadixAccentColor?

    @Environment(\.radixTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        let palette = RadixComponentPalette(theme: theme, colorScheme: colorScheme, overrideColor: color)
        let radius = theme.radius(4)

        content
            .background(background(palette: palette))
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(border(palette: palette), lineWidth: 1)
            )
            .shadow(color: shadowColor(palette: palette), radius: variant == .classic ? 5 : 0, y: 1)
    }

    private func background(palette: RadixComponentPalette) -> Color {
        switch variant {
        case .classic:
            theme.panel(colorScheme: colorScheme)
        case .soft:
            palette.accent(2, alpha: true)
        case .solid:
            palette.accent(9)
        case .surface, .outline, .ghost:
            theme.panel(colorScheme: colorScheme)
        }
    }

    private func border(palette: RadixComponentPalette) -> Color {
        switch variant {
        case .solid:
            palette.accent(9)
        case .soft:
            palette.accent(6, alpha: true)
        default:
            palette.gray(6, alpha: true)
        }
    }

    private func shadowColor(palette: RadixComponentPalette) -> Color {
        palette.gray(12, alpha: true).opacity(0.05)
    }
}

extension View {
    func radixTextStyle(
        size: RadixSize,
        weight: RadixTextWeight,
        color: Color?,
        align: RadixTextAlign,
        theme: RadixThemeValues
    ) -> some View {
        self
            .font(theme.font(size, weight: weight))
            .lineSpacing(max(0, theme.lineHeight(size) - theme.fontSize(size)))
            .foregroundStyle(color ?? .primary)
            .multilineTextAlignment(align.alignment)
    }
}
