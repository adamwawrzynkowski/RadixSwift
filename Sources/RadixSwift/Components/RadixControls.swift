import SwiftUI

public struct RadixButton<Label: View>: View {
    public var variant: RadixThemeVariant
    public var size: RadixSize
    public var color: RadixAccentColor?
    public var highContrast: Bool
    private let action: () -> Void
    private let label: Label

    public init(
        variant: RadixThemeVariant = .solid,
        size: RadixSize = .two,
        color: RadixAccentColor? = nil,
        highContrast: Bool = false,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.variant = variant
        self.size = size
        self.color = color
        self.highContrast = highContrast
        self.action = action
        self.label = label()
    }

    public init(
        _ title: LocalizedStringKey,
        variant: RadixThemeVariant = .solid,
        size: RadixSize = .two,
        color: RadixAccentColor? = nil,
        highContrast: Bool = false,
        action: @escaping () -> Void
    ) where Label == Text {
        self.init(variant: variant, size: size, color: color, highContrast: highContrast, action: action) {
            Text(title)
        }
    }

    public var body: some View {
        Button(action: action) {
            label
        }
        .buttonStyle(RadixButtonStyle(variant: variant, size: size, color: color, highContrast: highContrast))
    }
}

public struct RadixIconButton: View {
    public var icon: RadixIconName
    public var label: LocalizedStringKey
    public var variant: RadixThemeVariant
    public var size: RadixSize
    public var color: RadixAccentColor?
    private let action: () -> Void

    public init(
        icon: RadixIconName,
        label: LocalizedStringKey,
        variant: RadixThemeVariant = .solid,
        size: RadixSize = .two,
        color: RadixAccentColor? = nil,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.label = label
        self.variant = variant
        self.size = size
        self.color = color
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            RadixIcon(icon, size: iconSize)
                .accessibilityHidden(true)
        }
        .buttonStyle(RadixButtonStyle(variant: variant, size: size, color: color))
        .accessibilityLabel(label)
    }

    private var iconSize: CGFloat {
        size.rawValue <= 2 ? 15 : 18
    }
}

public struct RadixBadge<Content: View>: View {
    public var variant: RadixThemeVariant
    public var color: RadixAccentColor?
    private let content: Content

    @Environment(\.radixTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    public init(
        variant: RadixThemeVariant = .soft,
        color: RadixAccentColor? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.variant = variant
        self.color = color
        self.content = content()
    }

    public init(
        _ text: LocalizedStringKey,
        variant: RadixThemeVariant = .soft,
        color: RadixAccentColor? = nil
    ) where Content == Text {
        self.init(variant: variant, color: color) {
            Text(text)
        }
    }

    public var body: some View {
        let palette = RadixComponentPalette(theme: theme, colorScheme: colorScheme, overrideColor: color)

        content
            .font(theme.font(.one, weight: .medium))
            .foregroundStyle(foreground(palette: palette))
            .padding(.horizontal, 6)
            .frame(minHeight: 20)
            .background(background(palette: palette))
            .overlay(
                RoundedRectangle(cornerRadius: theme.radius(2), style: .continuous)
                    .stroke(border(palette: palette), lineWidth: variant == .outline || variant == .surface ? 1 : 0)
            )
            .clipShape(RoundedRectangle(cornerRadius: theme.radius(2), style: .continuous))
    }

    private func foreground(palette: RadixComponentPalette) -> Color {
        switch variant {
        case .solid, .classic:
            palette.contrast()
        default:
            palette.accent(11, alpha: true)
        }
    }

    private func background(palette: RadixComponentPalette) -> Color {
        switch variant {
        case .solid, .classic:
            palette.accent(9)
        case .soft:
            palette.accent(3, alpha: true)
        case .surface:
            palette.surface()
        case .outline, .ghost:
            .clear
        }
    }

    private func border(palette: RadixComponentPalette) -> Color {
        variant == .outline ? palette.accent(8, alpha: true) : palette.accent(7, alpha: true)
    }
}

public struct RadixCard<Content: View>: View {
    public var variant: RadixThemeVariant
    public var size: RadixSize
    private let content: Content

    @Environment(\.radixTheme) private var theme

    public init(
        variant: RadixThemeVariant = .surface,
        size: RadixSize = .three,
        @ViewBuilder content: () -> Content
    ) {
        self.variant = variant
        self.size = size
        self.content = content()
    }

    public var body: some View {
        content
            .padding(theme.space(min(max(size.rawValue, 2), 5)))
            .modifier(RadixCardChrome(variant: variant))
    }
}

public struct RadixCallout<Content: View>: View {
    public var icon: RadixIconName?
    public var color: RadixAccentColor?
    private let content: Content

    @Environment(\.radixTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    public init(
        icon: RadixIconName? = .infoCircled,
        color: RadixAccentColor? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.icon = icon
        self.color = color
        self.content = content()
    }

    public var body: some View {
        let palette = RadixComponentPalette(theme: theme, colorScheme: colorScheme, overrideColor: color)

        HStack(alignment: .top, spacing: theme.space(2)) {
            if let icon {
                RadixIcon(icon)
                    .foregroundStyle(palette.accent(11, alpha: true))
                    .padding(.top, 2)
            }
            content
                .font(theme.font(.two))
                .foregroundStyle(palette.accent(12))
        }
        .padding(theme.space(3))
        .background(palette.accent(3, alpha: true))
        .clipShape(RoundedRectangle(cornerRadius: theme.radius(3), style: .continuous))
    }
}

public struct RadixAvatar: View {
    public var imageURL: URL?
    public var fallback: String
    public var size: CGFloat

