import SwiftUI

public enum RadixAppearance: String, CaseIterable, Sendable {
    case inherit
    case light
    case dark
}

public enum RadixResolvedAppearance: String, CaseIterable, Sendable {
    case light
    case dark
}

public enum RadixPanelBackground: String, CaseIterable, Sendable {
    case solid
    case translucent
}

public enum RadixScaling: String, CaseIterable, Sendable {
    case xSmall = "90%"
    case small = "95%"
    case normal = "100%"
    case large = "105%"
    case xLarge = "110%"

    public var factor: CGFloat {
        switch self {
        case .xSmall: 0.9
        case .small: 0.95
        case .normal: 1
        case .large: 1.05
        case .xLarge: 1.1
        }
    }
}

public enum RadixRadius: String, CaseIterable, Sendable {
    case none
    case small
    case medium
    case large
    case full

    public var factor: CGFloat {
        switch self {
        case .none: 0
        case .small: 0.75
        case .medium: 1
        case .large: 1.5
        case .full: 1.5
        }
    }

    public var usesFullCapsule: Bool {
        self == .full
    }
}

public enum RadixAccentColor: String, CaseIterable, Identifiable, Sendable {
    case gray
    case gold
    case bronze
    case brown
    case yellow
    case amber
    case orange
    case tomato
    case red
    case ruby
    case crimson
    case pink
    case plum
    case purple
    case violet
    case iris
    case indigo
    case blue
    case cyan
    case teal
    case jade
    case green
    case grass
    case lime
    case mint
    case sky

    public var id: String { rawValue }
}

public enum RadixGrayColor: String, CaseIterable, Identifiable, Sendable {
    case auto
    case gray
    case mauve
    case slate
    case sage
    case olive
    case sand

    public var id: String { rawValue }
}

public enum RadixSize: Int, CaseIterable, Identifiable, Sendable {
    case one = 1
    case two = 2
    case three = 3
    case four = 4
    case five = 5
    case six = 6
    case seven = 7
    case eight = 8
    case nine = 9

    public var id: Int { rawValue }
}

public enum RadixThemeVariant: String, CaseIterable, Sendable {
    case classic
    case solid
    case soft
    case surface
    case outline
    case ghost
}

public enum RadixTextWeight: String, CaseIterable, Sendable {
    case light
    case regular
    case medium
    case bold

    public var fontWeight: Font.Weight {
        switch self {
        case .light: .light
        case .regular: .regular
        case .medium: .medium
        case .bold: .bold
        }
    }
}

public enum RadixTextAlign: String, CaseIterable, Sendable {
    case left
    case center
    case right

    public var alignment: TextAlignment {
        switch self {
        case .left: .leading
        case .center: .center
        case .right: .trailing
        }
    }
}

public enum RadixOrientation: String, CaseIterable, Sendable {
    case horizontal
    case vertical
}

public enum RadixInsetSide: String, CaseIterable, Sendable {
    case top
    case right
    case bottom
    case left
    case x
    case y
    case all
}
