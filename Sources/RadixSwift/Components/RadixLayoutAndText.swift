import SwiftUI

public struct RadixBox<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
    }
}

public struct RadixFlex<Content: View>: View {
    public var direction: RadixOrientation
    public var gap: Int
    public var alignment: Alignment
    private let content: Content

    @Environment(\.radixTheme) private var theme

    public init(
        direction: RadixOrientation = .horizontal,
        gap: Int = 3,
        alignment: Alignment = .center,
        @ViewBuilder content: () -> Content
    ) {
        self.direction = direction
        self.gap = gap
        self.alignment = alignment
        self.content = content()
    }

    public var body: some View {
        if direction == .horizontal {
            HStack(alignment: verticalAlignment, spacing: theme.space(gap)) {
                content
            }
        } else {
            VStack(alignment: horizontalAlignment, spacing: theme.space(gap)) {
                content
            }
        }
    }

    private var verticalAlignment: VerticalAlignment {
        switch alignment {
        case .topLeading, .top, .topTrailing: .top
        case .bottomLeading, .bottom, .bottomTrailing: .bottom
        default: .center
        }
    }

    private var horizontalAlignment: HorizontalAlignment {
        switch alignment {
        case .leading, .topLeading, .bottomLeading: .leading
        case .trailing, .topTrailing, .bottomTrailing: .trailing
        default: .center
        }
    }
}

public struct RadixGrid<Content: View>: View {
    public var columns: Int
    public var gap: Int
    private let content: Content

    @Environment(\.radixTheme) private var theme

    public init(
        columns: Int = 2,
        gap: Int = 3,
        @ViewBuilder content: () -> Content
    ) {
        self.columns = max(1, columns)
        self.gap = gap
        self.content = content()
    }

    public var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: theme.space(gap)), count: columns),
            spacing: theme.space(gap)
        ) {
            content
        }
    }
}

public struct RadixContainer<Content: View>: View {
    public var size: RadixSize
    private let content: Content

    public init(size: RadixSize = .four, @ViewBuilder content: () -> Content) {
        self.size = size
        self.content = content()
    }

    public var body: some View {
        content
            .frame(maxWidth: maxWidth)
            .frame(maxWidth: .infinity)
    }

    private var maxWidth: CGFloat {
        switch size {
        case .one: 448
        case .two: 688
        case .three: 880
        case .four: 1136
        default: 1136
        }
    }
}

public struct RadixSection<Content: View>: View {
    public var size: RadixSize
    private let content: Content

    @Environment(\.radixTheme) private var theme

    public init(size: RadixSize = .three, @ViewBuilder content: () -> Content) {
        self.size = size
        self.content = content()
    }

    public var body: some View {
        content
            .padding(.vertical, theme.space(min(max(size.rawValue + 2, 3), 9)))
    }
}

public struct RadixInset<Content: View>: View {
    public var side: RadixInsetSide
    public var amount: Int
    private let content: Content

    @Environment(\.radixTheme) private var theme

    public init(
        side: RadixInsetSide = .all,
        amount: Int = 3,
        @ViewBuilder content: () -> Content
    ) {
        self.side = side
        self.amount = amount
        self.content = content()
    }

    public var body: some View {
        content.padding(edges, theme.space(amount))
    }

    private var edges: Edge.Set {
        switch side {
        case .top: .top
        case .right: .trailing
        case .bottom: .bottom
        case .left: .leading
        case .x: .horizontal
        case .y: .vertical
        case .all: .all
        }
    }
}

public struct RadixText<Content: View>: View {
    public var size: RadixSize
    public var weight: RadixTextWeight
    public var color: Color?
    public var align: RadixTextAlign
    private let content: Content

    @Environment(\.radixTheme) private var theme

    public init(
        size: RadixSize = .three,
        weight: RadixTextWeight = .regular,
        color: Color? = nil,
        align: RadixTextAlign = .left,
        @ViewBuilder content: () -> Content
    ) {
        self.size = size
        self.weight = weight
        self.color = color
        self.align = align
        self.content = content()
    }