    @Environment(\.radixTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    public init(imageURL: URL? = nil, fallback: String, size: CGFloat = 32) {
        self.imageURL = imageURL
        self.fallback = fallback
        self.size = size
    }

    public var body: some View {
        ZStack {
            Circle().fill(theme.gray(3, colorScheme: colorScheme))

            if let imageURL {
                AsyncImage(url: imageURL) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    fallbackText
                }
            } else {
                fallbackText
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    private var fallbackText: some View {
        Text(fallback)
            .font(.system(size: max(10, size * 0.36), weight: .medium))
            .foregroundStyle(theme.gray(11, colorScheme: colorScheme))
    }
}

public struct RadixSkeleton: View {
    public var width: CGFloat?
    public var height: CGFloat

    @Environment(\.radixTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    public init(width: CGFloat? = nil, height: CGFloat = 16) {
        self.width = width
        self.height = height
    }

    public var body: some View {
        RoundedRectangle(cornerRadius: theme.radius(2), style: .continuous)
            .fill(theme.gray(3, colorScheme: colorScheme))
            .frame(width: width, height: height)
            .redacted(reason: .placeholder)
    }
}

public struct RadixSpinner: View {
    public var size: CGFloat
    @State private var isAnimating = false

    @Environment(\.radixTheme) private var theme
    @Environment(\.radixAnimations) private var animations
    @Environment(\.colorScheme) private var colorScheme

    public init(size: CGFloat = 16) {
        self.size = size
    }

    public var body: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { index in
                Capsule()
                    .fill(theme.gray(11, alpha: true, colorScheme: colorScheme).opacity(0.28 + Double(index) * 0.09))
                    .frame(width: max(size * 0.12, 1.5), height: max(size * 0.32, 4))
                    .offset(y: -size * 0.32)
                    .rotationEffect(.degrees(Double(index) * 45))
            }
        }
            .frame(width: size, height: size)
            .rotationEffect(.degrees(isAnimating ? 360 : 0))
            .animation(animations.repeatingAnimation(for: .spinner), value: isAnimating)
            .onAppear { isAnimating = true }
            .onDisappear { isAnimating = false }
    }
}

public struct RadixSeparator: View {
    public var orientation: RadixOrientation

    @Environment(\.radixTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    public init(orientation: RadixOrientation = .horizontal) {
        self.orientation = orientation
    }

    public var body: some View {
        Rectangle()
            .fill(theme.gray(6, alpha: true, colorScheme: colorScheme))
            .frame(
                width: orientation == .vertical ? 1 : nil,
                height: orientation == .horizontal ? 1 : nil
            )
    }
}

public struct RadixProgress: View {
    public var value: Double
    public var total: Double
    public var color: RadixAccentColor?

    @Environment(\.radixTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    public init(value: Double, total: Double = 1, color: RadixAccentColor? = nil) {
        self.value = value
        self.total = total
        self.color = color
    }

    public var body: some View {
        let palette = RadixComponentPalette(theme: theme, colorScheme: colorScheme, overrideColor: color)
        let progress = total == 0 ? 0 : min(max(value / total, 0), 1)

        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(palette.accent(3, alpha: true))
                Capsule()
                    .fill(palette.accent(9))
                    .frame(width: proxy.size.width * progress)
            }
        }
        .frame(height: 8)
        .accessibilityValue(Text("\(Int(progress * 100)) percent"))
    }
}

public struct RadixCheckbox<Label: View>: View {
    @Binding private var isOn: Bool
    public var size: RadixSize
    public var variant: RadixThemeVariant
    public var color: RadixAccentColor?
    private let label: Label

    @Environment(\.radixTheme) private var theme
    @Environment(\.radixAnimations) private var animations
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.isEnabled) private var isEnabled

    public init(
        isOn: Binding<Bool>,
        size: RadixSize = .two,
        variant: RadixThemeVariant = .surface,
        color: RadixAccentColor? = nil,
        @ViewBuilder label: () -> Label
    ) {
        self._isOn = isOn
        self.size = size
        self.variant = variant
        self.color = color
        self.label = label()
    }

    public init(
        _ title: LocalizedStringKey,
        isOn: Binding<Bool>,
        size: RadixSize = .two,
        variant: RadixThemeVariant = .surface,
        color: RadixAccentColor? = nil
    ) where Label == Text {
        self.init(isOn: isOn, size: size, variant: variant, color: color) {
            Text(title)
        }
    }

    public var body: some View {
        let palette = RadixComponentPalette(theme: theme, colorScheme: colorScheme, overrideColor: color)

        Button {
            animations.perform(.toggle) {
                isOn.toggle()
            }
        } label: {
            HStack(spacing: theme.space(2)) {
                checkboxBox(palette: palette)
                label
                    .font(theme.font(.two))
                    .foregroundStyle(theme.gray(12, colorScheme: colorScheme))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .opacity(isEnabled ? 1 : 0.58)
        .radixResponsiveHover(active: isEnabled, scale: 1.006)
        .accessibilityValue(isOn ? Text("Checked") : Text("Unchecked"))
        .animation(animations.animation(for: .toggle), value: isOn)
    }

    private var boxSize: CGFloat {
        switch size {
        case .one: theme.space(4) * 0.875
        case .two: theme.space(4)
        case .three: theme.space(4) * 1.25
        default: theme.space(4)
        }
    }

    private var indicatorSize: CGFloat {
        switch size {
        case .one: 9 * theme.scaling.factor
        case .two: 10 * theme.scaling.factor
        case .three: 12 * theme.scaling.factor
        default: 10 * theme.scaling.factor
        }
    }

    private func checkboxBox(palette: RadixComponentPalette) -> some View {
        let radius = max(theme.radius(1) * boxSize / theme.space(4), 1)

        return ZStack {
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(checkboxBackground(palette: palette))
                .radixInteractiveGlass(
                    enabled: isEnabled,
                    tint: isOn ? palette.accent(9).opacity(0.22) : nil,
                    in: RoundedRectangle(cornerRadius: radius, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .stroke(checkboxBorder(palette: palette), lineWidth: isOn ? 0 : 1)
                )
                .shadow(color: variant == .classic && !isOn ? .black.opacity(0.07) : .clear, radius: 1, x: 0, y: 1)

            if isOn {
                RadixIcon(.check, size: indicatorSize)
                    .foregroundStyle(checkboxIndicator(palette: palette))
            }
        }
        .frame(width: boxSize, height: boxSize)
    }

    private func checkboxBackground(palette: RadixComponentPalette) -> Color {
        guard isEnabled else { return palette.gray(3, alpha: true) }

        if isOn {
            switch variant {
            case .soft:
                return palette.accent(5, alpha: true)
            case .classic, .solid, .surface, .outline, .ghost:
                return palette.accent(9)
            }
        }

        switch variant {
        case .soft:
            return palette.accent(3, alpha: true)
        case .classic, .surface, .outline, .ghost:
            return theme.surface(colorScheme: colorScheme, color: color)
        case .solid:
            return palette.gray(3, alpha: true)
        }
    }

    private func checkboxBorder(palette: RadixComponentPalette) -> Color {
        isEnabled ? palette.gray(7, alpha: true) : palette.gray(6, alpha: true)
    }

    private func checkboxIndicator(palette: RadixComponentPalette) -> Color {
        variant == .soft ? palette.accent(11, alpha: true) : palette.contrast()
    }
}

public struct RadixSwitch<Label: View>: View {
    @Binding private var isOn: Bool
    @GestureState private var dragProgress: CGFloat?
    @State private var didDragKnob = false
    public var size: RadixSize
    public var variant: RadixThemeVariant
    public var color: RadixAccentColor?
    private let label: Label

    @Environment(\.radixTheme) private var theme
    @Environment(\.radixAnimations) private var animations
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.isEnabled) private var isEnabled

    public init(
        isOn: Binding<Bool>,
        size: RadixSize = .two,
        variant: RadixThemeVariant = .surface,
        color: RadixAccentColor? = nil,
        @ViewBuilder label: () -> Label
    ) {
        self._isOn = isOn
        self.size = size
        self.variant = variant
        self.color = color
        self.label = label()
    }

    public init(
        _ title: LocalizedStringKey,
        isOn: Binding<Bool>,
        size: RadixSize = .two,
        variant: RadixThemeVariant = .surface,
        color: RadixAccentColor? = nil
    ) where Label == Text {
        self.init(isOn: isOn, size: size, variant: variant, color: color) {
            Text(title)
        }
    }

    public var body: some View {
        let palette = RadixComponentPalette(theme: theme, colorScheme: colorScheme, overrideColor: color)

        Button {
            guard !didDragKnob else {
                didDragKnob = false
                return
            }

            animations.perform(.toggle) {
                isOn.toggle()
            }
        } label: {
            HStack(spacing: theme.space(2)) {
                switchTrack(palette: palette)
                label
                    .font(theme.font(.two))
                    .foregroundStyle(theme.gray(12, colorScheme: colorScheme))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .opacity(isEnabled ? 1 : 0.58)
        .radixResponsiveHover(active: isEnabled, scale: 1.006)
        .animation(animations.animation(for: .toggle), value: isOn)
        .accessibilityValue(isOn ? Text("On") : Text("Off"))
    }

    private var trackHeight: CGFloat {
        switch size {
        case .one: theme.space(4)
        case .two: theme.space(5) * 5 / 6
        case .three: theme.space(5)
        default: theme.space(5) * 5 / 6
        }
    }

    private var trackWidth: CGFloat {
        trackHeight * 1.75
    }

    private func switchTrack(palette: RadixComponentPalette) -> some View {
        let inset: CGFloat = 1
        let thumbSize = trackHeight - inset * 2
        let progress = dragProgress ?? (isOn ? 1 : 0)
        let offset = (trackWidth - trackHeight) * progress

        return Group {
            if #available(iOS 26.0, macOS 26.0, macCatalyst 26.0, tvOS 26.0, watchOS 26.0, *) {
                GlassEffectContainer(spacing: 3) {
                    ZStack(alignment: .leading) {
                        liquidGlassTrack(palette: palette)
                        liquidGlassKnob(size: thumbSize)
                            .offset(x: inset + offset)
                    }
                }
            } else {
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(switchBackground(palette: palette))
                        .overlay(
                            Capsule()
                                .stroke(switchBorder(palette: palette), lineWidth: 1)
                        )

                    Circle()
                        .fill(Color.white)
                        .frame(width: thumbSize, height: thumbSize)
                        .shadow(color: .black.opacity(0.12), radius: 1, x: 0, y: 1)
                        .offset(x: inset + offset)
                }
            }
        }
        .frame(width: trackWidth, height: trackHeight)
        .contentShape(Capsule())
        .simultaneousGesture(switchDragGesture())
    }

    private func switchBackground(palette: RadixComponentPalette) -> Color {
        guard isEnabled else { return palette.gray(3, alpha: true) }

        if isOn {
            return variant == .soft ? palette.accent(5, alpha: true) : palette.accent(9)
        }

        return variant == .soft ? palette.accent(3, alpha: true) : palette.gray(3, alpha: true)
    }

    private func switchBorder(palette: RadixComponentPalette) -> Color {
        if isOn && variant != .surface { return .clear }
        return palette.gray(5, alpha: true)
    }

    @available(iOS 26.0, macOS 26.0, macCatalyst 26.0, tvOS 26.0, watchOS 26.0, *)
    private func liquidGlassTrack(palette: RadixComponentPalette) -> some View {
        Capsule()
            .fill(switchLiquidGlassFill(palette: palette))
            .glassEffect(switchGlass(palette: palette), in: Capsule())
            .overlay(
                Capsule()
                    .stroke(switchBorder(palette: palette), lineWidth: 1)
            )
    }

    @available(iOS 26.0, macOS 26.0, macCatalyst 26.0, tvOS 26.0, watchOS 26.0, *)
    private func liquidGlassKnob(size: CGFloat) -> some View {
        Circle()
            .fill(Color.white.opacity(colorScheme == .dark ? 0.78 : 0.86))
            .glassEffect(.regular.interactive(isEnabled), in: Circle())
            .frame(width: size, height: size)
            .shadow(color: .black.opacity(0.12), radius: 1, x: 0, y: 1)
    }

    private func switchLiquidGlassFill(palette: RadixComponentPalette) -> Color {
        guard isEnabled else { return palette.gray(3, alpha: true).opacity(0.3) }

        if isOn {
            return palette.accent(9).opacity(variant == .soft ? 0.18 : 0.26)
        }

        return palette.gray(3, alpha: true).opacity(0.24)
    }

    @available(iOS 26.0, macOS 26.0, macCatalyst 26.0, tvOS 26.0, watchOS 26.0, *)
    private func switchGlass(palette: RadixComponentPalette) -> Glass {
        let glass = isOn ? Glass.regular.tint(palette.accent(9)) : Glass.regular
        return glass.interactive(isEnabled)
    }

    private func switchDragGesture() -> some Gesture {
        DragGesture(minimumDistance: 3)
            .updating($dragProgress) { gesture, state, _ in
                guard isEnabled else { return }

                state = switchProgress(from: gesture.location.x)
            }
            .onChanged { gesture in
                guard isEnabled else { return }

                if abs(gesture.translation.width) > 2 {
                    didDragKnob = true
                }
            }
            .onEnded { gesture in
                guard isEnabled, didDragKnob || abs(gesture.translation.width) > 2 else { return }

                let nextValue = switchProgress(from: gesture.location.x) >= 0.5
                if isOn != nextValue {
                    animations.perform(.toggle) {
                        isOn = nextValue
                    }
                }
                DispatchQueue.main.async {
                    didDragKnob = false
                }
            }
    }

    /// <summary>
    /// Converts a pointer position inside the track into the knob's 0...1 travel range.
    /// </summary>
    private func switchProgress(from locationX: CGFloat) -> CGFloat {
        let travel = trackWidth - trackHeight
        guard travel > 0 else { return 0 }

        return min(max((locationX - trackHeight / 2) / travel, 0), 1)
    }
}

public struct RadixSlider: View {
    @Binding private var value: Double
    public var bounds: ClosedRange<Double>
    public var step: Double
    public var color: RadixAccentColor?
    public var size: RadixSize
    public var variant: RadixThemeVariant

    @Environment(\.radixTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.isEnabled) private var isEnabled

    public init(
        value: Binding<Double>,
        in bounds: ClosedRange<Double> = 0...1,
        step: Double = 0.01,
        color: RadixAccentColor? = nil,
        size: RadixSize = .two,
        variant: RadixThemeVariant = .surface
    ) {
        self._value = value
        self.bounds = bounds
        self.step = step
        self.color = color
        self.size = size
        self.variant = variant
    }

    public var body: some View {
        let palette = RadixComponentPalette(theme: theme, colorScheme: colorScheme, overrideColor: color)
        let trackHeight = sliderTrackHeight
        let thumbSize = sliderThumbSize
        let controlHeight = max(theme.space(5), thumbSize + theme.space(2))

        GeometryReader { proxy in
            let progress = normalizedProgress
            let trackWidth = max(proxy.size.width, 1)

            RadixGlassEffectGroup(spacing: 0) {
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(sliderTrackBackground(palette: palette))
                        .radixInteractiveGlass(enabled: isEnabled, in: Capsule())
                        .overlay(
                            Capsule()
                                .stroke(sliderTrackBorder(palette: palette), lineWidth: variant == .surface ? 1 : 0)
                        )
                        .frame(height: trackHeight)

                    Capsule()
                        .fill(sliderRangeBackground(palette: palette))
                        .radixInteractiveGlass(
                            enabled: isEnabled,
                            tint: palette.accent(9).opacity(0.2),
                            in: Capsule()
                        )
                        .frame(width: trackWidth * progress, height: trackHeight)

                    Circle()
                        .fill(sliderThumbBackground)
                        .radixInteractiveGlass(enabled: isEnabled, in: Circle())
                        .frame(width: thumbSize, height: thumbSize)
                        .overlay(
                            Circle()
                                .stroke(theme.gray(7, alpha: true, colorScheme: colorScheme), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(colorScheme == .dark ? 0.12 : 0.05), radius: 1.5, x: 0, y: 1)
                        .offset(x: min(max(trackWidth * progress - thumbSize / 2, 0), max(trackWidth - thumbSize, 0)))
                }
            }
            .frame(height: controlHeight)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        setValue(from: gesture.location.x, width: trackWidth)
                    }
            )
        }
        .frame(height: controlHeight)
        .opacity(isEnabled ? 1 : 0.58)
        .accessibilityValue(Text("\(Int(normalizedProgress * 100)) percent"))
    }

    private var sliderTrackHeight: CGFloat {
        switch size {
        case .one: theme.space(1) * 1.5
        case .two: theme.space(2)
        case .three: theme.space(2) * 1.25
        default: theme.space(2)
        }
    }

    private var sliderThumbSize: CGFloat {
        sliderTrackHeight + theme.space(1)
    }

    private var sliderThumbBackground: Color {
        colorScheme == .dark
            ? Color.white.opacity(0.88)
            : theme.gray(12, colorScheme: colorScheme).opacity(0.92)
    }

    private func sliderTrackBackground(palette: RadixComponentPalette) -> Color {
        variant == .soft ? palette.accent(3, alpha: true) : palette.gray(3, alpha: true)
    }

    private func sliderTrackBorder(palette: RadixComponentPalette) -> Color {
        palette.gray(5, alpha: true)
    }

    private func sliderRangeBackground(palette: RadixComponentPalette) -> Color {
        switch variant {
        case .soft:
            palette.accent(8, alpha: true)
        default:
            palette.accent(9)
        }
    }

    private var normalizedProgress: CGFloat {
        guard bounds.upperBound > bounds.lowerBound else { return 0 }
        let clamped = min(max(value, bounds.lowerBound), bounds.upperBound)
        return CGFloat((clamped - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound))
    }

    private func setValue(from x: CGFloat, width: CGFloat) {
        guard width > 0, isEnabled else { return }

        let progress = min(max(Double(x / width), 0), 1)
        let rawValue = bounds.lowerBound + progress * (bounds.upperBound - bounds.lowerBound)
        let nextValue: Double
        if step > 0 {
            let steps = ((rawValue - bounds.lowerBound) / step).rounded()
            nextValue = min(max(bounds.lowerBound + steps * step, bounds.lowerBound), bounds.upperBound)
        } else {
            nextValue = min(max(rawValue, bounds.lowerBound), bounds.upperBound)
        }

        if value != nextValue {
            value = nextValue
        }
    }
}

public struct RadixTextField: View {
    public var title: LocalizedStringKey
    public var size: RadixSize
    public var variant: RadixThemeVariant
    public var color: RadixAccentColor?
    @Binding private var text: String
    @FocusState private var isFocused: Bool

