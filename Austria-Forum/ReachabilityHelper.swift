//
//  ReachabilityHelper.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 14.12.15.
//  Copyright © 2015 Paul Neuhold. All rights reserved.
//

import Foundation
import Reachability

enum ReachabilityType {
    case wifi
    case cellular
    case no_INTERNET
}

class ReachabilityHelper {
    static let sharedInstance = ReachabilityHelper()
    var reachability : Reachability?
    
    var connection : ReachabilityType = .no_INTERNET
    var delegate : ReachabilityDelegate?
    
    fileprivate init(){
        
        do {
            reachability =  Reachability.init()
            addObserver()
            try reachability?.startNotifier()
        } catch {
            print("Unable to create Reachability || Unable to startNotifier")
            return
        }
    }
    
    fileprivate func addObserver(){
        NotificationCenter.default.addObserver(forName: Notification.Name.reachabilityChanged, object: nil, queue: OperationQueue.main, using: {
            notification in
            self.reachabilityChanged(notification)
        })
        
    }
    
    func reachabilityChanged(_ note: Notification) {
        let reachability = note.object as! Reachability
        switch reachability.connection {
        case .wifi:
            self.connection = .wifi
            delegate?.InternetBack()
        case .cellular:
            self.connection = .cellular
            delegate?.InternetBack()
        case .none:
            self.connection = .no_INTERNET
            delegate?.noInternet()
        }
    }
    
    func removeObserver(){
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self,
                                                  name: Notification.Name.reachabilityChanged,
                                                  object: reachability)
    }
}

