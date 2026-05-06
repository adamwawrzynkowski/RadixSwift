import SwiftUI

public struct RadixThemeValues: Equatable, Sendable {
    public var appearance: RadixAppearance
    public var accentColor: RadixAccentColor
    public var grayColor: RadixGrayColor
    public var panelBackground: RadixPanelBackground
    public var radius: RadixRadius
    public var scaling: RadixScaling

    public init(
        appearance: RadixAppearance = .inherit,
        accentColor: RadixAccentColor = .indigo,
        grayColor: RadixGrayColor = .auto,
        panelBackground: RadixPanelBackground = .translucent,
        radius: RadixRadius = .medium,
        scaling: RadixScaling = .normal
    ) {
        self.appearance = appearance
        self.accentColor = accentColor
        self.grayColor = grayColor
        self.panelBackground = panelBackground
        self.radius = radius
        self.scaling = scaling
    }

    public func resolvedAppearance(for colorScheme: ColorScheme) -> RadixResolvedAppearance {
        switch appearance {
        case .light:
            .light
        case .dark:
            .dark
        case .inherit:
            colorScheme == .dark ? .dark : .light
        }
    }

    public func resolvedGrayColor() -> RadixGrayColor {
        grayColor == .auto
            ? RadixColorCatalog.shared.matchingGrayColor(for: accentColor)
            : grayColor
    }

    public func accent(_ step: Int, alpha: Bool = false, colorScheme: ColorScheme) -> Color {
        RadixColorCatalog.shared.color(
            scale: accentColor.rawValue,
            step: step,
            appearance: resolvedAppearance(for: colorScheme),
            alpha: alpha
        )
    }

    public func gray(_ step: Int, alpha: Bool = false, colorScheme: ColorScheme) -> Color {
        RadixColorCatalog.shared.color(
            scale: resolvedGrayColor().rawValue,
            step: step,
            appearance: resolvedAppearance(for: colorScheme),
            alpha: alpha
        )
    }

    public func background(colorScheme: ColorScheme) -> Color {
        let appearance = resolvedAppearance(for: colorScheme)
        return appearance == .dark ? gray(1, colorScheme: colorScheme) : .white
    }

    public func overlay(colorScheme: ColorScheme) -> Color {
        resolvedAppearance(for: colorScheme) == .dark
            ? RadixColorCatalog.shared.blackAlpha(8)
            : RadixColorCatalog.shared.blackAlpha(6)
    }

    public func panel(colorScheme: ColorScheme) -> Color {
        switch (panelBackground, resolvedAppearance(for: colorScheme)) {
        case (.solid, .light):
            .white
        case (.solid, .dark):
            gray(2, colorScheme: colorScheme)
        case (.translucent, .light):
            Color.white.opacity(0.7)
        case (.translucent, .dark):
            gray(2, alpha: true, colorScheme: colorScheme)
        }
    }

    public func surface(colorScheme: ColorScheme, color: RadixAccentColor? = nil) -> Color {
        RadixColorCatalog.shared.themeSurface(
            for: color ?? accentColor,
            appearance: resolvedAppearance(for: colorScheme)
        )
    }

    public func contrast(color: RadixAccentColor? = nil) -> Color {
        RadixColorCatalog.shared.themeContrast(for: color ?? accentColor)
    }

    public func space(_ step: Int) -> CGFloat {
        let values: [Int: CGFloat] = [
            1: 4,
            2: 8,
            3: 12,
            4: 16,
            5: 24,
            6: 32,
            7: 40,
            8: 48,
            9: 64
        ]
        return (values[step] ?? CGFloat(step * 4)) * scaling.factor
    }

    public func fontSize(_ size: RadixSize) -> CGFloat {
        let values: [RadixSize: CGFloat] = [
            .one: 12,
            .two: 14,
            .three: 16,
            .four: 18,
            .five: 20,
            .six: 24,
            .seven: 28,
            .eight: 35,
            .nine: 60
        ]
        return (values[size] ?? 16) * scaling.factor
    }

    public func lineHeight(_ size: RadixSize) -> CGFloat {
        let values: [RadixSize: CGFloat] = [
            .one: 16,
            .two: 20,
            .three: 24,
            .four: 26,
            .five: 28,
            .six: 30,
            .seven: 36,
            .eight: 40,
            .nine: 60
        ]
        return (values[size] ?? 24) * scaling.factor
    }

    public func radius(_ step: Int) -> CGFloat {
        guard !radius.usesFullCapsule else { return 9999 }

        let values: [Int: CGFloat] = [
            1: 3,
            2: 4,
            3: 6,
            4: 8,
            5: 12,
            6: 16
        ]
        return (values[step] ?? 6) * scaling.factor * radius.factor
    }

    public func font(_ size: RadixSize, weight: RadixTextWeight = .regular) -> Font {
        .system(size: fontSize(size), weight: weight.fontWeight)
    }
}

private struct RadixThemeValuesKey: EnvironmentKey {
    static let defaultValue = RadixThemeValues()
}

public extension EnvironmentValues {
    var radixTheme: RadixThemeValues {
        get { self[RadixThemeValuesKey.self] }
        set { self[RadixThemeValuesKey.self] = newValue }
    }
}

public struct RadixTheme<Content: View>: View {
    private let values: RadixThemeValues
    private let animations: RadixAnimationSettings
    private let hasBackground: Bool
    private let content: Content

    @Environment(\.colorScheme) private var colorScheme

    public init(
        appearance: RadixAppearance = .inherit,
        accentColor: RadixAccentColor = .indigo,
        grayColor: RadixGrayColor = .auto,
        panelBackground: RadixPanelBackground = .translucent,
        radius: RadixRadius = .medium,
        scaling: RadixScaling = .normal,
        animations: RadixAnimationSettings = .default,
        hasBackground: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.values = RadixThemeValues(
            appearance: appearance,
            accentColor: accentColor,
            grayColor: grayColor,
            panelBackground: panelBackground,
            radius: radius,
            scaling: scaling
        )
        self.animations = animations
        self.hasBackground = hasBackground
        self.content = content()
    }

    public var body: some View {
        content
            .environment(\.radixTheme, values)
            .environment(\.radixAnimations, animations)
            .background(hasBackground ? values.background(colorScheme: colorScheme) : Color.clear)
            .preferredColorScheme(preferredColorScheme)
    }

    private var preferredColorScheme: ColorScheme? {
        switch values.appearance {
        case .inherit:
            nil
        case .light:
            .light
        case .dark:
            .dark
        }
    }
}