    @Environment(\.radixTheme) private var theme
    @Environment(\.radixAnimations) private var animations
    @Environment(\.colorScheme) private var colorScheme

    public init(
        _ title: LocalizedStringKey,
        text: Binding<String>,
        size: RadixSize = .two,
        variant: RadixThemeVariant = .surface,
        color: RadixAccentColor? = nil
    ) {
        self.title = title
        self._text = text
        self.size = size
        self.variant = variant
        self.color = color
    }

    public var body: some View {
        let palette = RadixComponentPalette(theme: theme, colorScheme: colorScheme, overrideColor: color)
        let metrics = RadixControlMetrics(size: size, theme: theme)

        TextField(title, text: $text)
            .textFieldStyle(.plain)
            .focused($isFocused)
            .font(theme.font(size))
            .foregroundStyle(fieldForeground(palette: palette))
            .padding(.horizontal, metrics.controlHorizontalPadding - fieldBorderWidth)
            .frame(minHeight: metrics.height)
            .background(fieldBackground(palette: palette))
            .overlay(
                RoundedRectangle(cornerRadius: metrics.radius, style: .continuous)
                    .stroke(fieldBorder(palette: palette), lineWidth: fieldBorderWidth)
            )
            .overlay(focusRing(radius: metrics.radius, palette: palette))
            .clipShape(RoundedRectangle(cornerRadius: metrics.radius, style: .continuous))
            .animation(animations.animation(for: .hover), value: isFocused)
    }

