//
//  UserData.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 11.12.15.
//  Copyright © 2015 Paul Neuhold. All rights reserved.
//

import Foundation

/** UserData Class
 
 On creation the class will load all stored Values from the NSUserDefaults into the stored properties of the class
 if you set a property it will also be saved within the NSUserDefaults
 
 */
class UserData : NSObject {
    
    static let sharedInstance = UserData()
    private var userDefaults : NSUserDefaults?
    
    /**
     If you set this property it will also get stored as Object in the NSUserDefaults with the key UserDefaultKeys.kLastVisitedString
     */
    var lastVisitedString : String? {
        get{
            if let val = self.getValueForKey(UserDefaultKeys.kLastVisitedString) as? String {
                return val
            } else {
                return "http://www.austria-forum.org"
            }
        }
        set{
            self.setValueForKey(newValue!, key: UserDefaultKeys.kOptionAllowPushNotificationBool)
        }
    }
    
    
    var allowPushNotification : Bool? {
        get{
            if let val = self.getValueForKey(UserDefaultKeys.kOptionAllowPushNotificationBool) as? Bool {
                return val
            } else {
                return UserDefaultValues.allowPushNotifications
            }
        }
        set{
            self.setValueForKey(newValue!, key: UserDefaultKeys.kOptionAllowPushNotificationBool)
        }
    }
    
    var optionLocationUpdateInterval : Int? {
        get{
            if let val = self.getValueForKey(UserDefaultKeys.kOptionLocationUpdateIntervalInt) as? Int {
                return val
            } else {
                return UserDefaultValues.intervalTime
            }
        }
        set{
            self.setValueForKey(newValue!, key: UserDefaultKeys.kOptionLocationUpdateIntervalInt)
        }
        
    }
    
    var lastNotificationDate : NSDate? {
        get{
            if let val = self.getValueForKey(UserDefaultKeys.kLastNotificationMessageNSDate) as? NSDate {
                return val
            } else {
                return NSDate()
            }
        }
        set{
            self.setValueForKey(newValue!, key: UserDefaultKeys.kLastNotificationMessageNSDate)
        }
        
    }
    
    var locationChangeValue : Int? {
        get{
            if let val = self.getValueForKey(UserDefaultKeys.kLocationChangedValueInt) as? Int {
                return val
            } else {
                return UserDefaultValues.locationChangedValue
            }
        }
        set{
            self.setValueForKey(newValue!, key: UserDefaultKeys.kLocationChangedValueInt)
        }
    }
    
    var locationSignifacantChangeAllowed : Bool? {
        get{
            if let val = self.getValueForKey(UserDefaultKeys.kLocationSignificantChangeAllowedBool) as? Bool {
                return val
            } else {
                return UserDefaultValues.allowLocationSignificantChange
            }
        }
        set{
            self.setValueForKey(newValue!, key: UserDefaultKeys.kLocationSignificantChangeAllowedBool)
        }
    }
    
    var locationDistanceChangeAllowed : Bool? {
        get{
            if let val = self.getValueForKey(UserDefaultKeys.kLocationDistanceChangeAllowedBool) as? Bool {
                return val
            } else {
                return UserDefaultValues.allowLocationDistanceChange
            }
        }
        set{
            self.setValueForKey(newValue!, key: UserDefaultKeys.kLocationDistanceChangeAllowedBool)
        }

    }
    
    var notificationIntervalInMinutes : Int? {
        get{
            if let val = self.getValueForKey(UserDefaultKeys.kNotificationIntervalInMinutesInt) as? Int {
                return val
            } else {
                return UserDefaultValues.notificationIntervalMinutes
            }
        }
        set{
            self.setValueForKey(newValue!, key: UserDefaultKeys.kNotificationIntervalInMinutesInt)
        }
    }
    
    
    /**
     If we set this property, persist it
     */
    var articleOfTheMonth : SearchResult?  {
        get{
            if let val = self.getValueForKey(UserDefaultKeys.kArticleOfTheMonthSearchResult) as? NSDictionary {
                return SearchResult(title: val.valueForKey("title") as! String, name: val.valueForKey("name") as! String, url: val.valueForKey("url") as! String, score: 100)
            } else{
                return SearchResult(title: "", name: "", url: "default", score: 0)
            }
        }
        set{
            self.persistArticleOfTheMonth(newValue!)
        }
    }
    

    
    private override init(){
        super.init()
        self.userDefaults = NSUserDefaults.standardUserDefaults()
        
        
        //load all saved defaults to save userDefaults access later
        self.loadAllSavedValuesFromUserDefaults()
        
    }
    
