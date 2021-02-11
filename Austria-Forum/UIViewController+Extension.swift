//
//  UIViewController+Extension.swift
//  Austria-Forum
//
//  Created by Paul Neuhold Privat on 01.02.20.
//  Copyright © 2020 Paul Neuhold. All rights reserved.
//

import Foundation
import UIKit
import PKHUD
import SwiftEntryKit

extension UIViewController: ReachabilityDelegate {
    func InternetBack() {
        
    }
    
    @objc public func noInternet() {
        HUD.flash(.label("Bitte überprüfe deine Internetverbindung."), delay: 2)
    }
}

extension UIViewController {
    public func showLoadingScreen(withGracePeriod: Bool = true){
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.gracePeriod = withGracePeriod ? 1.0 : 0
        PKHUD.sharedHUD.show()
    }
    
    func hideLoadingScreen() {
        PKHUD.sharedHUD.hide()
    }
    
    func flashErrorMessage(title: String?, message: String?) {
        HUD.flash(.labeledError(title: title, subtitle: message), delay: 2)
    }
}

extension UIViewController {
    ///triggers a pushPopover and either asks for the push via system or delegates to app settings
    public func askForPushPermission(didAsk: (()->Void)? = nil, didNotAsk: (()->Void)? = nil ) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings(completionHandler: {
            settings in
            let buttonAction = settings.authorizationStatus == .notDetermined
                ? self.dismissSwiftEntryAndRequestPermission
                : self.dismissSwiftEntryKitAndGoToSettings
            
            if settings.authorizationStatus == .notDetermined
                || settings.authorizationStatus == .denied {
                DispatchQueue.main.async {
                    let viewModel = PopoverModel(type: .push,
                                                 buttonAction: buttonAction,
                                                 buttonSkipAction: { SwiftEntryKit.dismiss() })
                    let controller = PopoverViewController.create(viewModel: viewModel)
                    self.swiftEntryPopover(of: controller)
                    didAsk?()
                }
            } else {
                DispatchQueue.main.async {
                    didNotAsk?()
                }
            }
        })
    }
    
    private func requestPushPermissionAndRegister() {
        DispatchQueue.main.async {
            // set the delegate if needed then ask if we are authorized - the delegate must be set here if used
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {(_ granted: Bool, _ error: Error?) -> Void in
                if error == nil {
                    UserData.sharedInstance.allowPushNotification = granted
                }
            })
        }
    }
    
    private func dismissSwiftEntryAndRequestPermission() {
        SwiftEntryKit.dismiss()
        requestPushPermissionAndRegister()
    }
    
    private func dismissSwiftEntryKitAndGoToSettings() {
        SwiftEntryKit.dismiss()
        openAppSettings()
    }
    
    public func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: nil)
        }
    }
}

extension UIViewController {
    public func swiftEntryPopover(of controller: UIViewController, with attributes: EKAttributes? = nil) {
        if let attributes = attributes {
            if !SwiftEntryKit.isCurrentlyDisplaying {
                SwiftEntryKit.display(entry: controller, using: attributes)
            }
            return
        }
        
        var attributes = EKAttributes.centerFloat
        
        let backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        attributes.hapticFeedbackType = .success
        attributes.displayDuration = .infinity
        attributes.entryBackground = .color(color: EKColor(.white))
        attributes.screenBackground = .color(color: EKColor(backgroundColor))
        attributes.screenInteraction = .dismiss
        attributes.entryInteraction = .absorbTouches
        attributes.roundCorners = .all(radius: 15)
        let widthConstraint = EKAttributes.PositionConstraints.Edge.ratio(value: 0.9)
        let heightConstraint = EKAttributes.PositionConstraints.Edge.ratio(value: 0.8)
        attributes.positionConstraints.size = .init(width: widthConstraint, height: heightConstraint)
        attributes.positionConstraints.safeArea = .empty(fillSafeArea: false)
        
        attributes.shadow = .active(
            with: .init(
                color: .black,
                opacity: 0.3,
                radius: 2
            )
        )
        
        attributes.scroll = .disabled
        
        attributes.entranceAnimation = .init(
            translate: .init(duration: 0),
            scale: .init(
                from: 0.9,
                to: 1,
                duration: 0.2,
                spring: .init(damping: 1, initialVelocity: 0)
            ),
            fade: .init(from: 0, to: 1, duration: 0.2)
        )
        
        attributes.exitAnimation = .init(
            scale: .init(from: 1, to: 0.9, duration: 0.1),
            fade: .init(from: 1, to: 0, duration: 0.1)
        )
        
        attributes.entryBackground = .color(color: .white)
        
        if !SwiftEntryKit.isCurrentlyDisplaying {
            SwiftEntryKit.display(entry: controller, using: attributes)
        }
    }
}