    private var fieldBorderWidth: CGFloat {
        variant == .soft || variant == .ghost || variant == .solid ? 0 : 1
    }

    private func fieldForeground(palette: RadixComponentPalette) -> Color {
        variant == .soft ? palette.accent(12) : theme.gray(12, colorScheme: colorScheme)
    }

    private func fieldBackground(palette: RadixComponentPalette) -> Color {
        switch variant {
        case .classic, .surface:
            theme.controlSurface(colorScheme: colorScheme)
        case .soft:
            palette.accent(3, alpha: true)
        case .solid:
            palette.accent(9)
        case .outline, .ghost:
            .clear
        }
    }

    private func fieldBorder(palette: RadixComponentPalette) -> Color {
        switch variant {
        case .outline:
            palette.accent(8, alpha: true)
        case .classic, .surface:
            theme.gray(isFocused ? 8 : 7, alpha: true, colorScheme: colorScheme)
        default:
            .clear
        }
    }

    @ViewBuilder
    private func focusRing(radius: CGFloat, palette: RadixComponentPalette) -> some View {
        if isFocused {
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .stroke(palette.accent(8, alpha: true), lineWidth: 2)
        }
    }
}

public struct RadixTextArea: View {
    @Binding private var text: String
    public var minHeight: CGFloat
    public var size: RadixSize
    public var variant: RadixThemeVariant
    public var color: RadixAccentColor?
    @FocusState private var isFocused: Bool

    @Environment(\.radixTheme) private var theme
    @Environment(\.radixAnimations) private var animations
    @Environment(\.colorScheme) private var colorScheme

    public init(
        text: Binding<String>,
        minHeight: CGFloat = 96,
        size: RadixSize = .two,
        variant: RadixThemeVariant = .surface,
        color: RadixAccentColor? = nil
    ) {
        self._text = text
        self.minHeight = minHeight
        self.size = size
        self.variant = variant
        self.color = color
    }

    public var body: some View {
        let palette = RadixComponentPalette(theme: theme, colorScheme: colorScheme, overrideColor: color)
        let radius = theme.radius(size == .three ? 3 : 2)

        TextEditor(text: $text)
            .scrollContentBackground(.hidden)
            .focused($isFocused)
            .font(theme.font(size))
            .foregroundStyle(fieldForeground(palette: palette))
            .padding(.horizontal, textAreaHorizontalPadding - fieldBorderWidth)
            .padding(.vertical, textAreaVerticalPadding - fieldBorderWidth)
            .frame(minHeight: minHeight)
            .background(fieldBackground(palette: palette))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(fieldBorder(palette: palette), lineWidth: fieldBorderWidth)
            )
            .overlay(focusRing(radius: radius, palette: palette))
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .animation(animations.animation(for: .hover), value: isFocused)
    }

