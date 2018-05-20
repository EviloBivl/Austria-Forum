// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// swiftlint:disable explicit_type_interface identifier_name line_length nesting type_body_length type_name
enum L10n {
  /// austria-forum.org
  static let afShortUrl = L10n.tr("localizables", "AF_SHORT_URL")
  /// Austria-Forum
  static let appTitle = L10n.tr("localizables", "APP_TITLE")
  /// The Content shown in this App is provided by the 
  static let contentAllContentFromAf = L10n.tr("localizables", "CONTENT_ALL_CONTENT_FROM_AF")
  /// The icons used in the toolbars are provided by 
  static let contentIconsSource = L10n.tr("localizables", "CONTENT_ICONS_SOURCE")
  /// http://www.icons8.com
  static let icons8UrlSource = L10n.tr("localizables", "ICONS8_URL_SOURCE")
  /// icons8.com
  static let icons8UrlText = L10n.tr("localizables", "ICONS8_URL_TEXT")
  /// https://github.com/Alamofire/Alamofire/blob/master/LICENSE
  static let licenseAlmofire = L10n.tr("localizables", "LICENSE_ALMOFIRE")
  /// https://fabric.io/privacy
  static let licenseFabric = L10n.tr("localizables", "LICENSE_FABRIC")
  /// https://github.com/ashleymills/Reachability.swift/blob/master/LICENSE
  static let licenseReachability = L10n.tr("localizables", "LICENSE_REACHABILITY")
  /// https://github.com/SwiftyJSON/SwiftyJSON/blob/master/LICENSE
  static let licenseSwiftyjson = L10n.tr("localizables", "LICENSE_SWIFTYJSON")
  /// About the Austria-Forum App
  static let navTitleAboutLong = L10n.tr("localizables", "NAV_TITLE_ABOUT_LONG")
  /// About A-F
  static let navTitleAboutShort = L10n.tr("localizables", "NAV_TITLE_ABOUT_SHORT")
  /// Settings
  static let navTitleSettings = L10n.tr("localizables", "NAV_TITLE_SETTINGS")
  /// Alamofire
  static let titleAlalmofire = L10n.tr("localizables", "TITLE_ALALMOFIRE")
  /// Api development
  static let titleApiDev = L10n.tr("localizables", "TITLE_API_DEV")
  /// App development
  static let titleAppDev = L10n.tr("localizables", "TITLE_APP_DEV")
  /// Developers
  static let titleDevelopers = L10n.tr("localizables", "TITLE_DEVELOPERS")
  /// Fabric
  static let titleFabric = L10n.tr("localizables", "TITLE_FABRIC")
  /// License
  static let titleLicense = L10n.tr("localizables", "TITLE_LICENSE")
  /// Reachability
  static let titleReachability = L10n.tr("localizables", "TITLE_REACHABILITY")
  /// SwiftyJSON
  static let titleSwiftyjson = L10n.tr("localizables", "TITLE_SWIFTYJSON")
  /// Contents
  static let titleUsedContent = L10n.tr("localizables", "TITLE_USED_CONTENT")
  /// Used Icons
  static let titleUsedIcons = L10n.tr("localizables", "TITLE_USED_ICONS")
  /// Used libraries
  static let titleUsedLibs = L10n.tr("localizables", "TITLE_USED_LIBS")
  /// Version
  static let titleVersion = L10n.tr("localizables", "TITLE_VERSION")
  /// https://github.com/Alamofire/Alamofire
  static let urlAlalmofire = L10n.tr("localizables", "URL_ALALMOFIRE")
  /// https://fabric.io
  static let urlFabric = L10n.tr("localizables", "URL_FABRIC")
  /// https://github.com/ashleymills/Reachability.swift
  static let urlReachability = L10n.tr("localizables", "URL_REACHABILITY")
  /// https://github.com/SwiftyJSON/SwiftyJSON
  static let urlSwiftyjson = L10n.tr("localizables", "URL_SWIFTYJSON")
}
// swiftlint:enable explicit_type_interface identifier_name line_length nesting type_body_length type_name

extension L10n {
  fileprivate static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}

