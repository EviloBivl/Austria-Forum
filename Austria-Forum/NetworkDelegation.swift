//
//  NetworkDelegation.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 11.12.15.
//  Copyright © 2015 Paul Neuhold. All rights reserved.
//

import Foundation

/** NetworkDelegation protocol

*/
@objc
protocol NetworkDelegation : class{
    
    func onRequestFailed();
    func onRequestSuccess(_ from: String);
    @objc optional func noInternet();

}

protocol PageInfoDelegate {
    func onPageInfoSuccess();
    func onPageInfoFail();

}


protocol LocationControllerDelegate : class {
    func receivedPermissionResult()
}

protocol OptionsLocationDelegate : class {
    func receivedAlwaysPermissions()
}

protocol LocationErrorDelegate : class {
    func receivedErrorFromLocationManager()
}