    private var fieldBorderWidth: CGFloat {
        variant == .soft || variant == .ghost || variant == .solid ? 0 : 1
    }

    private var textAreaHorizontalPadding: CGFloat {
        size == .three ? theme.space(3) : theme.space(2)
    }

    private var textAreaVerticalPadding: CGFloat {
        size == .one ? theme.space(1) : theme.space(2) * 0.75
    }

    private func fieldForeground(palette: RadixComponentPalette) -> Color {
        variant == .soft ? palette.accent(12) : theme.gray(12, colorScheme: colorScheme)
    }

    private func fieldBackground(palette: RadixComponentPalette) -> Color {
        switch variant {
        case .classic, .surface:
            theme.controlSurface(colorScheme: colorScheme)
        case .soft:
            palette.accent(3, alpha: true)
        case .solid:
            palette.accent(9)
        case .outline, .ghost:
            .clear
        }
    }

    private func fieldBorder(palette: RadixComponentPalette) -> Color {
        switch variant {
        case .outline:
            palette.accent(8, alpha: true)
        case .classic, .surface:
            theme.gray(isFocused ? 8 : 7, alpha: true, colorScheme: colorScheme)
        default:
            .clear
        }
    }

    @ViewBuilder
    private func focusRing(radius: CGFloat, palette: RadixComponentPalette) -> some View {
        if isFocused {
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .stroke(palette.accent(8, alpha: true), lineWidth: 2)
        }
    }
}

public struct RadixSelectionOption<Value: Hashable>: Identifiable, Hashable, Sendable where Value: Sendable {
    public let id: Value
    public let label: String

    public init(_ value: Value, label: String) {
        self.id = value
        self.label = label
    }
}

public struct RadixSegmentedControl<Value: Hashable & Sendable>: View {
    @Binding private var selection: Value
    public var options: [RadixSelectionOption<Value>]
    public var size: RadixSize
    public var variant: RadixThemeVariant

    @Environment(\.radixTheme) private var theme
    @Environment(\.radixAnimations) private var animations
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.isEnabled) private var isEnabled
    @Namespace private var selectionNamespace

    public init(
        selection: Binding<Value>,
        options: [RadixSelectionOption<Value>],
        size: RadixSize = .two,
        variant: RadixThemeVariant = .surface
    ) {
        self._selection = selection
        self.options = options
        self.size = size
        self.variant = variant
    }

    public var body: some View {
        let metrics = RadixControlMetrics(size: size, theme: theme)
        let radius = metrics.radius
        let indicatorInset = segmentedIndicatorInset
        let indicatorRadius = max(radius - 1, 0.5)
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)

        RadixGlassEffectGroup(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(Array(options.enumerated()), id: \.element.id) { index, option in
                    let isSelected = selection == option.id

                    Button {
                        if selection != option.id {
                            animations.perform(.toggle) {
                                selection = option.id
                            }
                        }
                    } label: {
                        Text(option.label)
                            .font(theme.font(size, weight: isSelected ? .medium : .regular))
                            .foregroundStyle(isSelected ? theme.gray(12, colorScheme: colorScheme) : theme.gray(11, colorScheme: colorScheme))
                            .padding(.horizontal, segmentedHorizontalPadding)
                            .frame(height: metrics.height)
                            .frame(maxWidth: .infinity)
                            .background(selectedIndicator(isSelected: isSelected, radius: indicatorRadius, inset: indicatorInset))
                            .radixInteractiveGlass(
                                active: isSelected,
                                enabled: isEnabled,
                                in: RadixInsetRoundedRectangle(
                                    cornerRadius: indicatorRadius,
                                    horizontalInset: indicatorInset,
                                    verticalInset: indicatorInset
                                ),
                                effectID: "selection",
                                namespace: selectionNamespace
                            )
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if index < options.count - 1 {
                        Rectangle()
                            .fill(theme.gray(4, alpha: true, colorScheme: colorScheme))
                            .frame(width: 1, height: max(metrics.height - 6, 1))
                            .opacity(separatorOpacity(left: option.id, right: options[index + 1].id))
                    }
                }
            }
        }
        .background(segmentedBackground(radius: radius))
        .radixInteractiveGlass(enabled: isEnabled, in: shape)
        .clipShape(shape)
        .overlay(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .stroke(theme.gray(4, alpha: true, colorScheme: colorScheme), lineWidth: 1)
        )
        .opacity(isEnabled ? 1 : 0.58)
        .animation(animations.animation(for: .toggle), value: selection)
    }

    private var segmentedIndicatorInset: CGFloat {
        switch size {
        case .one: 1
        default: 2
        }
    }

    private var segmentedHorizontalPadding: CGFloat {
        switch size {
        case .one: theme.space(3)
        case .two, .three: theme.space(4)
        default: theme.space(4)
        }
    }

    private func separatorOpacity(left: Value, right: Value) -> Double {
        selection == left || selection == right ? 0 : 1
    }

    private func segmentedBackground(radius: CGFloat) -> some View {
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)

        return shape
            .fill(theme.surface(colorScheme: colorScheme))
            .overlay(theme.gray(3, alpha: true, colorScheme: colorScheme))
    }

    @ViewBuilder
    private func selectedIndicator(isSelected: Bool, radius: CGFloat, inset: CGFloat) -> some View {
        if isSelected {
            let fill = colorScheme == .dark
                ? theme.gray(3, alpha: true, colorScheme: colorScheme)
                : theme.background(colorScheme: colorScheme)
            let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)

            shape
                .fill(fill)
                .padding(inset)
                .overlay(
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .stroke(theme.gray(4, alpha: true, colorScheme: colorScheme), lineWidth: variant == .surface ? 1 : 0)
                        .padding(inset)
                )
        }
    }
}

public enum RadixSegmentedButtonGroupDisplay: Equatable, Sendable {
    case text
    case icon
    case iconAndText
}

public struct RadixSegmentedButtonBadge: Hashable, Sendable {
    public var text: String
    public var color: RadixAccentColor?

    public init(_ text: String, color: RadixAccentColor? = nil) {
        self.text = text
        self.color = color
    }
}

public struct RadixSegmentedButtonGroupItem<Value: Hashable>: Identifiable, Hashable, Sendable where Value: Sendable {
    public let id: Value
    public var label: String
    public var icon: RadixIconName?
    public var badge: RadixSegmentedButtonBadge?

    public init(
        _ value: Value,
        label: String,
        icon: RadixIconName? = nil,
        badge: RadixSegmentedButtonBadge? = nil
    ) {
        self.id = value
        self.label = label
        self.icon = icon
        self.badge = badge
    }
}

public struct RadixSegmentedButtonGroup<Value: Hashable & Sendable>: View {
    @Binding private var selection: Value
    public var items: [RadixSegmentedButtonGroupItem<Value>]
    public var orientation: RadixOrientation
    public var display: RadixSegmentedButtonGroupDisplay
    public var size: RadixSize
    public var variant: RadixThemeVariant
    public var color: RadixAccentColor?
    @State private var hoveredItem: Value?

