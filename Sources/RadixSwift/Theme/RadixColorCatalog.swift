import Foundation
import SwiftUI

public struct RadixColorStep: Identifiable, Equatable, Sendable {
    public let id: Int
    public let tokenName: String
    public let value: String
}

public struct RadixColorScale: Equatable, Sendable {
    public let exportName: String
    public let steps: [RadixColorStep]
}

public struct RadixUpstreamSource: Equatable, Sendable {
    public let website: String
    public let primitives: String
    public let icons: String
    public let themes: String
    public let colors: String
    public let commits: [String: String]
}

public final class RadixColorCatalog: @unchecked Sendable {
    public static let shared = RadixColorCatalog()

    public let upstream: RadixUpstreamSource
    public let exportNames: [String]
    public let themeColorNames: [String]

    private let exports: [String: [String: String]]
    private let themeColors: [String: RadixThemeColorPayload]
    private let colorCacheLock = NSLock()
    private var colorCache: [String: Color] = [:]

    private init(bundle: Bundle = .module) {
        guard let url = bundle.url(forResource: "RadixColors", withExtension: "json") else {
            fatalError("RadixColors.json is missing from the RadixSwift package resources.")
        }

        do {
            let data = try Data(contentsOf: url)
            let payload = try JSONDecoder().decode(RadixColorPayload.self, from: data)
            self.exports = payload.exports
            self.themeColors = payload.themeColors
            self.exportNames = payload.exports.keys.sorted()
            self.themeColorNames = payload.themeColors.keys.sorted()
            self.upstream = RadixUpstreamSource(
                website: payload.upstream.website,
                primitives: payload.upstream.primitives,
                icons: payload.upstream.icons,
                themes: payload.upstream.themes,
                colors: payload.upstream.colors,
                commits: payload.upstream.commits
            )
        } catch {
            fatalError("RadixColors.json could not be decoded: \(error)")
        }
    }

    public func scale(named exportName: String) -> RadixColorScale? {
        guard let values = exports[exportName] else { return nil }

        let steps = values
            .compactMap { key, value -> RadixColorStep? in
                guard let step = key.radixTrailingNumber else { return nil }
                return RadixColorStep(id: step, tokenName: key, value: value)
            }
            .sorted { $0.id < $1.id }

        return RadixColorScale(exportName: exportName, steps: steps)
    }

    public func tokenValue(
        scale: String,
        step: Int,
        appearance: RadixResolvedAppearance = .light,
        alpha: Bool = false,
        prefersDisplayP3: Bool = true
    ) -> String? {
        let exportName = resolvedExportName(
            scale: scale,
            appearance: appearance,
            alpha: alpha,
            prefersDisplayP3: prefersDisplayP3
        )
        let tokenName = "\(scale)\(alpha ? "A" : "")\(step)"

        if let value = exports[exportName]?[tokenName] {
            return value
        }

        let fallbackExportName = resolvedExportName(
            scale: scale,
            appearance: appearance,
            alpha: alpha,
            prefersDisplayP3: false
        )
        return exports[fallbackExportName]?[tokenName]
    }

    public func color(
        scale: String,
        step: Int,
        appearance: RadixResolvedAppearance = .light,
        alpha: Bool = false,
        prefersDisplayP3: Bool = true
    ) -> Color {
        guard
            let value = tokenValue(
                scale: scale,
                step: step,
                appearance: appearance,
                alpha: alpha,
                prefersDisplayP3: prefersDisplayP3
            )
        else {
            return .clear
        }

        return cachedColor(radixCSSValue: value)
    }

    public func blackAlpha(_ step: Int) -> Color {
        colorFromExport("blackA", token: "blackA\(step)")
    }

    public func whiteAlpha(_ step: Int) -> Color {
        colorFromExport("whiteA", token: "whiteA\(step)")
    }

    public func themeContrast(for color: RadixAccentColor) -> Color {
        let value = themeColors[color.rawValue]?.contrast ?? "white"
        return cachedColor(radixCSSValue: value)
    }

    public func themeSurface(
        for color: RadixAccentColor,
        appearance: RadixResolvedAppearance
    ) -> Color {
        let payload = themeColors[color.rawValue]
        let value = appearance == .dark ? payload?.darkSurface : payload?.lightSurface
        return cachedColor(radixCSSValue: value ?? "#ffffffcc")
    }

    public func matchingGrayColor(for accent: RadixAccentColor) -> RadixGrayColor {
        switch accent {
        case .tomato, .red, .ruby, .crimson, .pink, .plum, .purple, .violet:
            .mauve
        case .iris, .indigo, .blue, .sky, .cyan:
            .slate
        case .teal, .jade, .mint, .green:
            .sage
        case .grass, .lime:
            .olive
        case .yellow, .amber, .orange, .brown, .gold, .bronze:
            .sand
        case .gray:
            .gray
        }
    }