    public init(
        _ text: LocalizedStringKey,
        size: RadixSize = .three,
        weight: RadixTextWeight = .regular,
        color: Color? = nil,
        align: RadixTextAlign = .left
    ) where Content == Text {
        self.init(size: size, weight: weight, color: color, align: align) {
            Text(text)
        }
    }

    public var body: some View {
        content.radixTextStyle(size: size, weight: weight, color: color, align: align, theme: theme)
    }
}

public struct RadixHeading<Content: View>: View {
    public var size: RadixSize
    public var weight: RadixTextWeight
    public var align: RadixTextAlign
    private let content: Content

    @Environment(\.radixTheme) private var theme

    public init(
        size: RadixSize = .six,
        weight: RadixTextWeight = .bold,
        align: RadixTextAlign = .left,
        @ViewBuilder content: () -> Content
    ) {
        self.size = size
        self.weight = weight
        self.align = align
        self.content = content()
    }

    public init(
        _ text: LocalizedStringKey,
        size: RadixSize = .six,
        weight: RadixTextWeight = .bold,
        align: RadixTextAlign = .left
    ) where Content == Text {
        self.init(size: size, weight: weight, align: align) {
            Text(text)
        }
    }

    public var body: some View {
        content
            .radixTextStyle(size: size, weight: weight, color: nil, align: align, theme: theme)
            .accessibilityAddTraits(.isHeader)
    }
}

public struct RadixStrong<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content.fontWeight(.bold)
    }
}

public struct RadixEm<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content.italic()
    }
}

public struct RadixQuote<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text("“")
            content
            Text("”")
        }
        .italic()
    }
}

public struct RadixBlockquote<Content: View>: View {
    private let content: Content

    @Environment(\.radixTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .padding(.leading, theme.space(4))
            .overlay(alignment: .leading) {
                Rectangle()
                    .fill(theme.gray(6, colorScheme: colorScheme))
                    .frame(width: 3)
            }
    }
}

public struct RadixCode: View {
    public var text: String
    public var size: RadixSize

    @Environment(\.radixTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    public init(_ text: String, size: RadixSize = .two) {
        self.text = text
        self.size = size
    }

    public var body: some View {
        Text(text)
            .font(.system(size: theme.fontSize(size) * 0.95, weight: .regular, design: .monospaced))
            .padding(.horizontal, 4)
            .padding(.vertical, 1)
            .background(theme.gray(3, alpha: true, colorScheme: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: theme.radius(1), style: .continuous))
    }
}

public struct RadixKbd: View {
    public var text: String

    @Environment(\.radixTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    public init(_ text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .font(.system(size: theme.fontSize(.one), weight: .medium, design: .monospaced))
            .padding(.horizontal, 6)
            .frame(minHeight: 20)
            .background(theme.gray(2, colorScheme: colorScheme))
            .overlay(
                RoundedRectangle(cornerRadius: theme.radius(2), style: .continuous)
                    .stroke(theme.gray(7, alpha: true, colorScheme: colorScheme), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: theme.radius(2), style: .continuous))
    }
}

public struct RadixLink: View {
    public var title: LocalizedStringKey
    public var destination: URL

    @Environment(\.radixTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    public init(_ title: LocalizedStringKey, destination: URL) {
        self.title = title
        self.destination = destination
    }

    public var body: some View {
        Link(title, destination: destination)
            .foregroundStyle(theme.accent(11, colorScheme: colorScheme))
    }
}

public struct RadixVisuallyHidden<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .frame(width: 1, height: 1)
            .clipped()
            .opacity(0.001)
            .accessibilityHidden(false)
    }
}

public struct RadixAccessibleIcon<Content: View>: View {
    public var label: LocalizedStringKey
    private let content: Content

    public init(label: LocalizedStringKey, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }

    public var body: some View {
        content.accessibilityLabel(label)
    }
}