    @Environment(\.radixTheme) private var theme
    @Environment(\.radixAnimations) private var animations
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.isEnabled) private var isEnabled
    @Namespace private var selectionNamespace
    @Namespace private var hoverNamespace

    public init(
        selection: Binding<Value>,
        items: [RadixSegmentedButtonGroupItem<Value>],
        orientation: RadixOrientation = .horizontal,
        display: RadixSegmentedButtonGroupDisplay = .text,
        size: RadixSize = .two,
        variant: RadixThemeVariant = .surface,
        color: RadixAccentColor? = nil
    ) {
        self._selection = selection
        self.items = items
        self.orientation = orientation
        self.display = display
        self.size = size
        self.variant = variant
        self.color = color
    }

    public var body: some View {
        let metrics = RadixControlMetrics(size: size, theme: theme)
        let palette = RadixComponentPalette(theme: theme, colorScheme: colorScheme, overrideColor: color)
        let shape = RoundedRectangle(cornerRadius: groupRadius(metrics: metrics), style: .continuous)

        RadixGlassEffectGroup(spacing: 0) {
            orientedItems(metrics: metrics, palette: palette)
                .padding(groupInset)
        }
        .background(groupBackground(palette: palette, shape: shape))
        .radixInteractiveGlass(enabled: false, tint: groupGlassTint(palette: palette), in: shape)
        .clipShape(shape)
        .overlay(
            shape.stroke(groupBorder(palette: palette), lineWidth: groupBorderWidth)
        )
        .opacity(isEnabled ? 1 : 0.58)
        .animation(animations.animation(for: .toggle), value: selection)
        .animation(animations.animation(for: .hover), value: hoveredItem)
    }

    @ViewBuilder
    private func orientedItems(metrics: RadixControlMetrics, palette: RadixComponentPalette) -> some View {
        if orientation == .horizontal {
            HStack(spacing: 0) {
                itemButtons(metrics: metrics, palette: palette)
            }
        } else {
            VStack(spacing: 0) {
                itemButtons(metrics: metrics, palette: palette)
            }
        }
    }

    @ViewBuilder
    private func itemButtons(metrics: RadixControlMetrics, palette: RadixComponentPalette) -> some View {
        ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
            segmentedButton(for: item, metrics: metrics, palette: palette)

            if index < items.count - 1 {
                separator(
                    left: item.id,
                    right: items[index + 1].id,
                    metrics: metrics,
                    palette: palette
                )
            }
        }
    }

    private func segmentedButton(
        for item: RadixSegmentedButtonGroupItem<Value>,
        metrics: RadixControlMetrics,
        palette: RadixComponentPalette
    ) -> some View {
        let isSelected = selection == item.id
        let isHovered = hoveredItem == item.id && !isSelected
        let shape = RoundedRectangle(cornerRadius: itemRadius(metrics: metrics), style: .continuous)

        return Button {
            guard selection != item.id else { return }

            animations.perform(.toggle) {
                selection = item.id
            }
        } label: {
            ZStack {
                itemPlate(isSelected: isSelected, isHovered: isHovered, metrics: metrics, palette: palette)
                itemContent(for: item, isSelected: isSelected, palette: palette)
                    .padding(.horizontal, itemHorizontalPadding)
                    .padding(.vertical, 1)
            }
            .frame(minWidth: itemMinWidth(metrics: metrics), minHeight: metrics.height)
            .frame(height: metrics.height)
            .contentShape(shape)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(item.label))
        .accessibilityValue(isSelected ? Text("Selected") : Text(""))
        .onHover { hovering in
            guard isEnabled else { return }

            animations.perform(.hover) {
                if hovering {
                    hoveredItem = item.id
                } else if hoveredItem == item.id {
                    hoveredItem = nil
                }
            }
        }
    }

    /// <summary>
    /// Builds the visible segment content while keeping the text label available as the accessibility name.
    /// </summary>
    private func itemContent(
        for item: RadixSegmentedButtonGroupItem<Value>,
        isSelected: Bool,
        palette: RadixComponentPalette
    ) -> some View {
        let showsIcon = display != .text && item.icon != nil
        let showsText = display != .icon || item.icon == nil
        let spacing = showsIcon && showsText ? theme.space(2) : 0

        return HStack(spacing: spacing) {
            if showsIcon, let icon = item.icon {
                RadixIcon(icon, size: iconSize)
                    .accessibilityHidden(true)
            }

            if showsText {
                Text(item.label)
                    .font(theme.font(textSize, weight: isSelected ? .medium : .regular))
                    .lineLimit(1)
            }
        }
        .padding(.trailing, item.badge == nil ? 0 : badgeReservedWidth)
        .foregroundStyle(itemForeground(isSelected: isSelected, palette: palette))
        .overlay(alignment: .topTrailing) {
            if let badge = item.badge {
                badgeView(badge)
                    .offset(x: badgeOffset, y: -badgeOffset)
            }
        }
    }

    @ViewBuilder
    private func itemPlate(
        isSelected: Bool,
        isHovered: Bool,
        metrics: RadixControlMetrics,
        palette: RadixComponentPalette
    ) -> some View {
        let radius = itemRadius(metrics: metrics)
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)

        if isHovered {
            shape
                .fill(hoverFill(palette: palette))
                .matchedGeometryEffect(id: "hover", in: hoverNamespace)
                .padding(itemInset)
        }

        if isSelected {
            shape
                .fill(selectedFill(palette: palette))
                .overlay(
                    shape.stroke(selectedBorder(palette: palette), lineWidth: selectedBorderWidth)
                )
                .matchedGeometryEffect(id: "selection", in: selectionNamespace)
                .padding(itemInset)
        }
    }

    @ViewBuilder
    private func separator(
        left: Value,
        right: Value,
        metrics: RadixControlMetrics,
        palette: RadixComponentPalette
    ) -> some View {
        let opacity = separatorOpacity(left: left, right: right)

        if orientation == .horizontal {
            Rectangle()
                .fill(palette.gray(5, alpha: true))
                .frame(width: 1, height: max(metrics.height - itemInset * 4, 1))
                .opacity(opacity)
        } else {
            Rectangle()
                .fill(palette.gray(5, alpha: true))
                .frame(width: itemMinWidth(metrics: metrics), height: 1)
                .padding(.horizontal, theme.space(2))
                .opacity(opacity)
        }
    }

    private func badgeView(_ badge: RadixSegmentedButtonBadge) -> some View {
        let badgePalette = RadixComponentPalette(theme: theme, colorScheme: colorScheme, overrideColor: badge.color ?? .amber)

        return Text(badge.text)
            .font(theme.font(.one, weight: .bold))
            .foregroundStyle(badgePalette.contrast())
            .lineLimit(1)
            .padding(.horizontal, badge.text.count > 1 ? 5 : 0)
            .frame(minWidth: badgeSize, minHeight: badgeSize)
            .background(Capsule().fill(badgePalette.accent(9)))
            .overlay(
                Capsule()
                    .stroke(badgePalette.accent(8, alpha: true), lineWidth: 1)
            )
    }

    private var groupInset: CGFloat {
        switch size {
        case .one: 2
        case .two: 3
        default: 4
        }
    }

    private var itemInset: CGFloat {
        switch size {
        case .one: 1
        default: 2
        }
    }

    private var itemHorizontalPadding: CGFloat {
        switch display {
        case .icon:
            theme.space(2)
        case .text:
            theme.space(size == .one ? 3 : 4)
        case .iconAndText:
            theme.space(size == .one ? 3 : 4)
        }
    }

    private var textSize: RadixSize {
        size == .one ? .one : .two
    }

    private var iconSize: CGFloat {
        switch size {
        case .one: 14 * theme.scaling.factor
        case .two: 16 * theme.scaling.factor
        case .three: 18 * theme.scaling.factor
        default: 18 * theme.scaling.factor
        }
    }

    private var badgeSize: CGFloat {
        switch size {
        case .one: 15 * theme.scaling.factor
        case .two: 17 * theme.scaling.factor
        default: 18 * theme.scaling.factor
        }
    }

    private var badgeOffset: CGFloat {
        switch size {
        case .one: 4
        default: 5
        }
    }

    private var badgeReservedWidth: CGFloat {
        badgeSize * 0.9
    }

    private func groupRadius(metrics: RadixControlMetrics) -> CGFloat {
        metrics.radius + groupInset
    }

    private func itemRadius(metrics: RadixControlMetrics) -> CGFloat {
        max(metrics.radius, 1)
    }

    private func itemMinWidth(metrics: RadixControlMetrics) -> CGFloat {
        switch display {
        case .icon:
            metrics.height + theme.space(size == .one ? 2 : 3)
        case .text:
            theme.space(size == .one ? 7 : 8)
        case .iconAndText:
            theme.space(size == .one ? 9 : 10)
        }
    }

    private var groupBorderWidth: CGFloat {
        switch variant {
        case .surface, .outline, .classic:
            1
        default:
            0
        }
    }

    private var selectedBorderWidth: CGFloat {
        switch variant {
        case .surface, .outline, .classic:
            1
        default:
            0
        }
    }

    private func itemForeground(isSelected: Bool, palette: RadixComponentPalette) -> Color {
        if isSelected && (variant == .solid || variant == .classic) {
            return palette.contrast()
        }

        return isSelected
            ? palette.gray(12)
            : palette.gray(11)
    }

    private func groupBackground<S: Shape>(palette: RadixComponentPalette, shape: S) -> some View {
        shape.fill(groupFill(palette: palette))
    }

    private func groupFill(palette: RadixComponentPalette) -> Color {
        guard isEnabled else { return palette.gray(3, alpha: true) }

        return switch variant {
        case .classic:
            theme.solidPanel(colorScheme: colorScheme)
        case .soft:
            palette.accent(3, alpha: true)
        case .ghost, .outline:
            .clear
        case .solid:
            palette.accent(9).opacity(colorScheme == .dark ? 0.28 : 0.18)
        case .surface:
            theme.controlSurface(colorScheme: colorScheme)
        }
    }

    private func groupBorder(palette: RadixComponentPalette) -> Color {
        switch variant {
        case .outline:
            palette.accent(8, alpha: true)
        case .surface, .classic:
            palette.gray(6, alpha: true)
        default:
            .clear
        }
    }

    private func groupGlassTint(palette: RadixComponentPalette) -> Color? {
        switch variant {
        case .solid, .soft:
            palette.accent(9).opacity(0.18)
        default:
            nil
        }
    }

    private func selectedFill(palette: RadixComponentPalette) -> Color {
        switch variant {
        case .solid, .classic:
            palette.accent(9)
        case .soft:
            palette.accent(4, alpha: true)
        case .surface, .outline, .ghost:
            colorScheme == .dark
                ? palette.gray(3, alpha: true)
                : theme.background(colorScheme: colorScheme)
        }
    }

    private func selectedBorder(palette: RadixComponentPalette) -> Color {
        switch variant {
        case .outline:
            palette.accent(8, alpha: true)
        case .surface, .ghost:
            palette.accent(7, alpha: true)
        case .classic:
            palette.gray(7, alpha: true)
        default:
            .clear
        }
    }

    private func hoverFill(palette: RadixComponentPalette) -> Color {
        switch variant {
        case .soft:
            palette.accent(4, alpha: true)
        case .solid:
            palette.accent(9).opacity(0.2)
        default:
            palette.gray(3, alpha: true)
        }
    }

    private func separatorOpacity(left: Value, right: Value) -> Double {
        if selection == left || selection == right {
            return 0
        }

        if hoveredItem == left || hoveredItem == right {
            return 0
        }

        return 1
    }
}