    private func colorFromExport(_ exportName: String, token: String) -> Color {
        guard let value = exports[exportName]?[token] else { return .clear }
        return cachedColor(radixCSSValue: value)
    }

    /// <summary>
    /// Reuses parsed SwiftUI colors for Radix tokens that are requested during view rendering.
    /// </summary>
    private func cachedColor(radixCSSValue value: String) -> Color {
        colorCacheLock.lock()
        if let cached = colorCache[value] {
            colorCacheLock.unlock()
            return cached
        }
        colorCacheLock.unlock()

        let color = Color(radixCSSValue: value)

        colorCacheLock.lock()
        colorCache[value] = color
        colorCacheLock.unlock()

        return color
    }

    private func resolvedExportName(
        scale: String,
        appearance: RadixResolvedAppearance,
        alpha: Bool,
        prefersDisplayP3: Bool
    ) -> String {
        if scale == "blackA" || scale == "whiteA" {
            return scale
        }

        var name = scale
        if appearance == .dark {
            name += "Dark"
        }
        if prefersDisplayP3 {
            name += "P3"
        }
        if alpha {
            name += "A"
        }
        return name
    }
}

private struct RadixColorPayload: Decodable {
    let upstream: RadixUpstreamPayload
    let exports: [String: [String: String]]
    let themeColors: [String: RadixThemeColorPayload]
}

private struct RadixUpstreamPayload: Decodable {
    let website: String
    let primitives: String
    let icons: String
    let themes: String
    let colors: String
    let commits: [String: String]
}

private struct RadixThemeColorPayload: Decodable {
    let contrast: String
    let lightSurface: String?
    let darkSurface: String?
}

private extension String {
    var radixTrailingNumber: Int? {
        var digits = ""
        for character in reversed() {
            guard character.isNumber else { break }
            digits.insert(character, at: digits.startIndex)
        }
        return digits.isEmpty ? nil : Int(digits)
    }
}

public extension Color {
    init(radixCSSValue value: String) {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed == "white" {
            self = .white
            return
        }

        if trimmed == "black" {
            self = .black
            return
        }

        if let components = RadixCSSColorParser.hex(trimmed) {
            self = Color(
                red: components.red,
                green: components.green,
                blue: components.blue,
                opacity: components.alpha
            )
            return
        }

        if let components = RadixCSSColorParser.displayP3(trimmed) {
            self = Color(
                .displayP3,
                red: components.red,
                green: components.green,
                blue: components.blue,
                opacity: components.alpha
            )
            return
        }

        if let components = RadixCSSColorParser.rgba(trimmed) {
            self = Color(
                red: components.red,
                green: components.green,
                blue: components.blue,
                opacity: components.alpha
            )
            return
        }

        self = .clear
    }
}

private enum RadixCSSColorParser {
    typealias Components = (red: Double, green: Double, blue: Double, alpha: Double)

    static func hex(_ value: String) -> Components? {
        guard value.hasPrefix("#") else { return nil }

        let raw = String(value.dropFirst())
        guard raw.count == 6 || raw.count == 8, let intValue = UInt64(raw, radix: 16) else {
            return nil
        }

        let red: UInt64
        let green: UInt64
        let blue: UInt64
        let alpha: UInt64

        if raw.count == 6 {
            red = (intValue >> 16) & 0xff
            green = (intValue >> 8) & 0xff
            blue = intValue & 0xff
            alpha = 0xff
        } else {
            red = (intValue >> 24) & 0xff
            green = (intValue >> 16) & 0xff
            blue = (intValue >> 8) & 0xff
            alpha = intValue & 0xff
        }

        return (
            Double(red) / 255,
            Double(green) / 255,
            Double(blue) / 255,
            Double(alpha) / 255
        )
    }

    static func displayP3(_ value: String) -> Components? {
        guard value.hasPrefix("color(display-p3 "), value.hasSuffix(")") else { return nil }

        let inner = value
            .replacingOccurrences(of: "color(display-p3 ", with: "")
            .dropLast()
        let pieces = inner
            .split(separator: " ")
            .map(String.init)

        guard pieces.count == 3 || pieces.count == 5 else { return nil }
        guard
            let red = Double(pieces[0]),
            let green = Double(pieces[1]),
            let blue = Double(pieces[2])
        else {
            return nil
        }

        let alpha = pieces.count == 5 ? Double(pieces[4]) ?? 1 : 1
        return (red, green, blue, alpha)
    }

    static func rgba(_ value: String) -> Components? {
        guard value.hasPrefix("rgba("), value.hasSuffix(")") else { return nil }

        let inner = value
            .replacingOccurrences(of: "rgba(", with: "")
            .dropLast()
        let pieces = inner
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        guard pieces.count == 4 else { return nil }
        guard
            let red = Double(pieces[0]),
            let green = Double(pieces[1]),
            let blue = Double(pieces[2]),
            let alpha = Double(pieces[3])
        else {
            return nil
        }

        return (red / 255, green / 255, blue / 255, alpha)
    }
}
