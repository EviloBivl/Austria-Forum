//
//  ViewController+Extension.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 17.04.16.
//  Copyright © 2016 Paul Neuhold. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    ///not working at the moment due to memory leaks from Analytics SDK
    func trackViewControllerTitleToAnalytics(){
//        let tracker = GAI.sharedInstance().defaultTracker
//        
//        if let title = self.title {
//            print("Sending Title: \(title) to Analytics")
//            tracker.set(kGAIScreenName, value: title)
//            let builder = GAIDictionaryBuilder.createScreenView()
//            tracker.send(builder.build() as [NSObject : AnyObject])
//        }
    }
    
    ///not working at the moment due to memory leaks from Analytics SDK
    func trackAnalyticsEvent(withCategory: String, action: String, label: String = "") {
//        let tracker = GAI.sharedInstance().defaultTracker
//    
//        if label != "" {
//            let builder = GAIDictionaryBuilder.createEventWithCategory(withCategory, action: action, label: label, value: nil)
//            tracker.send(builder.build() as [NSObject : AnyObject])
//        } else {
//            let builder = GAIDictionaryBuilder.createEventWithCategory(withCategory, action: action, label: label, value: nil)
//            tracker.send(builder.build() as [NSObject : AnyObject])
//        }
        
    }
    
}
