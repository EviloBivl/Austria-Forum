    //
//  AppDelegate.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 10.12.15.
//  Copyright © 2015 Paul Neuhold. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import UserNotifications
    
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    var isGrantedNotificationAccess : Bool = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UNUserNotificationCenter.current().delegate = self
        
        // Handle launching with options
        if let launchOptions = launchOptions {
            //handle launching from significant Location Change
            if let _ = launchOptions[UIApplicationLaunchOptionsKey.location]{
                    MyLocationManager.sharedInstance.startAsResultTOLaunchFromLocationKey()
                    return true
                }
        }
        
        //start the Reachability Observer
        let _ : ReachabilityHelper = ReachabilityHelper.sharedInstance
        
        //init crashlytics
        Fabric.with([Crashlytics.self])
        self.logUser()
        
        if UserData.sharedInstance.wasPushPermissionAsked! {
            MyLocationManager.sharedInstance.startIfAllowed()
        }
        
        application.applicationIconBadgeNumber = 0
        return true
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
        
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        if UserData.sharedInstance.wasPushPermissionAsked! {
            MyLocationManager.sharedInstance.startIfAllowed()
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        //remove the Observer
        print("will Terminate")
        ReachabilityHelper.sharedInstance.removeObserver()
        MyLocationManager.sharedInstance.startIfAllowed()
        
    }
    
  

    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Swift.Void){
        
        let notificationUserInfo : [AnyHashable : Any] = response.notification.request.content.userInfo
        
        let sr = Helper.getSearchResultNotificationUserInfoNoLicense(userinfo: notificationUserInfo)
        SearchHolder.sharedInstance.selectedItem = sr
        Answers.logCustomEvent(withName: DetailViewController.answersEventFromPush, customAttributes: ["Article" : notificationUserInfo["title"], "Distance" : notificationUserInfo["distance"]])
        
        completionHandler()
    }
    
    func logUser() {
        let name = UIDevice.current.name
        let model = UIDevice.current.model
        let iosVersion = UIDevice.current.systemVersion
        let user = "\(name) - \(model) - iOS:\(iosVersion)"
        Crashlytics.sharedInstance().setUserName(user)
    }
    
//    func fireNotificationFromTerminated(){
//        let localNotification : UILocalNotification = UILocalNotification()
//        //==
//        let calendar = NSCalendar.init(calendarIdentifier: NSCalendarIdentifierGregorian)
//        let currentHour = (calendar?.component(NSCalendarUnit.Hour, fromDate: NSDate()))!
//        let currentMinute = (calendar?.component(NSCalendarUnit.Minute, fromDate: NSDate()))!
//        let currentSecond = (calendar?.component(NSCalendarUnit.Second, fromDate: NSDate()))!
//        //let writer = ReadWriteToPList()
//        //writer.loadFavourites()
//        //==
//        
//        localNotification.fireDate = NSDate()
//        localNotification.soundName = UILocalNotificationDefaultSoundName
//        localNotification.alertBody = "Push From Terminated - \(currentHour):\(currentMinute):\(currentSecond)"
//        localNotification.timeZone = NSTimeZone.defaultTimeZone()
//        localNotification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
//        //print("previous app badge number: \(UIApplication.sharedApplication().applicationIconBadgeNumber)")
//        
//        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
//
//    }
    
    //this is so iOS 9 and shall be refactored ignored for now
    /*
     func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
     print("didRevieceLocalNotification")
     if let sr = notification.userInfo{
     if let _ = sr["url"]{
     print("started with url: \(sr["url"] as! String)")
     //Note: We ignore the license for now - because we load it in getPageInfo afterwards anyway
     SearchHolder.sharedInstance.selectedItem = Helper.getSearchResultNotificationUserInfoNoLicense(userinfo: sr)
     Answers.logCustomEvent(withName: DetailViewController.answersEventFromPush, customAttributes: ["Article" : sr["title"]!, "Distance" : sr["distance"]! ])
     
     }
     }
     }
     */
    
}

