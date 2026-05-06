import AppKit
import SwiftUI

public enum RadixDirection: String, CaseIterable, Sendable {
    case ltr
    case rtl

    public var layoutDirection: LayoutDirection {
        self == .rtl ? .rightToLeft : .leftToRight
    }
}

private struct RadixDirectionKey: EnvironmentKey {
    static let defaultValue: RadixDirection = .ltr
}

public extension EnvironmentValues {
    var radixDirection: RadixDirection {
        get { self[RadixDirectionKey.self] }
        set { self[RadixDirectionKey.self] = newValue }
    }
}

public struct RadixDirectionProvider<Content: View>: View {
    public var direction: RadixDirection
    private let content: Content

    public init(_ direction: RadixDirection, @ViewBuilder content: () -> Content) {
        self.direction = direction
        self.content = content()
    }

    public var body: some View {
        content
            .environment(\.radixDirection, direction)
            .environment(\.layoutDirection, direction.layoutDirection)
    }
}

public struct RadixLabel<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public init(_ text: LocalizedStringKey) where Content == Text {
        self.init {
            Text(text)
        }
    }

    public var body: some View {
        content.accessibilityAddTraits(.isStaticText)
    }
}

public struct RadixForm<Content: View>: View {
    private let content: Content

    @Environment(\.radixTheme) private var theme

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.space(3)) {
            content
        }
    }
}

public struct RadixArrow: Shape {
    public init() {}

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

public struct RadixPresence<Content: View>: View {
    public var isPresent: Bool
    private let content: Content

    @Environment(\.radixAnimations) private var animations

    public init(_ isPresent: Bool, @ViewBuilder content: () -> Content) {
        self.isPresent = isPresent
        self.content = content()
    }

    public var body: some View {
        Group {
            if isPresent {
                content
                    .transition(animations.transition(for: .presence))
            }
        }
        .animation(animations.animation(for: .presence), value: isPresent)
    }
}

public struct RadixFocusScope<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content.focusSection()
    }
}

public struct RadixFocusGuards<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
    }
}

public struct RadixDismissableLayer<Content: View>: View {
    public var onDismiss: () -> Void
    private let content: Content

    public init(onDismiss: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.onDismiss = onDismiss
        self.content = content()
    }

    public var body: some View {
        content.onExitCommand(perform: onDismiss)
    }
}

public struct RadixRovingFocusGroup<Content: View>: View {
    public var orientation: RadixOrientation
    private let content: Content

    public init(orientation: RadixOrientation = .horizontal, @ViewBuilder content: () -> Content) {
        self.orientation = orientation
        self.content = content()
    }

    public var body: some View {
        if orientation == .horizontal {
            HStack {
                content
            }
        } else {
            VStack {
                content
            }
        }
    }
}

public struct RadixCollection<Element: Identifiable & Sendable>: Sendable {
    public var elements: [Element]

    public init(_ elements: [Element] = []) {
        self.elements = elements
    }
}

public enum RadixAnnounce {
    @MainActor
    public static func polite(_ message: String) {
        announce(message, priority: NSAccessibilityPriorityLevel.medium.rawValue)
    }

    @MainActor
    public static func assertive(_ message: String) {
        announce(message, priority: NSAccessibilityPriorityLevel.high.rawValue)
    }

    /// <summary>
    /// Sends a native accessibility announcement, matching Radix's web announcer role without adding a visible view.
    /// </summary>
    @MainActor
    private static func announce(_ message: String, priority: Int) {
        NSAccessibility.post(
            element: NSApplication.shared,
            notification: .announcementRequested,
            userInfo: [
                .announcement: message,
                .priority: NSNumber(value: priority)
            ]
        )
    }
}
