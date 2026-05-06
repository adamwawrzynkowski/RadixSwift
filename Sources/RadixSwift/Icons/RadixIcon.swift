import Foundation
import SwiftUI

public struct RadixIcon: View {
    public let name: RadixIconName
    public var size: CGFloat
    public var accessibilityLabel: String?

    public init(
        _ name: RadixIconName,
        size: CGFloat = 15,
        accessibilityLabel: String? = nil
    ) {
        self.name = name
        self.size = size
        self.accessibilityLabel = accessibilityLabel
    }

    public var body: some View {
        Group {
            if let definition = RadixIconLoader.definition(named: name) {
                ZStack {
                    ForEach(definition.primitives) { primitive in
                        RadixIconPrimitiveShape(path: primitive.path, viewBox: definition.viewBox)
                            .fill(.foreground, style: FillStyle(eoFill: primitive.usesEvenOddFill))
                            .opacity(primitive.opacity)
                    }
                }
            } else if let symbolName = fallbackSymbolName {
                Image(systemName: symbolName)
                    .font(.system(size: size * 0.78, weight: .medium))
                    .imageScale(.small)
            } else {
                Rectangle()
                    .fill(.clear)
                    .overlay(Rectangle().strokeBorder(.secondary, lineWidth: 1))
            }
        }
        .frame(width: size, height: size)
        .accessibilityLabel(accessibilityLabel ?? name.rawValue)
        .accessibilityHidden(accessibilityLabel == nil)
    }

    private var fallbackSymbolName: String? {
        switch name {
        case .check:
            "checkmark"
        case .chevronDown:
            "chevron.down"
        case .chevronLeft:
            "chevron.left"
        case .chevronRight:
            "chevron.right"
        case .chevronUp:
            "chevron.up"
        case .arrowRight:
            "arrow.right"
        case .arrowLeft:
            "arrow.left"
        case .arrowUp:
            "arrow.up"
        case .arrowDown:
            "arrow.down"
        default:
            nil
        }
    }
}

struct RadixIconDefinition {
    var viewBox: CGRect
    var primitives: [RadixIconPrimitive]
}

struct RadixIconPrimitive: Identifiable {
    var id: Int
    var path: Path
    var usesEvenOddFill: Bool
    var opacity: Double
}

private struct RadixIconPrimitiveShape: Shape {
    var path: Path
    var viewBox: CGRect

    func path(in rect: CGRect) -> Path {
        let xScale = rect.width / viewBox.width
        let yScale = rect.height / viewBox.height
        let transform = CGAffineTransform(
            a: xScale,
            b: 0,
            c: 0,
            d: yScale,
            tx: rect.minX - viewBox.minX * xScale,
            ty: rect.minY - viewBox.minY * yScale
        )
        return path.applying(transform)
    }
}

@MainActor
enum RadixIconLoader {
    private static var cache: [RadixIconName: RadixIconDefinition] = [:]

    static func definition(named name: RadixIconName) -> RadixIconDefinition? {
        if let cached = cache[name] {
            return cached
        }

        guard let url = resourceURL(for: name),
              let svg = try? String(contentsOf: url, encoding: .utf8),
              let definition = RadixIconSVGParser.parse(svg)
        else {
            return nil
        }

        cache[name] = definition
        return definition
    }

    private static func resourceURL(for name: RadixIconName) -> URL? {
        Bundle.module.url(
            forResource: name.resourceName,
            withExtension: "svg"
        ) ?? Bundle.module.url(
            forResource: name.resourceName,
            withExtension: "svg",
            subdirectory: "Icons"
        )
    }
}

private enum RadixIconSVGParser {
    private static let svgExpression = try! NSRegularExpression(
        pattern: #"<svg\b([^>]*)>"#
    )
    private static let maskExpression = try! NSRegularExpression(
        pattern: #"<mask\b[^>]*>.*?</mask>"#,
        options: [.dotMatchesLineSeparators]
    )
    private static let primitiveExpression = try! NSRegularExpression(
        pattern: #"<(path|rect|circle)\b([^>]*)/?>"#
    )
    private static let attributeExpression = try! NSRegularExpression(
        pattern: #"([A-Za-z:-]+)\s*=\s*"([^"]*)"#
    )

