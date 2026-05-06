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
        let base: CGFloat
        switch step {
        case 1:
            base = 4
        case 2:
            base = 8
        case 3:
            base = 12
        case 4:
            base = 16
        case 5:
            base = 24
        case 6:
            base = 32
        case 7:
            base = 40
        case 8:
            base = 48
        case 9:
            base = 64
        default:
            base = CGFloat(step * 4)
        }
        return base * scaling.factor
    }

    public func fontSize(_ size: RadixSize) -> CGFloat {
        let base: CGFloat
        switch size {
        case .one:
            base = 12
        case .two:
            base = 14
        case .three:
            base = 16
        case .four:
            base = 18
        case .five:
            base = 20
        case .six:
            base = 24
        case .seven:
            base = 28
        case .eight:
            base = 35
        case .nine:
            base = 60
        }
        return base * scaling.factor
    }

    public func lineHeight(_ size: RadixSize) -> CGFloat {
        let base: CGFloat
        switch size {
        case .one:
            base = 16
        case .two:
            base = 20
        case .three:
            base = 24
        case .four:
            base = 26
        case .five:
            base = 28
        case .six:
            base = 30
        case .seven:
            base = 36
        case .eight:
            base = 40
        case .nine:
            base = 60
        }
        return base * scaling.factor
    }

    public func radius(_ step: Int) -> CGFloat {
        guard !radius.usesFullCapsule else { return 9999 }

        let base: CGFloat
        switch step {
        case 1:
            base = 3
        case 2:
            base = 4
        case 3:
            base = 6
        case 4:
            base = 8
        case 5:
            base = 12
        case 6:
            base = 16
        default:
            base = 6
        }
        return base * scaling.factor * radius.factor
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