    func setValueForKey(value: AnyObject, key: String){
        self.userDefaults?.setObject(value, forKey: key)
    }
    
    func getValueForKey(key: String) -> AnyObject?{
        return self.userDefaults?.objectForKey(key)
    }
    
    func removeValueForKey(key: String) {
        self.userDefaults?.removeObjectForKey(key)
    }
    
    
    private func persistArticleOfTheMonth(article: SearchResult) {
        if checkIfArticleOfTheMonthNeedsReload() {
            let dictFromSearchResult : NSDictionary = ["url":article.url, "title" : article.title, "name" : article.name, "score" : article.score]
            setValueForKey(dictFromSearchResult, key: UserDefaultKeys.kArticleOfTheMonthSearchResult)
            setValueForKey(NSDate(), key: UserDefaultKeys.kLastMonthOfArticleOfTheMonthNSDate)
        }
    }
    
    func checkIfArticleOfTheMonthNeedsReload () -> Bool{
        let calendar = NSCalendar.init(calendarIdentifier: NSCalendarIdentifierGregorian)
        let currentMonth = (calendar?.component(NSCalendarUnit.Month, fromDate: NSDate()))!
        let currentYear = (calendar?.component(NSCalendarUnit.Year, fromDate: NSDate()))!
        
        if let lastDate = getValueForKey(UserDefaultKeys.kLastMonthOfArticleOfTheMonthNSDate) as? NSDate {
            let lastMonth = (calendar?.component(NSCalendarUnit.Month, fromDate: lastDate))!
            let lastYear = (calendar?.component(NSCalendarUnit.Year, fromDate: lastDate))!
            if lastYear < currentYear {
                return true
            } else {
                if lastMonth < currentMonth {
                    return true
                }
            }
        } else {
            return true
        }
        return false
    }
    
    
    private func loadAllSavedValuesFromUserDefaults () {
        
       
        
    }
    /**
     checks if the user starts the app for the first time
     */
    func checkIfAppStartsTheFirstTime() -> Bool{
        if let val = self.getValueForKey(UserDefaultKeys.kFirstTimeStartingAppString) {
            //the value is set, so its not the first time starting the app
            print("we got val : \(val)")
            return true
        } else {
            //no value is set we are starting it for the first time
            print("we got no val")
            return false
        }
    }
    
    
    
}

/**
 Struct containing all used keys for saving/loading data to the NSUserdefaults
 */

struct UserDefaultKeys {
    
    static let kLastVisitedString : String = "kLastVisited"
    static let kOptionOneString :   String = "kOptionOne"
    static let kOptionTwoString :   String = "kOptionTwo"
    static let kOptionAllowPushNotificationBool : String = "kOptionAllowPushNotificationBool"
    static let kOptionLocationUpdateIntervalInt : String = "kOptionLocationUpdateIntervalInt"
    static let kOptionThreeBool :   String = "kOptionThreeBool"
    static let kArticleOfTheMonthSearchResult: String = "kArticleOfTheMonth"
    static let kLastMonthOfArticleOfTheMonthNSDate: String = "kLastMonthOfArticleOfTheMonth"
    static let kFirstTimeStartingAppString : String = "kFirstTimeStartingAppString"
    static let kLastNotificationMessageNSDate : String = "kLastNotificationMessage"
    static let kNotificationIntervalInMinutesInt : String = "kNotificationIntervalInMinutes"
    static let kLocationChangedValueInt : String = "kLocationChangedValue"
    static let kLocationSignificantChangeAllowedBool : String = "kSignificantChangeAllowed"
    static let kLocationDistanceChangeAllowedBool : String = "kRegularLocationChange"
    
}

/**
 Struct containing all Default Values for not set settings
*/
struct UserDefaultValues {
    static let intervalTime : Int = 10
    static let allowPushNotifications : Bool = false
    static let allowLocationSignificantChange : Bool = false
    static let allowLocationDistanceChange : Bool = false
    static let locationChangedValue : Int = 50
    static let notificationIntervalMinutes = 5
}