    /// <summary>
    /// Parses the small SVG subset used by Radix Icons into SwiftUI paths.
    /// </summary>
    static func parse(_ svg: String) -> RadixIconDefinition? {
        let viewBox = parseViewBox(from: svg) ?? CGRect(x: 0, y: 0, width: 15, height: 15)
        let svgWithoutMasks = stripMasks(from: svg)
        let nsRange = NSRange(svgWithoutMasks.startIndex..<svgWithoutMasks.endIndex, in: svgWithoutMasks)
        let matches = primitiveExpression.matches(in: svgWithoutMasks, range: nsRange)

        var primitives: [RadixIconPrimitive] = []
        for match in matches {
            guard let tagRange = Range(match.range(at: 1), in: svgWithoutMasks),
                  let attributesRange = Range(match.range(at: 2), in: svgWithoutMasks)
            else {
                continue
            }

            let tag = String(svgWithoutMasks[tagRange])
            let attributes = parseAttributes(String(svgWithoutMasks[attributesRange]))
            guard attributes["mask"] == nil,
                  let primitivePath = makePath(for: tag, attributes: attributes)
            else {
                continue
            }

            let primitive = RadixIconPrimitive(
                id: primitives.count,
                path: primitivePath,
                usesEvenOddFill: attributes["fill-rule"] == "evenodd",
                opacity: double(attributes["opacity"]) ?? 1
            )
            primitives.append(primitive)
        }

        guard !primitives.isEmpty else {
            return nil
        }

        return RadixIconDefinition(viewBox: viewBox, primitives: primitives)
    }

    private static func parseViewBox(from svg: String) -> CGRect? {
        let nsRange = NSRange(svg.startIndex..<svg.endIndex, in: svg)
        guard let match = svgExpression.firstMatch(in: svg, range: nsRange),
              let attributesRange = Range(match.range(at: 1), in: svg)
        else {
            return nil
        }

        let attributes = parseAttributes(String(svg[attributesRange]))
        guard let value = attributes["viewBox"] else {
            return nil
        }

        let values = parseNumbers(value)
        guard values.count == 4 else {
            return nil
        }

        return CGRect(x: values[0], y: values[1], width: values[2], height: values[3])
    }

    private static func stripMasks(from svg: String) -> String {
        let nsRange = NSRange(svg.startIndex..<svg.endIndex, in: svg)
        return maskExpression.stringByReplacingMatches(
            in: svg,
            range: nsRange,
            withTemplate: ""
        )
    }

    private static func makePath(for tag: String, attributes: [String: String]) -> Path? {
        let path: Path?
        switch tag {
        case "path":
            guard let data = attributes["d"] else {
                return nil
            }
            path = SVGPathParser.parse(data)
        case "rect":
            path = makeRectPath(attributes)
        case "circle":
            path = makeCirclePath(attributes)
        default:
            path = nil
        }

        guard var path else {
            return nil
        }

        if let transformValue = attributes["transform"],
           let transform = parseTransform(transformValue)
        {
            path = path.applying(transform)
        }

        return path
    }

    private static func makeRectPath(_ attributes: [String: String]) -> Path? {
        let x = double(attributes["x"]) ?? 0
        let y = double(attributes["y"]) ?? 0
        guard let width = double(attributes["width"]),
              let height = double(attributes["height"])
        else {
            return nil
        }

        let rect = CGRect(x: x, y: y, width: width, height: height)
        var path = Path()
        if let radius = double(attributes["rx"]), radius > 0 {
            path.addRoundedRect(in: rect, cornerSize: CGSize(width: radius, height: radius))
        } else {
            path.addRect(rect)
        }
        return path
    }

    private static func makeCirclePath(_ attributes: [String: String]) -> Path? {
        guard let centerX = double(attributes["cx"]),
              let centerY = double(attributes["cy"]),
              let radius = double(attributes["r"])
        else {
            return nil
        }

        let rect = CGRect(
            x: centerX - radius,
            y: centerY - radius,
            width: radius * 2,
            height: radius * 2
        )
        return Path(ellipseIn: rect)
    }

