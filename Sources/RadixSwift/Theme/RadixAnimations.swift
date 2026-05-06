import SwiftUI

public enum RadixAnimationCurve: String, CaseIterable, Sendable {
    case linear
    case easeIn
    case easeOut
    case easeInOut

    func animation(duration: Double) -> Animation {
        switch self {
        case .linear:
            .linear(duration: duration)
        case .easeIn:
            .easeIn(duration: duration)
        case .easeOut:
            .easeOut(duration: duration)
        case .easeInOut:
            .easeInOut(duration: duration)
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
        hover: RadixAnimationSpec = RadixAnimationSpec(duration: 0.12),
        press: RadixAnimationSpec = RadixAnimationSpec(duration: 0.08),
        toggle: RadixAnimationSpec = RadixAnimationSpec(duration: 0.14),
        popup: RadixAnimationSpec = RadixAnimationSpec(duration: 0.16),
        dialog: RadixAnimationSpec = RadixAnimationSpec(duration: 0.16),
        tooltip: RadixAnimationSpec = RadixAnimationSpec(duration: 0.12),
        disclosure: RadixAnimationSpec = RadixAnimationSpec(duration: 0.14),
        presence: RadixAnimationSpec = RadixAnimationSpec(duration: 0.16),
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

    public func transition(for role: RadixAnimationRole) -> AnyTransition {
        guard isEnabled else { return .identity }

        switch role {
        case .dialog, .popup:
            return .scale(scale: 0.97).combined(with: .opacity)
        case .tooltip:
            return .scale(scale: 0.98).combined(with: .opacity)
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
