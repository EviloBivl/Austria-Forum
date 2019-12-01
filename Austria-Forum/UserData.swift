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
    fileprivate var userDefaults : UserDefaults?
    static let AF_URL = "https://austria-forum.org"
    
    /**
     If you set this property it will also get stored as Object in the NSUserDefaults with the key UserDefaultKeys.kLastVisitedString
     */
    var lastVisitedString : String? {
        get{
            if let val = self.getValueForKey(UserDefaultKeys.kLastVisitedString) as? String {
                return val
            } else {
                return UserData.AF_URL
            }
        }
        set{
            self.setValueForKey(newValue! as AnyObject, key: UserDefaultKeys.kLastVisitedString)
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
            self.setValueForKey(newValue! as AnyObject, key: UserDefaultKeys.kOptionAllowPushNotificationBool)
        }
    }
    
    var wasPushPermissionAsked : Bool? {
        get{
            if let val = self.getValueForKey(UserDefaultKeys.kOptionWasPushPermissionAskedBool) as? Bool {
                return val
            } else {
                return UserDefaultValues.wasPushPermissionAsked
            }
        }
        set{
            self.setValueForKey(newValue! as AnyObject, key: UserDefaultKeys.kOptionWasPushPermissionAskedBool)
        }
    }
    /*
     seems to be unesed atm
     */
    var optionLocationUpdateInterval : Int? {
        get{
            if let val = self.getValueForKey(UserDefaultKeys.kOptionLocationUpdateIntervalInt) as? Int {
                return val
            } else {
                return UserDefaultValues.intervalTime
            }
        }
        set{
            self.setValueForKey(newValue! as AnyObject, key: UserDefaultKeys.kOptionLocationUpdateIntervalInt)
        }
        
    }
    
    var lastNotificationDate : Date? {
        get{
            if let val = self.getValueForKey(UserDefaultKeys.kLastNotificationMessageNSDate) as? Date {
                return val
            } else {
                self.lastNotificationDate = Date()
                return Date()
            }
        }
        set{
            self.setValueForKey(newValue! as AnyObject, key: UserDefaultKeys.kLastNotificationMessageNSDate)
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
            self.setValueForKey(newValue! as AnyObject, key: UserDefaultKeys.kLocationChangedValueInt)
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
            self.setValueForKey(newValue! as AnyObject, key: UserDefaultKeys.kLocationSignificantChangeAllowedBool)
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
            self.setValueForKey(newValue! as AnyObject, key: UserDefaultKeys.kLocationDistanceChangeAllowedBool)
        }
        
    }
    
    var notificationIntervalInSeconds : Int? {
        get{
            if let val = self.getValueForKey(UserDefaultKeys.kNotificationIntervalInSecondsInt) as? Int {
                return val
            } else {
                return UserDefaultValues.notificationIntervalSeconds
            }
        }
        set{
            self.setValueForKey(newValue! as AnyObject, key: UserDefaultKeys.kNotificationIntervalInSecondsInt)
        }
    }
    
    var categorySelected : String? {
        get{
            if let val = self.getValueForKey(UserDefaultKeys.kCategorySelectedString) as? String {
                return val
            } else {
                return UserDefaultValues.categorySelected
            }
        }
        set{
            self.setValueForKey(newValue! as AnyObject, key: UserDefaultKeys.kCategorySelectedString)
        }
    }
    
    var disableToolbar : Bool? {
        get {
            if let val = self.getValueForKey(UserDefaultKeys.kDisableToolbarBool) as? Bool {
                return val
            } else {
                return UserDefaultValues.disableToolbar
            }
        }
        set {
            self.setValueForKey(newValue! as AnyObject, key: UserDefaultKeys.kDisableToolbarBool)
        }
    }
    
    /**
     If we set this property, persist it
     */
    var articleOfTheMonth : SearchResult?  {
        get{
            if let val = self.getValueForKey(UserDefaultKeys.kArticleOfTheMonthSearchResult) as? NSDictionary {
                var licenseResult : License? = .none
                if let license = val["licenseResult"] as? NSDictionary{
                    licenseResult = License(css: license["css"] as? String, title: license["title"] as? String, url: license["url"] as? String, id: license["id"]as? String)
                }
                return SearchResult(title: val.value(forKey: "title") as? String, name: val.value(forKey: "name") as? String, url: val.value(forKey: "url") as? String, score: 100, licenseResult: licenseResult )
            } else{
                return SearchResult(title: "", name: "", url: self.lastVisitedString, score: 0, licenseResult: .none)
            }
        }
        set{
            self.persistArticleOfTheMonth(newValue!)
        }
    }
    
    
    
    fileprivate override init(){
        super.init()
        self.userDefaults = UserDefaults.standard
        
        
        //load all saved defaults to save userDefaults access later
        self.loadAllSavedValuesFromUserDefaults()
        
    }
    
    func setValueForKey(_ value: AnyObject, key: String){
        self.userDefaults?.set(value, forKey: key)
    }
    
    func getValueForKey(_ key: String) -> AnyObject?{
        return self.userDefaults?.object(forKey: key) as AnyObject?
    }
    
    func removeValueForKey(_ key: String) {
        self.userDefaults?.removeObject(forKey: key)
    }
    
    
    fileprivate func persistArticleOfTheMonth(_ article: SearchResult) {
        if checkIfArticleOfTheMonthNeedsReload() {

            var licenseDict : [String:String] = [:]
            if let license = article.licenseResult {
                licenseDict = ["id" : license.id!, "title": license.title!, "css" : license.css!, "url" : license.url!]
            }
            
            let url = article.url as AnyObject? ?? "" as AnyObject
            let title = article.title as AnyObject? ?? "" as AnyObject
            let name = article.name as AnyObject? ?? "" as AnyObject
            let score = article.score as AnyObject
            
            let dictFromSearchResult : [String:AnyObject] = ["url":url, "title" : title,
                                                             "name" : name, "score" : score,
                                                             "licenseResult" : licenseDict as AnyObject]
            setValueForKey(dictFromSearchResult as AnyObject, key: UserDefaultKeys.kArticleOfTheMonthSearchResult)
            setValueForKey(Date() as AnyObject, key: UserDefaultKeys.kLastMonthOfArticleOfTheMonthNSDate)
        }
    }
    
    func checkIfArticleOfTheMonthNeedsReload () -> Bool{
        let calendar = Calendar.init(identifier: Calendar.Identifier.gregorian)
        let currentMonth = ((calendar as NSCalendar?)?.component(NSCalendar.Unit.month, from: Date()))!
        let currentYear = ((calendar as NSCalendar?)?.component(NSCalendar.Unit.year, from: Date()))!
        
        if let lastDate = getValueForKey(UserDefaultKeys.kLastMonthOfArticleOfTheMonthNSDate) as? Date {
            let lastMonth = ((calendar as NSCalendar?)?.component(NSCalendar.Unit.month, from: lastDate))!
            let lastYear = ((calendar as NSCalendar?)?.component(NSCalendar.Unit.year, from: lastDate))!
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
    
    
    
    fileprivate func loadAllSavedValuesFromUserDefaults () {
        
        
        
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
    static let kNotificationIntervalInSecondsInt : String = "kNotificationIntervalInMinutes"
    static let kLocationChangedValueInt : String = "kLocationChangedValue"
    static let kLocationSignificantChangeAllowedBool : String = "kSignificantChangeAllowed"
    static let kLocationDistanceChangeAllowedBool : String = "kRegularLocationChange"
    static let kCategorySelectedString : String = "kCategorySelected"
    static let kDisableToolbarBool : String = "kDisableToolBar"
    static let kOptionWasPushPermissionAskedBool : String = "kWasPushPermissionAsked"
    
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
    static let notificationIntervalSeconds = 1 * 60
    static let categorySelected : String = "ALL"
    static let disableToolbar : Bool = false
    static let wasPushPermissionAsked : Bool = false
}



