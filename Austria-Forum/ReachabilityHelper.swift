//
//  ReachabilityHelper.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 14.12.15.
//  Copyright © 2015 Paul Neuhold. All rights reserved.
//

import Foundation
import ReachabilitySwift

enum ReachabilityType {
    case WIFI
    case CELLULAR
    case NO_INTERNET
}

class ReachabilityHelper {
    
    
    
    static let sharedInstance = ReachabilityHelper()
    var reachability : Reachability?
    
    var connection : ReachabilityType = .NO_INTERNET
    var delegate : ReachabilityDelegate?
    
    private init(){
        
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
            addObserver()
            try reachability?.startNotifier()
        } catch {
            print("Unable to create Reachability || Unable to startNotifier")
            return
        }
        
    }
    
    
    private func addObserver(){
        
        NSNotificationCenter.defaultCenter().addObserverForName(ReachabilityChangedNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: {
            notification in
            self.reachabilityChanged(notification)
        })
        
    }
    
    func reachabilityChanged(note: NSNotification) {
        
        let reachability = note.object as! Reachability
        
        if reachability.isReachable() {
            if reachability.isReachableViaWiFi() {
                print("Reachable via WiFi")
                self.connection = .WIFI
            } else {
                print("Reachable via Cellular")
                self.connection = .CELLULAR
            }
        } else {
            print("Not reachable")
            self.connection = .NO_INTERNET
            if let del = self.delegate {
                del.noInternet()
            }
            //No internet connection present a view
        }
    }
    
    func removeObserver(){
        reachability?.stopNotifier()
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: ReachabilityChangedNotification,
            object: reachability)
    }
    
    deinit {
        // in case the Object get deinit before we can remove the Observer in an apropiate way
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: ReachabilityChangedNotification,
            object: reachability)
    }
    
}