public struct RadixSelect<Value: Hashable & Sendable>: View {
    public var title: LocalizedStringKey
    @Binding private var selection: Value
    public var options: [RadixSelectionOption<Value>]
    public var size: RadixSize
    public var variant: RadixThemeVariant
    public var color: RadixAccentColor?
    @State private var isOpen = false
    @State private var highlightedOption: Value?

    @Environment(\.radixTheme) private var theme
    @Environment(\.radixAnimations) private var animations
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.isEnabled) private var isEnabled

    public init(
        _ title: LocalizedStringKey,
        selection: Binding<Value>,
        options: [RadixSelectionOption<Value>],
        size: RadixSize = .two,
        variant: RadixThemeVariant = .surface,
        color: RadixAccentColor? = nil
    ) {
        self.title = title
        self._selection = selection
        self.options = options
        self.size = size
        self.variant = variant
        self.color = color
    }

    public var body: some View {
        let palette = RadixComponentPalette(theme: theme, colorScheme: colorScheme, overrideColor: color)
        let metrics = RadixControlMetrics(size: size, theme: theme)
        let shape = RoundedRectangle(cornerRadius: metrics.radius, style: .continuous)

        Button {
            animations.perform(.popup) {
                isOpen.toggle()
            }
        } label: {
            HStack(spacing: theme.space(2)) {
                if let selectedLabel {
                    Text(selectedLabel)
                } else {
                    Text(title)
                        .foregroundStyle(theme.gray(10, alpha: true, colorScheme: colorScheme))
                }

                Spacer(minLength: theme.space(2))

                RadixIcon(.chevronDown, size: size == .three ? 11 : 10)
                    .opacity(0.9)
            }
            .font(theme.font(size))
            .foregroundStyle(selectForeground(palette: palette))
            .lineLimit(1)
            .padding(.horizontal, metrics.controlHorizontalPadding)
            .frame(minWidth: 116, minHeight: metrics.height)
            .background(selectBackgroundLayer(palette: palette, radius: metrics.radius))
            .radixInteractiveGlass(
                active: usesSelectGlass,
                enabled: isEnabled,
                tint: selectGlassTint(palette: palette),
                in: shape
            )
            .overlay(selectBorder(palette: palette, radius: metrics.radius))
            .clipShape(shape)
            .contentShape(shape)
        }
        .buttonStyle(.plain)
        .opacity(isEnabled ? 1 : 0.58)
        .radixResponsiveHover(active: isEnabled, scale: 1.006)
        .background(
            RadixFloatingPanel(isPresented: $isOpen, placement: .belowAnchor(offset: 4)) {
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
                    RadixPopupPanel(size: size, minWidth: 160) {
                        ForEach(options) { option in
                            selectItem(option, palette: palette)
                        }
                    }
                }
            }
        )
    }

    private var selectedLabel: String? {
        options.first { $0.id == selection }?.label
    }

    private func selectForeground(palette: RadixComponentPalette) -> Color {
        switch variant {
        case .soft, .ghost:
            palette.accent(12)
        default:
            theme.gray(12, colorScheme: colorScheme)
        }
    }

    private var usesSelectGlass: Bool {
        isEnabled && (variant != .ghost || isOpen)
    }

    private func selectBackground(palette: RadixComponentPalette) -> Color {
        guard isEnabled else { return palette.gray(3, alpha: true) }

        switch variant {
        case .classic:
            return theme.solidPanel(colorScheme: colorScheme)
        case .soft:
            return palette.accent(3, alpha: true)
        case .ghost:
            return isOpen ? palette.accent(3, alpha: true) : .clear
        case .solid:
            return palette.accent(9)
        case .surface, .outline:
            return theme.controlSurface(colorScheme: colorScheme)
        }
    }

    private func selectBackgroundLayer(palette: RadixComponentPalette, radius: CGFloat) -> some View {
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)

        return shape
            .fill(selectBackground(palette: palette))
    }

    private func selectGlassTint(palette: RadixComponentPalette) -> Color? {
        switch variant {
        case .solid:
            palette.accent(9)
        case .soft:
            palette.accent(9).opacity(0.2)
        case .classic, .surface, .outline, .ghost:
            nil
        }
    }

    @ViewBuilder
    private func selectBorder(palette: RadixComponentPalette, radius: CGFloat) -> some View {
        switch variant {
        case .surface, .classic:
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .stroke(theme.gray(isOpen ? 8 : 7, alpha: true, colorScheme: colorScheme), lineWidth: 1)
        case .outline:
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .stroke(palette.accent(8, alpha: true), lineWidth: 1)
        default:
            EmptyView()
        }
    }

    private func selectItem(_ option: RadixSelectionOption<Value>, palette: RadixComponentPalette) -> some View {
        let selected = selection == option.id
        let highlighted = highlightedOption == option.id
        let active = selected || highlighted
        let radius = theme.radius(2)
        let highlightInset: CGFloat = 2

        return Button {
            animations.perform(.toggle) {
                if selection != option.id {
                    selection = option.id
                }
                highlightedOption = nil
                isOpen = false
            }
        } label: {
            HStack(spacing: theme.space(2)) {
                Group {
                    if selected {
                        RadixIcon(.check, size: 10)
                    } else {
                        Color.clear
                    }
                }
                .frame(width: theme.space(4))

                Text(option.label)
                    .font(theme.font(size == .one ? .one : .two))
                    .lineLimit(1)

                Spacer(minLength: theme.space(4))
            }
            .foregroundStyle(active ? palette.contrast() : theme.gray(12, colorScheme: colorScheme))
            .frame(height: size == .one ? theme.space(5) : theme.space(6))
            .padding(.horizontal, theme.space(2))
            .background(selectItemBackground(active: active, inset: highlightInset, radius: radius, palette: palette))
            .radixInteractiveGlass(
                active: active,
                enabled: isEnabled,
                tint: palette.accent(9).opacity(0.22),
                in: RadixInsetRoundedRectangle(cornerRadius: radius, verticalInset: highlightInset)
            )
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            if hovering, highlightedOption != option.id {
                highlightedOption = option.id
            } else if highlightedOption == option.id {
                highlightedOption = nil
            }
        }
    }

    @ViewBuilder
    private func selectItemBackground(active: Bool, inset: CGFloat, radius: CGFloat, palette: RadixComponentPalette) -> some View {
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)

        shape
            .fill(active ? palette.accent(9) : .clear)
            .padding(.vertical, inset)
            .animation(animations.animation(for: .hover), value: active)
    }
}

