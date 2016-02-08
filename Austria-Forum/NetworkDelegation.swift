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
protocol NetworkDelegation {
    
    func onRequestFailed(from: String?);
    func onRequestSuccess(from: String?);

}

protocol PageInfoDelegate {
    func onPageInfoSuccess();
    func onPageInfoFail();

}