    private static func parseAttributes(_ source: String) -> [String: String] {
        let nsRange = NSRange(source.startIndex..<source.endIndex, in: source)
        let matches = attributeExpression.matches(in: source, range: nsRange)
        var attributes: [String: String] = [:]

        for match in matches {
            guard let keyRange = Range(match.range(at: 1), in: source),
                  let valueRange = Range(match.range(at: 2), in: source)
            else {
                continue
            }
            attributes[String(source[keyRange])] = String(source[valueRange])
        }

        return attributes
    }

    private static func parseTransform(_ value: String) -> CGAffineTransform? {
        let numbers = parseNumbers(value)
        if value.hasPrefix("matrix"), numbers.count == 6 {
            return CGAffineTransform(
                a: numbers[0],
                b: numbers[1],
                c: numbers[2],
                d: numbers[3],
                tx: numbers[4],
                ty: numbers[5]
            )
        }

        if value.hasPrefix("rotate"), numbers.count == 3 {
            let radians = numbers[0] * .pi / 180
            let centerX = numbers[1]
            let centerY = numbers[2]
            var transform = CGAffineTransform(translationX: centerX, y: centerY)
            transform = transform.rotated(by: radians)
            return transform.translatedBy(x: -centerX, y: -centerY)
        }

        return nil
    }

    private static func parseNumbers(_ source: String) -> [CGFloat] {
        let pattern = #"[-+]?(?:(?:\d+\.?\d*)|(?:\.\d+))(?:[eE][-+]?\d+)?"#
        let expression = try! NSRegularExpression(pattern: pattern)
        let nsRange = NSRange(source.startIndex..<source.endIndex, in: source)
        return expression.matches(in: source, range: nsRange).compactMap { match in
            guard let range = Range(match.range, in: source),
                  let value = Double(source[range])
            else {
                return nil
            }
            return CGFloat(value)
        }
    }

    private static func double(_ value: String?) -> CGFloat? {
        guard let value,
              let number = Double(value)
        else {
            return nil
        }
        return CGFloat(number)
    }
}

private struct SVGPathParser {
    private enum Token {
        case command(Character)
        case number(CGFloat)
    }

    private var tokens: [Token]
    private var index = 0

    static func parse(_ data: String) -> Path? {
        var parser = SVGPathParser(tokens: tokenize(data))
        return parser.parsePath()
    }

    /// <summary>
    /// Walks the Radix path commands and converts repeated coordinate groups into Path calls.
    /// </summary>
    private mutating func parsePath() -> Path? {
        var path = Path()
        var current = CGPoint.zero
        var subpathStart = CGPoint.zero
        var currentCommand: Character?

        while index < tokens.count {
            if let command = readCommand() {
                currentCommand = command
            }

            guard let command = currentCommand else {
                return nil
            }

            switch command {
            case "M", "m":
                let isRelative = command == "m"
                guard let point = readPoint(relative: isRelative, from: current) else {
                    return nil
                }
                path.move(to: point)
                current = point
                subpathStart = point

                while let point = readPoint(relative: isRelative, from: current) {
                    path.addLine(to: point)
                    current = point
                }
                currentCommand = isRelative ? "l" : "L"
            case "L", "l":
                let isRelative = command == "l"
                guard parseRepeatedPoints(into: &path, current: &current, relative: isRelative) else {
                    return nil
                }
            case "H", "h":
                let isRelative = command == "h"
                guard parseRepeatedHorizontalLines(into: &path, current: &current, relative: isRelative) else {
                    return nil
                }
            case "V", "v":
                let isRelative = command == "v"
                guard parseRepeatedVerticalLines(into: &path, current: &current, relative: isRelative) else {
                    return nil
                }
            case "C", "c":
                let isRelative = command == "c"
                guard parseRepeatedCurves(into: &path, current: &current, relative: isRelative) else {
                    return nil
                }
            case "Z", "z":
                path.closeSubpath()
                current = subpathStart
                currentCommand = nil
            default:
                return nil
            }
        }

        return path
    }

