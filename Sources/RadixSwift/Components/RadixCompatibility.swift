import SwiftUI

public typealias RadixCheckboxGroup<Value: Hashable & Sendable> = RadixCheckboxCards<Value>
public typealias RadixDropdownMenuRoot<Label: View, Content: View> = RadixDropdownMenu<Label, Content>
public typealias RadixContextMenuRoot<MenuContent: View, Content: View> = RadixContextMenu<MenuContent, Content>
public typealias RadixPopoverRoot<Label: View, Content: View> = RadixPopover<Label, Content>
public typealias RadixHoverCardRoot<Label: View, Content: View> = RadixHoverCard<Label, Content>
public typealias RadixTooltipRoot<Content: View> = RadixTooltip<Content>

public struct RadixRadio<Label: View>: View {
    public var isSelected: Bool
    public var size: RadixSize
    public var color: RadixAccentColor?
    private let action: () -> Void
    private let label: Label

    @Environment(\.radixTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.isEnabled) private var isEnabled

    public init(
        isSelected: Bool,
        size: RadixSize = .two,
        color: RadixAccentColor? = nil,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.isSelected = isSelected
        self.size = size
        self.color = color
        self.action = action
        self.label = label()
    }

    public init(
        _ title: LocalizedStringKey,
        isSelected: Bool,
        size: RadixSize = .two,
        color: RadixAccentColor? = nil,
        action: @escaping () -> Void
    ) where Label == Text {
        self.init(isSelected: isSelected, size: size, color: color, action: action) {
            Text(title)
        }
    }

    public var body: some View {
        let palette = RadixComponentPalette(theme: theme, colorScheme: colorScheme, overrideColor: color)

        Button(action: action) {
            HStack(spacing: 8) {
                radioControl(palette: palette)

                label
                    .font(theme.font(.two))
                    .foregroundStyle(theme.gray(12, colorScheme: colorScheme))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .opacity(isEnabled ? 1 : 0.58)
    }

    private var controlSize: CGFloat {
        switch size {
        case .one: 14 * theme.scaling.factor
        case .two: 16 * theme.scaling.factor
        case .three: 20 * theme.scaling.factor
        default: 16 * theme.scaling.factor
        }
    }

    private var dotSize: CGFloat {
        max(controlSize * 0.42, 5)
    }

    private func radioControl(palette: RadixComponentPalette) -> some View {
        ZStack {
            Circle()
                .fill(isSelected ? palette.accent(9) : theme.surface(colorScheme: colorScheme, color: color))
                .radixInteractiveGlass(
                    enabled: isEnabled,
                    tint: isSelected ? palette.accent(9).opacity(0.22) : nil,
                    in: Circle()
                )
                .overlay(
                    Circle()
                        .stroke(isSelected ? .clear : theme.gray(7, alpha: true, colorScheme: colorScheme), lineWidth: 1)
                )

            if isSelected {
                Circle()
                    .fill(palette.contrast())
                    .frame(width: dotSize, height: dotSize)
            }
        }
        .frame(width: controlSize, height: controlSize)
    }
}

public struct RadixReset<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .buttonStyle(.plain)
            .textFieldStyle(.plain)
    }
}

public struct RadixThemePanel: View {
    @Environment(\.radixTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    public init() {}

    public var body: some View {
        RadixCard(size: .two) {
            VStack(alignment: .leading, spacing: theme.space(2)) {
                RadixText("Radix Theme", size: .two, weight: .medium)
                RadixDataList([
                    RadixDataListItem(label: "Appearance", value: theme.resolvedAppearance(for: colorScheme).rawValue),
                    RadixDataListItem(label: "Accent", value: theme.accentColor.rawValue),
                    RadixDataListItem(label: "Gray", value: theme.resolvedGrayColor().rawValue),
                    RadixDataListItem(label: "Radius", value: theme.radius.rawValue),
                    RadixDataListItem(label: "Scaling", value: theme.scaling.rawValue)
                ])
            }
        }
    }
}
