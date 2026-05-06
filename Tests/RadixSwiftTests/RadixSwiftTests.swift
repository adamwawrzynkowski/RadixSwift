import Testing
@testable import RadixSwift

@Test func generatedRadixAssetsArePresent() {
    #expect(RadixIconName.allCases.count == 332)
    #expect(RadixThemeComponentName.allCases.count == 58)
    #expect(RadixPrimitiveName.allCases.count == 58)
    #expect(RadixColorCatalog.shared.exportNames.count == 252)
}

@MainActor
@Test func radixIconSVGResourcesParseIntoDrawableDefinitions() {
    for icon in RadixIconName.allCases {
        let definition = RadixIconLoader.definition(named: icon)
        #expect(definition != nil)
        #expect(definition?.primitives.isEmpty == false)
    }
}

@Test func radixThemeMatchesDefaultWebConfiguration() {
    let theme = RadixThemeValues()
    #expect(theme.accentColor == .indigo)
    #expect(theme.grayColor == .auto)
    #expect(theme.resolvedGrayColor() == .slate)
    #expect(theme.radius == .medium)
    #expect(theme.scaling == .normal)
}

@Test func radixAnimationSettingsExposeMotionRoles() {
    let settings = RadixAnimationSettings.default

    #expect(RadixAnimationRole.allCases.count == 9)
    #expect(settings.isEnabled)
    #expect(settings.durationScale == 1)
    #expect(settings.spec(for: .press).duration == 0.08)
    #expect(settings.spec(for: .spinner).curve == .linear)
    #expect(RadixAnimationSettings.none.isEnabled == false)
    #expect(RadixAnimationSettings.slow.durationScale == 1.6)
}