    private mutating func parseRepeatedPoints(
        into path: inout Path,
        current: inout CGPoint,
        relative: Bool
    ) -> Bool {
        guard let first = readPoint(relative: relative, from: current) else {
            return false
        }
        path.addLine(to: first)
        current = first

        while let point = readPoint(relative: relative, from: current) {
            path.addLine(to: point)
            current = point
        }

        return true
    }

    private mutating func parseRepeatedHorizontalLines(
        into path: inout Path,
        current: inout CGPoint,
        relative: Bool
    ) -> Bool {
        guard let first = readNumber() else {
            return false
        }
        current.x = relative ? current.x + first : first
        path.addLine(to: current)

        while let value = readNumber() {
            current.x = relative ? current.x + value : value
            path.addLine(to: current)
        }

        return true
    }

    private mutating func parseRepeatedVerticalLines(
        into path: inout Path,
        current: inout CGPoint,
        relative: Bool
    ) -> Bool {
        guard let first = readNumber() else {
            return false
        }
        current.y = relative ? current.y + first : first
        path.addLine(to: current)

        while let value = readNumber() {
            current.y = relative ? current.y + value : value
            path.addLine(to: current)
        }

        return true
    }

    private mutating func parseRepeatedCurves(
        into path: inout Path,
        current: inout CGPoint,
        relative: Bool
    ) -> Bool {
        guard let first = readCurve(relative: relative, from: current) else {
            return false
        }
        path.addCurve(to: first.end, control1: first.control1, control2: first.control2)
        current = first.end

        while let curve = readCurve(relative: relative, from: current) {
            path.addCurve(to: curve.end, control1: curve.control1, control2: curve.control2)
            current = curve.end
        }

        return true
    }

    private mutating func readCurve(
        relative: Bool,
        from current: CGPoint
    ) -> (control1: CGPoint, control2: CGPoint, end: CGPoint)? {
        guard let x1 = readNumber(),
              let y1 = readNumber(),
              let x2 = readNumber(),
              let y2 = readNumber(),
              let x = readNumber(),
              let y = readNumber()
        else {
            return nil
        }

        let control1 = point(x: x1, y: y1, relative: relative, from: current)
        let control2 = point(x: x2, y: y2, relative: relative, from: current)
        let end = point(x: x, y: y, relative: relative, from: current)
        return (control1, control2, end)
    }

    private mutating func readPoint(relative: Bool, from current: CGPoint) -> CGPoint? {
        guard let x = readNumber(),
              let y = readNumber()
        else {
            return nil
        }
        return point(x: x, y: y, relative: relative, from: current)
    }

    private func point(x: CGFloat, y: CGFloat, relative: Bool, from current: CGPoint) -> CGPoint {
        if relative {
            return CGPoint(x: current.x + x, y: current.y + y)
        }
        return CGPoint(x: x, y: y)
    }

    private mutating func readCommand() -> Character? {
        guard index < tokens.count else {
            return nil
        }

        if case let .command(command) = tokens[index] {
            index += 1
            return command
        }

        return nil
    }

    private mutating func readNumber() -> CGFloat? {
        guard index < tokens.count else {
            return nil
        }

        if case let .number(number) = tokens[index] {
            index += 1
            return number
        }

        return nil
    }

    private static func tokenize(_ data: String) -> [Token] {
        let pattern = #"[MmLlHhVvCcZz]|[-+]?(?:(?:\d+\.?\d*)|(?:\.\d+))(?:[eE][-+]?\d+)?"#
        let expression = try! NSRegularExpression(pattern: pattern)
        let nsRange = NSRange(data.startIndex..<data.endIndex, in: data)

        return expression.matches(in: data, range: nsRange).compactMap { match in
            guard let range = Range(match.range, in: data) else {
                return nil
            }

            let token = String(data[range])
            if token.count == 1,
               let command = token.first,
               "MmLlHhVvCcZz".contains(command)
            {
                return .command(command)
            }

            guard let value = Double(token) else {
                return nil
            }
            return .number(CGFloat(value))
        }
    }
}
