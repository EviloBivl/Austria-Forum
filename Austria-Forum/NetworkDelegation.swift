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
    
    func onRequestFailed();
    func onRequestSuccess();

}

protocol PageInfoDelegate {
    func onPageInfoSucces();
    func onPageInfoFail();

}
