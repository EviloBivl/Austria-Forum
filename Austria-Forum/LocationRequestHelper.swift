//
//  LocationHelper.swift
//  Cashback
//
//  Created by Paul Neuhold on 20.11.19.
//  Copyright © 2019 myWorld Solutions AG. All rights reserved.
//

import Foundation
import SwiftEntryKit
import UIKit
import CoreLocation

public class LocationRequestHelper {
    
    weak var executingController: UIViewController?
    var locationManager = MyLocationManager.sharedInstance
    
    init(executingController: UIViewController){
        self.executingController = executingController
    }
    
    @discardableResult
    func showGPSPopover() -> Bool {
        if locationManager.authorizationStatus == .notDetermined ||
        locationManager.authorizationStatus == .denied {
            let viewModel = PopoverModel(type: .location,
                                         buttonAction: buttonAction(),
                                         buttonSkipAction: { SwiftEntryKit.dismiss() })
            let controller = PopoverViewController.create(viewModel: viewModel)
            executingController?.swiftEntryPopover(of: controller)
            return true
        } 
        return false
    }
    
    @discardableResult
    func showGPSPopoverForAlwaysPermission() -> Bool {
        if locationManager.authorizationStatus != .authorizedAlways {
            let viewModel = PopoverModel(type: .location,
                                         buttonAction: buttonActionForAlways(),
                                         buttonSkipAction: { SwiftEntryKit.dismiss() })
            let controller = PopoverViewController.create(viewModel: viewModel)
            executingController?.swiftEntryPopover(of: controller)
            return true
        }
        return false
    }
    
    private func buttonActionForAlways() -> (() -> Void)  {
        if locationManager.authorizationStatus == .notDetermined {
            return { [weak self] in
                SwiftEntryKit.dismiss()
                self?.locationManager.requestAlways()
            }
        } else if !(locationManager.authorizationStatus == .authorizedAlways)  {
            return { [weak self] in
                SwiftEntryKit.dismiss()
                self?.executingController?.openAppSettings()
            }
        }
        return { SwiftEntryKit.dismiss() }
    }
    
    private func buttonAction() -> (() -> Void) {
        if locationManager.authorizationStatus == .notDetermined {
            return { [weak self] in
                SwiftEntryKit.dismiss()
                self?.locationManager.requestWhenInUse()
            }
        } else if locationManager.authorizationStatus == .denied {
            return { [weak self] in
                SwiftEntryKit.dismiss()
                self?.executingController?.openAppSettings()
            }
        }
        return { SwiftEntryKit.dismiss() }
    }
}
