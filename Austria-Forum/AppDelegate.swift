    //
//  AppDelegate.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 10.12.15.
//  Copyright © 2015 Paul Neuhold. All rights reserved.
//

import UIKit
import UserNotifications
    
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    var isGrantedNotificationAccess : Bool = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }
        
        // Handle launching with options
        if let launchOptions = launchOptions {
            //handle launching from significant Location Change
            if let _ = launchOptions[UIApplication.LaunchOptionsKey.location]{
                    MyLocationManager.sharedInstance.startAsResultTOLaunchFromLocationKey()
                    return true
                }
        }
        
        //start the Reachability Observer
        let _ : ReachabilityHelper = ReachabilityHelper.sharedInstance
        
     
        if UserData.sharedInstance.wasPushPermissionAsked! {
            MyLocationManager.sharedInstance.startIfAllowed()
        }
        
        application.applicationIconBadgeNumber = 0
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        if UserData.sharedInstance.wasPushPermissionAsked! {
            MyLocationManager.sharedInstance.startIfAllowed()
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        //remove the Observer
        ReachabilityHelper.sharedInstance.removeObserver()
        MyLocationManager.sharedInstance.startIfAllowed()
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Swift.Void){
        
        let notificationUserInfo : [AnyHashable : Any] = response.notification.request.content.userInfo
        
        let sr = Helper.getSearchResultNotificationUserInfoNoLicense(userinfo: notificationUserInfo)
        SearchHolder.sharedInstance.selectedItem = sr
        completionHandler()
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        print("didRevieceLocalNotification")
        if let sr = notification.userInfo{
            if let _ = sr["url"]{
                print("started with url: \(sr["url"] as! String)")
                //Note: We ignore the license for now - because we load it in getPageInfo afterwards anyway
                SearchHolder.sharedInstance.selectedItem = Helper.getSearchResultNotificationUserInfoNoLicense(userinfo: sr)
            }
        }
    }
}

