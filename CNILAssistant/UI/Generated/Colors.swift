// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation
import UIKit

public typealias Color = UIColor

// swiftlint:disable all
public extension Color {
  static let app_background = Asset.Colors.background.color
  static let app_buttonBackground = Asset.Colors.Button.background.color
  static let app_buttonFillButtonTint = Asset.Colors.Button.fillButtonTint.color
  static let app_buttonOptionBackground = Asset.Colors.Button.optionBackground.color
  static let app_buttonOptionBorder = Asset.Colors.Button.optionBorder.color
  static let app_buttonTint = Asset.Colors.Button.tint.color
  static let app_labelPrimary = Asset.Colors.Label.primary.color
  static let app_labelQuaternary = Asset.Colors.Label.quaternary.color
  static let app_labelSecondary = Asset.Colors.Label.secondary.color
  static let app_labelTertiary = Asset.Colors.Label.tertiary.color
  static let app_secondaryBackground = Asset.Colors.secondaryBackground.color
  static let app_separator = Asset.Colors.separator.color
  static let app_textInputPlaceholder = Asset.Colors.TextInput.placeholder.color
  static let app_textInputPrimary = Asset.Colors.TextInput.primary.color
  static let app_tint = Asset.Colors.tint.color
}

private enum Asset {
// Hint: to name 2 resources with the same name in different folders without colision,
// check "Provides Namespace" in the xcasset folder attributes
  enum Colors {
    static let background = ColorAsset(name: "Background")
    enum Button {
      static let background = ColorAsset(name: "Button/Background")
      static let fillButtonTint = ColorAsset(name: "Button/FillButtonTint")
      static let optionBackground = ColorAsset(name: "Button/OptionBackground")
      static let optionBorder = ColorAsset(name: "Button/OptionBorder")
      static let tint = ColorAsset(name: "Button/Tint")
    }
    enum Label {
      static let primary = ColorAsset(name: "Label/Primary")
      static let quaternary = ColorAsset(name: "Label/Quaternary")
      static let secondary = ColorAsset(name: "Label/Secondary")
      static let tertiary = ColorAsset(name: "Label/Tertiary")
    }
    static let secondaryBackground = ColorAsset(name: "SecondaryBackground")
    static let separator = ColorAsset(name: "Separator")
    enum TextInput {
      static let placeholder = ColorAsset(name: "TextInput/Placeholder")
      static let primary = ColorAsset(name: "TextInput/Primary")
    }
    static let tint = ColorAsset(name: "Tint")
  }
}

private struct ColorAsset {
  fileprivate(set) var name: String

  var color: Color {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    let color = Color(named: name, in: bundle, compatibleWith: nil)
    #elseif os(watchOS)
    let color = Color(named: name)
    #endif
    guard let result = color else { fatalError("Unable to load color named \(name).") }
    return result
  }
}

private final class BundleToken {}
