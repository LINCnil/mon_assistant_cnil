// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation
import UIKit

public typealias Image = UIImage

// swiftlint:disable all
public extension Image {
  static let app_gearshapeIcon = Asset.Images.gearshapeIcon.image
  static let app_listeningButtonBackground = Asset.Images.listeningButtonBackground.image
  static let app_listeningIcon = Asset.Images.listeningIcon.image
  static let app_microphoneButtonBackground = Asset.Images.microphoneButtonBackground.image
  static let app_microphoneIcon = Asset.Images.microphoneIcon.image
  static let app_nothingFoundIcon = Asset.Images.nothingFoundIcon.image
  static let app_processingButtonBackground = Asset.Images.processingButtonBackground.image
  static let app_radioButtonFilledIcon = Asset.Images.radioButtonFilledIcon.image
  static let app_radioButtonIcon = Asset.Images.radioButtonIcon.image
  static let app_sendIcon = Asset.Images.sendIcon.image
}

private enum Asset {
// Hint: to name 2 resources with the same name in different folders without colision,
// check "Provides Namespace" in the xcasset folder attributes
  enum Images {
    static let gearshapeIcon = ImageAsset(name: "GearshapeIcon")
    static let listeningButtonBackground = ImageAsset(name: "ListeningButtonBackground")
    static let listeningIcon = ImageAsset(name: "ListeningIcon")
    static let microphoneButtonBackground = ImageAsset(name: "MicrophoneButtonBackground")
    static let microphoneIcon = ImageAsset(name: "MicrophoneIcon")
    static let nothingFoundIcon = ImageAsset(name: "NothingFoundIcon")
    static let processingButtonBackground = ImageAsset(name: "ProcessingButtonBackground")
    static let radioButtonFilledIcon = ImageAsset(name: "RadioButtonFilledIcon")
    static let radioButtonIcon = ImageAsset(name: "RadioButtonIcon")
    static let sendIcon = ImageAsset(name: "SendIcon")
  }
}

private struct ImageAsset {
  var name: String

  var image: Image {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else { fatalError("Unable to load image named \(name).") }
    return result
  }
}

private extension Image {
  @available(iOS 1.0, tvOS 1.0, watchOS 1.0, *)
  convenience init!(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = Bundle(for: BundleToken.self)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

private final class BundleToken {}
