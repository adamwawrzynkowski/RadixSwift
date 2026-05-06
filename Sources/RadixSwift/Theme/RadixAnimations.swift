import SwiftUI

public enum RadixAnimationCurve: String, CaseIterable, Sendable {
    case linear
    case easeIn
    case easeOut
    case easeInOut
    case spring
    case interactiveSpring

    func animation(duration: Double) -> Animation {
        let duration = max(duration, 0)

        switch self {
        case .linear:
            return .linear(duration: duration)
        case .easeIn:
            return .easeIn(duration: duration)
        case .easeOut:
            return .easeOut(duration: duration)
        case .easeInOut:
            return .easeInOut(duration: duration)
        case .spring:
            return .spring(response: duration, dampingFraction: 0.88, blendDuration: min(duration * 0.25, 0.08))
        case .interactiveSpring:
            return .interactiveSpring(response: duration, dampingFraction: 0.9, blendDuration: min(duration * 0.25, 0.08))
        }
    }
}

public struct RadixAnimationSpec: Equatable, Sendable {
    public var duration: Double
    public var delay: Double
    public var curve: RadixAnimationCurve

    public init(
        duration: Double,
        delay: Double = 0,
        curve: RadixAnimationCurve = .easeOut
    ) {
        self.duration = duration
        self.delay = delay
        self.curve = curve
    }

    func animation(durationScale: Double) -> Animation {
        let scaledDuration = max(duration * max(durationScale, 0), 0)
        let scaledDelay = max(delay * max(durationScale, 0), 0)
        let animation = curve.animation(duration: scaledDuration)
        return scaledDelay > 0 ? animation.delay(scaledDelay) : animation
    }
}

public enum RadixAnimationRole: String, CaseIterable, Sendable {
    case hover
    case press
    case toggle
    case popup
    case dialog
    case tooltip
    case disclosure
    case presence
    case spinner
}

public struct RadixAnimationSettings: Equatable, Sendable {
    public var isEnabled: Bool
    public var durationScale: Double
    public var hover: RadixAnimationSpec
    public var press: RadixAnimationSpec
    public var toggle: RadixAnimationSpec
    public var popup: RadixAnimationSpec
    public var dialog: RadixAnimationSpec
    public var tooltip: RadixAnimationSpec
    public var disclosure: RadixAnimationSpec
    public var presence: RadixAnimationSpec
    public var spinner: RadixAnimationSpec

    public init(
        isEnabled: Bool = true,
        durationScale: Double = 1,
        hover: RadixAnimationSpec = RadixAnimationSpec(duration: 0.16, curve: .interactiveSpring),
        press: RadixAnimationSpec = RadixAnimationSpec(duration: 0.1, curve: .interactiveSpring),
        toggle: RadixAnimationSpec = RadixAnimationSpec(duration: 0.22, curve: .spring),
        popup: RadixAnimationSpec = RadixAnimationSpec(duration: 0.22, curve: .spring),
        dialog: RadixAnimationSpec = RadixAnimationSpec(duration: 0.26, curve: .spring),
        tooltip: RadixAnimationSpec = RadixAnimationSpec(duration: 0.16, curve: .interactiveSpring),
        disclosure: RadixAnimationSpec = RadixAnimationSpec(duration: 0.22, curve: .spring),
        presence: RadixAnimationSpec = RadixAnimationSpec(duration: 0.2, curve: .spring),
        spinner: RadixAnimationSpec = RadixAnimationSpec(duration: 0.8, curve: .linear)
    ) {
        self.isEnabled = isEnabled
        self.durationScale = durationScale
        self.hover = hover
        self.press = press
        self.toggle = toggle
        self.popup = popup
        self.dialog = dialog
        self.tooltip = tooltip
        self.disclosure = disclosure
        self.presence = presence
        self.spinner = spinner
    }

    public static let `default` = RadixAnimationSettings()
    public static let none = RadixAnimationSettings(isEnabled: false)
    public static let slow = RadixAnimationSettings(durationScale: 1.6)

    public func spec(for role: RadixAnimationRole) -> RadixAnimationSpec {
        switch role {
        case .hover:
            hover
        case .press:
            press
        case .toggle:
            toggle
        case .popup:
            popup
        case .dialog:
            dialog
        case .tooltip:
            tooltip
        case .disclosure:
            disclosure
        case .presence:
            presence
        case .spinner:
            spinner
        }
    }

    public func animation(for role: RadixAnimationRole) -> Animation? {
        guard isEnabled else { return nil }
        return spec(for: role).animation(durationScale: durationScale)
    }

    public func repeatingAnimation(for role: RadixAnimationRole, autoreverses: Bool = false) -> Animation? {
        guard isEnabled else { return nil }
        return spec(for: role)
            .animation(durationScale: durationScale)
            .repeatForever(autoreverses: autoreverses)
    }

    public func perform(_ role: RadixAnimationRole, updates: () -> Void) {
        guard let animation = animation(for: role) else {
            updates()
            return
        }

        withAnimation(animation) {
            updates()
        }
    }

    public func transition(for role: RadixAnimationRole) -> AnyTransition {
        guard isEnabled else { return .identity }

        switch role {
        case .dialog:
            return .scale(scale: 0.96, anchor: .center).combined(with: .opacity)
        case .popup:
            return .scale(scale: 0.96, anchor: .top).combined(with: .opacity)
        case .tooltip:
            return .scale(scale: 0.96, anchor: .bottom).combined(with: .opacity)
        case .disclosure:
            return .opacity.combined(with: .move(edge: .top))
        case .presence:
            return .opacity.combined(with: .scale(scale: 0.98))
        default:
            return .opacity
        }
    }
}

private struct RadixAnimationSettingsKey: EnvironmentKey {
    static let defaultValue = RadixAnimationSettings.default
}

public extension EnvironmentValues {
    var radixAnimations: RadixAnimationSettings {
        get { self[RadixAnimationSettingsKey.self] }
        set { self[RadixAnimationSettingsKey.self] = newValue }
    }
}

public extension View {
    func radixAnimations(_ settings: RadixAnimationSettings) -> some View {
        environment(\.radixAnimations, settings)
    }
}