public struct RadixRadioGroup<Value: Hashable & Sendable>: View {
    @Binding private var selection: Value
    public var options: [RadixSelectionOption<Value>]

    public init(selection: Binding<Value>, options: [RadixSelectionOption<Value>]) {
        self._selection = selection
        self.options = options
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(options) { option in
                RadixRadio(option.labelLocalizedKey, isSelected: selection == option.id) {
                    if selection != option.id {
                        selection = option.id
                    }
                }
            }
        }
    }
}

private extension RadixSelectionOption {
    var labelLocalizedKey: LocalizedStringKey {
        LocalizedStringKey(label)
    }
}

public struct RadixCheckboxCards<Value: Hashable & Sendable>: View {
    @Binding private var selection: Set<Value>
    public var options: [RadixSelectionOption<Value>]

    public init(selection: Binding<Set<Value>>, options: [RadixSelectionOption<Value>]) {
        self._selection = selection
        self.options = options
    }

    public var body: some View {
        RadixGrid(columns: 2, gap: 2) {
            ForEach(options) { option in
                RadixCard(size: .two) {
                    RadixCheckbox(isOn: binding(for: option.id)) {
                        Text(option.label)
                    }
                }
            }
        }
    }

    private func binding(for value: Value) -> Binding<Bool> {
        Binding {
            selection.contains(value)
        } set: { isSelected in
            if isSelected {
                selection.insert(value)
            } else {
                selection.remove(value)
            }
        }
    }
}

public struct RadixRadioCards<Value: Hashable & Sendable>: View {
    @Binding private var selection: Value
    public var options: [RadixSelectionOption<Value>]

    public init(selection: Binding<Value>, options: [RadixSelectionOption<Value>]) {
        self._selection = selection
        self.options = options
    }

    public var body: some View {
        RadixGrid(columns: 2, gap: 2) {
            ForEach(options) { option in
                RadixButton(
                    variant: selection == option.id ? .solid : .surface,
                    size: .two
                ) {
                    if selection != option.id {
                        selection = option.id
                    }
                } label: {
                    Text(option.label)
                }
            }
        }
    }
}

public struct RadixDataListItem: Identifiable, Sendable {
    public let id = UUID()
    public var label: String
    public var value: String

    public init(label: String, value: String) {
        self.label = label
        self.value = value
    }
}

public struct RadixDataList: View {
    public var items: [RadixDataListItem]

    @Environment(\.radixTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    public init(_ items: [RadixDataListItem]) {
        self.items = items
    }

    public var body: some View {
        Grid(alignment: .leadingFirstTextBaseline, horizontalSpacing: theme.space(4), verticalSpacing: theme.space(2)) {
            ForEach(items.indices, id: \.self) { index in
                let item = items[index]

                GridRow {
                    Text(item.label)
                        .foregroundStyle(theme.gray(11, colorScheme: colorScheme))
                    Text(item.value)
                        .foregroundStyle(theme.gray(12, colorScheme: colorScheme))
                }
            }
        }
        .font(theme.font(.two))
    }
}

public struct RadixTable<Content: View>: View {
    private let content: Content

    @Environment(\.radixTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .padding(theme.space(3))
        .modifier(RadixCardChrome(variant: .surface))
        .foregroundStyle(theme.gray(12, colorScheme: colorScheme))
    }
}
