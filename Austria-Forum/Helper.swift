//
//  Helper.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 30.09.16.
//  Copyright © 2016 Paul Neuhold. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit


public class Helper {
    
    
    ///Parsing the incoming userInfo from a Notification and returns a SearchResult
    ///Does not parse the License Info - since it will get loaded upon url loading in the getPageInfo Job
    class func getSearchResultNotificationUserInfoNoLicense (userinfo: [AnyHashable: Any]) -> SearchResult {
        
        return SearchResult(title   : userinfo["title"] as? String,
                            name    : userinfo["name"]  as? String,
                            url     : userinfo["url"]   as? String,
                            score: 100, licenseResult: .none )
        
        
    }
    
    class func fireNotificationWithInfosFromLocaionResult(lr : LocationArticleResult) {
        let content = UNMutableNotificationContent()
        
        content.title = "Es wurde ein Artikel in Ihrer Nähe gefunden!"
        content.body = "\(lr.title) befindet sich nur \(lr.distanceString) entfernt."
        var userInfo : [AnyHashable : String] = [:]
        userInfo["title"] = lr.title
        userInfo["name"] = lr.name
        userInfo["url"] = lr.url
        content.userInfo = userInfo
        
        let badgeNumber : NSNumber? = (UIApplication.shared.applicationIconBadgeNumber + 1 ) as NSNumber?
        content.badge = badgeNumber
        content.sound = UNNotificationSound.default()
        
        
        //Set the trigger of the notification -- here a timer.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        //Set the request for the notification from the above
        let request = UNNotificationRequest(
            identifier: "af.article",
            content: content,
            trigger: trigger
        )
        
        //Add the notification to the currnet notification center
        UNUserNotificationCenter.current().add(
            request, withCompletionHandler: nil)
    }
    
}
