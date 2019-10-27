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
    
    
     @available(iOS 10.0, *)
     class func notificationForiOS10(lr : LocationArticleResult) {
        
        
        
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
        content.sound = UNNotificationSound.default
        
        
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
    
    class func notificationForiOS9(lr: LocationArticleResult){
        let localNotification : UILocalNotification = UILocalNotification()
        localNotification.fireDate = Date()
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.alertBody = "\(lr.title) befindet sich nur \(lr.distanceString) entfernt."
        localNotification.timeZone = NSTimeZone.default
        localNotification.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
        //print("previous app badge number: \(UIApplication.sharedApplication().applicationIconBadgeNumber)")
                
        UIApplication.shared.scheduleLocalNotification(localNotification)
    }
    

    
    class func saveCurrentArticleAsFavourite(withCurrentUrl : URL?, andWithTitle title: String?, isWebBook webBook: Bool? = false) -> Bool{
        let pListWorker : ReadWriteToPList? = ReadWriteToPList()
        
        var  activeArticle : [String:String] = [:]
        
        if let activeArticleInWebView = SearchHolder.sharedInstance.selectedItem, let currentCategory = SearchHolder.sharedInstance.currentCategory {
            activeArticle["title"] = activeArticleInWebView.title
            activeArticle["url"] = activeArticleInWebView.url?.removeAFSkin()
            activeArticle["category"] = currentCategory
       
        } else if let activeUrlString = withCurrentUrl?.absoluteString, let activeTitle = SearchHolder.sharedInstance.currentTitle, let currentCategory = SearchHolder.sharedInstance.currentCategory {
            activeArticle["title"] = activeTitle
            activeArticle["url"] = activeUrlString.removeAFSkin()
            activeArticle["category"] = currentCategory
        
        } else if let activeUrlString = withCurrentUrl?.absoluteString , let currentCategory = SearchHolder.sharedInstance.currentCategory {
            activeArticle["title"] = withCurrentUrl?.path ?? activeUrlString
            activeArticle["url"] = activeUrlString.removeAFSkin()
            activeArticle["category"] = currentCategory
        }
        
        if let webBook = webBook {
            if webBook {
                
                activeArticle["title"] = title ?? withCurrentUrl?.path ?? withCurrentUrl?.absoluteString
                activeArticle["url"] = withCurrentUrl?.absoluteString.removeAFSkin()
                activeArticle["category"] = "Web Book"
                
            }
        }
        
        if !activeArticle.isEmpty {
            _ = pListWorker?.loadFavourites()
            if pListWorker?.isFavourite(activeArticle) == false {
                _ = pListWorker?.saveFavourite(activeArticle)
                Helper.trackAnalyticsEvent(withCategory: DetailViewController.answersEventAddFavs, action: activeArticle["title"]!, label: "\(activeArticle["url"]!)  \(activeArticle["category"]!)")
            } else {
                _ = pListWorker?.removeFavourite(activeArticle)
            }
            FavouritesHolder.sharedInstance.refresh()
            return true
        } else {
            print("No Article Loaded for saving as Favourite")
            return false
        }
    }
    
    class func trackViewControllerTitleToAnalytics(){
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
    class func trackAnalyticsEvent(withCategory: String, action: String, label: String = "") {
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
