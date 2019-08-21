// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable sorted_imports
import Foundation
import UIKit

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

internal protocol StoryboardType {
  static var storyboardName: String { get }
}

internal extension StoryboardType {
  static var storyboard: UIStoryboard {
    let name = self.storyboardName
    return UIStoryboard(name: name, bundle: Bundle(for: BundleToken.self))
  }
}

internal struct SceneType<T: Any> {
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

internal struct InitialSceneType<T: Any> {
  internal let storyboard: StoryboardType.Type

  internal func instantiate() -> T {
    guard let controller = storyboard.storyboard.instantiateInitialViewController() as? T else {
      fatalError("ViewController is not of the expected class \(T.self).")
    }
    return controller
  }
}

internal protocol SegueType: RawRepresentable { }

internal extension UIViewController {
  func perform<S: SegueType>(segue: S, sender: Any? = nil) where S.RawValue == String {
    let identifier = segue.rawValue
    performSegue(withIdentifier: identifier, sender: sender)
  }
}

// swiftlint:disable explicit_type_interface identifier_name line_length type_body_length type_name
internal enum StoryboardScene {
  internal enum AboutViewController: StoryboardType {
    internal static let storyboardName = "AboutViewController"

    internal static let aboutViewController = SceneType<Austria_Forum.AboutViewController>(storyboard: AboutViewController.self, identifier: "AboutViewController")
  }
  internal enum FavouriteViewController: StoryboardType {
    internal static let storyboardName = "FavouriteViewController"

    internal static let favouritesTableViewController = SceneType<Austria_Forum.FavouritesTableViewController>(storyboard: FavouriteViewController.self, identifier: "FavouritesTableViewController")
  }
  internal enum LaunchScreen: StoryboardType {
    internal static let storyboardName = "LaunchScreen"

    internal static let initialScene = InitialSceneType<UIViewController>(storyboard: LaunchScreen.self)
  }
  internal enum Main: StoryboardType {
    internal static let storyboardName = "Main"

    internal static let initialScene = InitialSceneType<UINavigationController>(storyboard: Main.self)
  }
  internal enum NearbyArticlesViewController: StoryboardType {
    internal static let storyboardName = "NearbyArticlesViewController"

    internal static let nearbyArticlesViewController = SceneType<Austria_Forum.NearbyArticlesViewController>(storyboard: NearbyArticlesViewController.self, identifier: "NearbyArticlesViewController")
  }
  internal enum SearchViewController: StoryboardType {
    internal static let storyboardName = "SearchViewController"

    internal static let searchTableViewController = SceneType<Austria_Forum.SearchTableViewController>(storyboard: SearchViewController.self, identifier: "SearchTableViewController")
  }
  internal enum SettingsViewController: StoryboardType {
    internal static let storyboardName = "SettingsViewController"

    internal static let settingsViewController = SceneType<Austria_Forum.SettingsViewController>(storyboard: SettingsViewController.self, identifier: "SettingsViewController")
  }
}

internal enum StoryboardSegue {
}
// swiftlint:enable explicit_type_interface identifier_name line_length type_body_length type_name

private final class BundleToken {}

