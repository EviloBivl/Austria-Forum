// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// swiftlint:disable explicit_type_interface identifier_name line_length nesting type_body_length type_name
internal enum L10n {
  /// austria-forum.org
  internal static let afShortUrl = L10n.tr("localizables", "AF_SHORT_URL")
  /// Austria-Forum
  internal static let appTitle = L10n.tr("localizables", "APP_TITLE")
  /// The Content shown in this App is provided by the 
  internal static let contentAllContentFromAf = L10n.tr("localizables", "CONTENT_ALL_CONTENT_FROM_AF")
  /// The icons used in the toolbars are provided by 
  internal static let contentIconsSource = L10n.tr("localizables", "CONTENT_ICONS_SOURCE")
  /// http://www.icons8.com
  internal static let icons8UrlSource = L10n.tr("localizables", "ICONS8_URL_SOURCE")
  /// icons8.com
  internal static let icons8UrlText = L10n.tr("localizables", "ICONS8_URL_TEXT")
  /// https://github.com/Alamofire/Alamofire/blob/master/LICENSE
  internal static let licenseAlmofire = L10n.tr("localizables", "LICENSE_ALMOFIRE")
  /// https://fabric.io/privacy
  internal static let licenseFabric = L10n.tr("localizables", "LICENSE_FABRIC")
  /// https://github.com/ashleymills/Reachability.swift/blob/master/LICENSE
  internal static let licenseReachability = L10n.tr("localizables", "LICENSE_REACHABILITY")
  /// https://github.com/SwiftyJSON/SwiftyJSON/blob/master/LICENSE
  internal static let licenseSwiftyjson = L10n.tr("localizables", "LICENSE_SWIFTYJSON")
  /// About the Austria-Forum App
  internal static let navTitleAboutLong = L10n.tr("localizables", "NAV_TITLE_ABOUT_LONG")
  /// About A-F
  internal static let navTitleAboutShort = L10n.tr("localizables", "NAV_TITLE_ABOUT_SHORT")
  /// Settings
  internal static let navTitleSettings = L10n.tr("localizables", "NAV_TITLE_SETTINGS")
  /// How much time should be passed before a possible notification will be triggered
  internal static let settingsTitlePushinterval = L10n.tr("localizables", "SETTINGS_TITLE_PUSHINTERVAL")
  /// Alamofire
  internal static let titleAlalmofire = L10n.tr("localizables", "TITLE_ALALMOFIRE")
  /// Api development
  internal static let titleApiDev = L10n.tr("localizables", "TITLE_API_DEV")
  /// App development
  internal static let titleAppDev = L10n.tr("localizables", "TITLE_APP_DEV")
  /// Developers
  internal static let titleDevelopers = L10n.tr("localizables", "TITLE_DEVELOPERS")
  /// Fabric
  internal static let titleFabric = L10n.tr("localizables", "TITLE_FABRIC")
  /// License
  internal static let titleLicense = L10n.tr("localizables", "TITLE_LICENSE")
  /// Reachability
  internal static let titleReachability = L10n.tr("localizables", "TITLE_REACHABILITY")
  /// SwiftyJSON
  internal static let titleSwiftyjson = L10n.tr("localizables", "TITLE_SWIFTYJSON")
  /// Contents
  internal static let titleUsedContent = L10n.tr("localizables", "TITLE_USED_CONTENT")
  /// Used Icons
  internal static let titleUsedIcons = L10n.tr("localizables", "TITLE_USED_ICONS")
  /// Used libraries
  internal static let titleUsedLibs = L10n.tr("localizables", "TITLE_USED_LIBS")
  /// Version
  internal static let titleVersion = L10n.tr("localizables", "TITLE_VERSION")
  /// https://github.com/Alamofire/Alamofire
  internal static let urlAlalmofire = L10n.tr("localizables", "URL_ALALMOFIRE")
  /// https://fabric.io
  internal static let urlFabric = L10n.tr("localizables", "URL_FABRIC")
  /// https://github.com/ashleymills/Reachability.swift
  internal static let urlReachability = L10n.tr("localizables", "URL_REACHABILITY")
  /// https://github.com/SwiftyJSON/SwiftyJSON
  internal static let urlSwiftyjson = L10n.tr("localizables", "URL_SWIFTYJSON")
}
// swiftlint:enable explicit_type_interface identifier_name line_length nesting type_body_length type_name

extension L10n {
  fileprivate static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}

