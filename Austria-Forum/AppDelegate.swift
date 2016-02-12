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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        //start the Reachability Observer
        let _ : ReachabilityHelper = ReachabilityHelper.sharedInstance
        //for crashlytics
        Fabric.with([Crashlytics.self])
        // TODO: Move this to where you establish a user session
        self.logUser()
        
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert,  UIUserNotificationType.Badge , UIUserNotificationType.Sound], categories: nil))
        application.applicationIconBadgeNumber = 0
        
        // Handle launching from a notification
        // TODO Here
        if let launchOptions = launchOptions {
            if let _ = launchOptions[UIApplicationLaunchOptionsLocationKey]{
                MyLocationManager.sharedInstance.startFromTerminated()
            }
            if let notification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification{
                if let sr = notification.userInfo{
                    print("started with url: \(sr["url"])")
                    SearchHolder.sharedInstance.selectedItem = SearchResult(title: sr["title"] as! String , name: sr["name"] as! String , url: sr["url"] as! String, score: 100, license: sr["license"] as! String?)
                }
            }
        } else {
            MyLocationManager.sharedInstance.startIfAllowed()
        }
        //Start the LocalizationManager
        //    print("restarting locaiton Manager now")
        //    MyLocationManager.sharedInstance.startFromTerminated()
        print("APP STARTED")
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        //print("Application state : \(application.applicationState.rawValue)" )
        UserData.sharedInstance.lastNotificationDate = NSDate()
        //set first Time
        
    }
    
    
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        application.applicationIconBadgeNumber = 0
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        
        //remove the Observer
        ReachabilityHelper.sharedInstance.removeObserver()
        print("swiped to kill")
    }
    
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        print("didRevieceLocalNotification")
        if let sr = notification.userInfo{
            if let _ = sr["url"]{
                print("started with url: \(sr["url"] as! String)")
                SearchHolder.sharedInstance.selectedItem = SearchResult(title: sr["title"] as! String , name: sr["name"] as! String , url: sr["url"] as! String, score: 100, license: sr["license"] as! String? )
            }
        }
        
        
        
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        print("recieved RegisterUserNotification   \(notificationSettings.types.rawValue)")
        let type = notificationSettings.types
        let requiredForPush = UIUserNotificationType.Alert.rawValue | UIUserNotificationType.Badge.rawValue | UIUserNotificationType.Sound.rawValue
        
        print("requiredForPush is \(requiredForPush)")
        if type.rawValue == requiredForPush {
            UserData.sharedInstance.allowPushNotification = true
        } else {
            UserData.sharedInstance.allowPushNotification = false
            //slightly blend out the allow push notification setting
        }
    }
    
    
    
    
    
    // MARK: - Crashlytics Logging
    func logUser() {
        // TODO: Use the current user's information
        // You can call any combination of these three methods
        Crashlytics.sharedInstance().setUserEmail("user@fabric.io")
        Crashlytics.sharedInstance().setUserIdentifier("12345")
        Crashlytics.sharedInstance().setUserName("Test User")
    }
    
    
    
}

