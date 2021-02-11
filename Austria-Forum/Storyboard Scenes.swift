// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable sorted_imports
import Foundation
import UIKit

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Storyboard Scenes

// swiftlint:disable explicit_type_interface identifier_name line_length type_body_length type_name
internal enum StoryboardScene {
  internal enum About: StoryboardType {
    internal static let storyboardName = "About"

    internal static let aboutViewController = SceneType<Austria_Forum.AboutViewController>(storyboard: About.self, identifier: "AboutViewController")
  }
  internal enum FavouriteViewController: StoryboardType {
    internal static let storyboardName = "FavouriteViewController"

    internal static let favouritesTableViewController = SceneType<Austria_Forum.FavouritesTableViewController>(storyboard: FavouriteViewController.self, identifier: "FavouritesTableViewController")
  }
  internal enum LaunchScreen: StoryboardType {
    internal static let storyboardName = "LaunchScreen"

    internal static let initialScene = InitialSceneType<UIKit.UIViewController>(storyboard: LaunchScreen.self)
  }
  internal enum LibLicenses: StoryboardType {
    internal static let storyboardName = "LibLicenses"

    internal static let licenseViewController = SceneType<Austria_Forum.LicenseViewController>(storyboard: LibLicenses.self, identifier: "LicenseViewController")
  }
  internal enum LocationArticlesViewController: StoryboardType {
    internal static let storyboardName = "LocationArticlesViewController"

    internal static let locationArticlesViewController = SceneType<Austria_Forum.LocationArticlesViewController>(storyboard: LocationArticlesViewController.self, identifier: "LocationArticlesViewController")
  }
  internal enum Main: StoryboardType {
    internal static let storyboardName = "Main"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: Main.self)
  }
  internal enum NearbyArticles: StoryboardType {
    internal static let storyboardName = "NearbyArticles"
  }
  internal enum PopoverViewController: StoryboardType {
    internal static let storyboardName = "PopoverViewController"

    internal static let popoverViewController = SceneType<Austria_Forum.PopoverViewController>(storyboard: PopoverViewController.self, identifier: "PopoverViewController")
  }
  internal enum SearchViewController: StoryboardType {
    internal static let storyboardName = "SearchViewController"

    internal static let searchTableViewController = SceneType<Austria_Forum.SearchTableViewController>(storyboard: SearchViewController.self, identifier: "SearchTableViewController")
  }
  internal enum Settings: StoryboardType {
    internal static let storyboardName = "Settings"

    internal static let settingsViewController = SceneType<Austria_Forum.SettingsViewController>(storyboard: Settings.self, identifier: "SettingsViewController")
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length type_body_length type_name

// MARK: - Implementation Details

internal protocol StoryboardType {
  static var storyboardName: String { get }
}

internal extension StoryboardType {
  static var storyboard: UIStoryboard {
    let name = self.storyboardName
    return UIStoryboard(name: name, bundle: Bundle(for: BundleToken.self))
  }
}

internal struct SceneType<T: UIViewController> {
  internal let storyboard: StoryboardType.Type
  internal let identifier: String

  internal func instantiate() -> T {
    let identifier = self.identifier
    guard let controller = storyboard.storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
      fatalError("ViewController '\(identifier)' is not of the expected class \(T.self).")
    }
    return controller
  }
}

internal struct InitialSceneType<T: UIViewController> {
  internal let storyboard: StoryboardType.Type

  internal func instantiate() -> T {
    guard let controller = storyboard.storyboard.instantiateInitialViewController() as? T else {
      fatalError("ViewController is not of the expected class \(T.self).")
    }
    return controller
  }
}

private final class BundleToken {}
