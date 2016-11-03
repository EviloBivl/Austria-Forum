//
//  OptionsTableViewController.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 07.01.16.
//  Copyright © 2016 Paul Neuhold. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

class OptionsTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, OptionsLocationDelegate {
    
    var pickerOptions : [String] = ["1 Minute", "5 Minuten" , "10 Minuten" , "15 Minuten", "30 Minuten" , "60 Minuten", "2 Stunden"]
    var pickerValues : [Int] = [1 * 60,5 * 60,10 * 60,15 * 60,30 * 60,60 * 60, 120*60]
    
    var pushPickerOptions : [String] = ["20 Meter","50 Meter","100 Meter","250 Meter","500 Meter","1 Km","2 Km"]
    var pushPickerValues : [Int] = [20,50,100,250,500,1000,2000]
    
    var categoryPickerOptions : [String] = ["Alle","AEIOU","Alltagskultur","AustriaWiki","Bilder & Videos","Community","Geography","Kunst & Kultur","Natur","Politik & Geschichte","Videos","Wissenschaft & Wirtschaft","Biographien","Essays", "Web Books"]
    var categoryPickerValues : [String] = ["ALL","AEIOU","Alltagskultur","AustriaWiki","Bilder_und_Videos","Community","Geography","Kunst_und_Kultur","Natur","Politik_und_Geschichte","Videos","Wissenschaft_und_Wirtschaft","Wissenssammlungen/Biographien","Wissenssammlungen/Essays", "Web_Books"]
    
    
    //    let sectionTitlePretty : [String] = ["Ortungseinstellungen", "Zufalls Artikel Einstellungen"]
    //
    //    let rowTitlePrettySectionOne : [String] = ["Erlaube Push Notifications", "Lokalisierung im Hintergrund", "Lokalisierung auch wenn Austria-Forum geschlossen ist", "Push Notification nicht öfters als alle..." , "Lokalisierung nicht öfters als alle ..."]
    //
    //    let rowTitlePrettySectionTwo : [String] = ["Suche in allen Kategorien" , "Wähle zu durchsuchende"]
    //
    //    let isRowExpandableSectionOne : [Bool] = [false, false, false, true, true]
    //    var rowIsExpandedSectionOne : [Bool] = [false, false, false, false, false]
    //
    
    let infoSection = 2
    let infoxRow = 1
    
    
    @IBOutlet weak var switchAllowPushNotificationOutlet: UISwitch!
    @IBOutlet weak var switchAllowBackgroundLocation: UISwitch!
    @IBOutlet weak var switchAllowSignificantChange: UISwitch!
    @IBOutlet weak var switchDisableToolbar: UISwitch!
    
    
    @IBOutlet weak var intervalPicker: UIPickerView!
    @IBOutlet weak var pushIntervalPicker: UIPickerView!
    @IBOutlet weak var categoryPicker: UIPickerView!
    
    //Tags for the pickers
    let locationIntervalPickerTag : Int = 0
    let pushIntervalPickerTag : Int = 1
    let categoryPickerTag : Int = 2
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor(red: 243.0/255, green: 243.0/255, blue: 243.0/255, alpha: 1)
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.navigationController?.isNavigationBarHidden = false
        
        MyLocationManager.sharedInstance.optionsLocationDelegate = self
        MyLocationManager.sharedInstance.requestAlways()
        self.askUserForPushAllowence()
        
        
        self.registerObserverForSystemPreferenceChange()
        self.synchronizeAppSettingsWithSystemSettings()
        
        self.setPickerSelection()
        
        self.tableView.allowsSelection = true
        self.adaptPickerAlpha()


        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //for debug options
       // self.addDebugOptions()
        //===
        super.viewWillAppear(animated)
    }
    
    func receivedAlwaysPermissions() {
        UserData.sharedInstance.locationSignifacantChangeAllowed = true;
        DispatchQueue.main.async(execute: {
            self.synchronizeAppSettingsWithSystemSettings()
        })
    }
    
    fileprivate func addDebugOptions(){
        pickerOptions.insert("5s debug", at: 0)
        pickerValues.insert(5, at: 0)
        
        pushPickerValues.insert(0, at: 0)
        pushPickerOptions.insert("always", at: 0)
        
        categoryPickerValues.append("not_existing")
        categoryPickerOptions.append("force fail");
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        synchronizeAppSettingsWithSystemSettings()
        
        self.trackViewControllerTitleToAnalytics()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        super.viewDidDisappear(animated)
    }
    
    
    deinit {
        print("\(self.description) deinit")
    }
    
    func setSwitchOptionValues() {
        self.switchAllowBackgroundLocation.setOn(UserData.sharedInstance.locationDistanceChangeAllowed!, animated: false)
        self.switchAllowPushNotificationOutlet.setOn(UserData.sharedInstance.allowPushNotification!, animated: false)
        self.switchAllowSignificantChange.setOn(UserData.sharedInstance.locationSignifacantChangeAllowed!, animated: false)
        self.switchDisableToolbar.setOn(UserData.sharedInstance.disableToolbar!, animated: false)
    }
    
    func setPickerSelection(){
        let pushTimeIndex = self.pickerValues.index(of: UserData.sharedInstance.notificationIntervalInSeconds!)
        self.intervalPicker.selectRow(pushTimeIndex!, inComponent: 0, animated: false)
        
        let distanceIndex = self.pushPickerValues.index(of: UserData.sharedInstance.locationChangeValue!)
        self.pushIntervalPicker.selectRow(distanceIndex!, inComponent: 0, animated: false)
        
        let categoryIndex = self.categoryPickerValues.index(of: UserData.sharedInstance.categorySelected!)
        self.categoryPicker.selectRow(categoryIndex!, inComponent: 0, animated: false)
    }
    
    fileprivate func synchronizeAppSettingsWithSystemSettings() {
        var systemPush = false
        if  isPushSystemAllowed() {
            systemPush = true
        }
        var systemLocation = false
        if isLocationAllowedBySystem() {
            systemLocation = true
        }
        if systemPush == false && UserData.sharedInstance.allowPushNotification != systemPush {
            UserData.sharedInstance.allowPushNotification = systemPush
        }
        if systemLocation == false && (UserData.sharedInstance.locationDistanceChangeAllowed! || UserData.sharedInstance.locationSignifacantChangeAllowed!){
            UserData.sharedInstance.locationDistanceChangeAllowed = systemPush
            UserData.sharedInstance.locationSignifacantChangeAllowed = systemPush
        }
        setSwitchOptionValues()
        self.adaptPickerAlpha()
    }
    
    func isLocationAllowedBySystem() -> Bool {
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined || status == .denied || status == .restricted || status == .authorizedWhenInUse{
            return false
        }else {
            return true
        }
    }
    
    fileprivate func registerObserverForSystemPreferenceChange () {
        NotificationCenter.default.addObserver(self, selector: #selector(OptionsTableViewController.appBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    func appBecomeActive (){
        DispatchQueue.main.async(execute: {
            self.synchronizeAppSettingsWithSystemSettings()
        })
    }
    
    
    func activateBackgroundLocationBasedOnSettings(){
        if self.switchAllowPushNotificationOutlet.isOn {
            //resett push date on pushswitch reallow
            UserData.sharedInstance.lastNotificationDate = Date()
            MyLocationManager.sharedInstance.startIfAllowed()
        } else {
            MyLocationManager.sharedInstance.stopTracking()
        }
    }
    
    
    // MARK: - IBActions
    
    @IBAction func switchAllowPushNotificationsAction(_ sender: UISwitch) {
        if self.isPushSystemAllowed(){
            UserData.sharedInstance.allowPushNotification = sender.isOn
            activateBackgroundLocationBasedOnSettings()
        } else {
            switchAllowPushNotificationOutlet.setOn(false, animated: true)
            self.showToSettingsPushHint()
        }
        self.adaptPickerAlpha()
    }
    
    @IBAction func switchAllowBackgroundLocationAction(_ sender: UISwitch) {
        let locationAuthorizationSystemSetting = isLocationAllowedBySystem()
        if locationAuthorizationSystemSetting == false{
            switchAllowBackgroundLocation.setOn(false, animated: true)
            self.hintToLocationSettings()
        } else {
            UserData.sharedInstance.locationDistanceChangeAllowed = sender.isOn
            if sender.isOn {
                UserData.sharedInstance.locationSignifacantChangeAllowed = !sender.isOn
                switchAllowSignificantChange.setOn(!sender.isOn, animated: true)
            }
            self.handleOptionsSwitch()
        }
    }
    
    @IBAction func switchAllowSignificantChangeAction(_ sender: UISwitch) {
        let locationAuthorizationSystemSetting = isLocationAllowedBySystem()
        if locationAuthorizationSystemSetting == false{
            switchAllowSignificantChange.setOn(false, animated: true)
            self.hintToLocationSettings()
        } else {
            UserData.sharedInstance.locationSignifacantChangeAllowed = sender.isOn
            if sender.isOn {
                UserData.sharedInstance.locationDistanceChangeAllowed = !sender.isOn
                switchAllowBackgroundLocation.setOn(!sender.isOn, animated: true)
            }
            self.handleOptionsSwitch()
        }
    }
    @IBAction func switchDisableToolbar(_ sender: UISwitch) {
        UserData.sharedInstance.disableToolbar = sender.isOn
    }
    
    fileprivate func handleOptionsSwitch() {
        adaptPickerAlpha()
        MyLocationManager.sharedInstance.startIfAllowed()
    }
    
    fileprivate func adaptPickerAlpha(){
        if switchAllowSignificantChange.isOn {
            self.pushIntervalPicker.isUserInteractionEnabled = false
            UIView.animate(withDuration: 0.2, animations: {
                self.pushIntervalPicker.alpha = 0.2
            })
        } else if switchAllowBackgroundLocation.isOn{
            self.pushIntervalPicker.isUserInteractionEnabled = true
            UIView.animate(withDuration: 0.2, animations: {
                self.pushIntervalPicker.alpha = 1
            })
        } else {
            self.pushIntervalPicker.isUserInteractionEnabled = false
            UIView.animate(withDuration: 0.2, animations: {
                self.pushIntervalPicker.alpha = 0.2
            })
        }
       
        if !switchAllowPushNotificationOutlet.isOn {
            UIView.animate(withDuration: 0.2, animations: {
            self.intervalPicker.alpha = 0.2
            })
            self.intervalPicker.isUserInteractionEnabled = false
        } else {
            UIView.animate(withDuration: 0.2, animations: {
            self.intervalPicker.alpha = 1
            })
            self.intervalPicker.isUserInteractionEnabled = true
        
        } 
        
    }
    
    fileprivate func isPushSystemAllowed () -> Bool {
        let notificationSettings = UIApplication.shared.currentUserNotificationSettings
        print("notificationSettings?.types.rawValue \(notificationSettings?.types.rawValue)")
        if notificationSettings?.types.rawValue != 7 {
            return false
        }
        else {
            return true
        }
    }
    
    fileprivate func showToSettingsPushHint() {
        let alertController : UIAlertController = UIAlertController(title: "Mitteilungszentrale", message: "Austria-Forum darf zur Zeit keine vollständigen Mitteilungen schicken. Wenn Sie das ganze Potential ausschöpfen wollen, können sie diese in den System-Einstellungen aktivieren.", preferredStyle: UIAlertControllerStyle.alert)
        let actionAbort : UIAlertAction = UIAlertAction(title: "Abbruch", style: UIAlertActionStyle.cancel, handler: {
            cancleAction in
            print("pressed cancle")
            DispatchQueue.main.async(execute: {
                self.switchAllowPushNotificationOutlet.setOn(false, animated: true)
            })
            
        })
        let actionToSettings : UIAlertAction = UIAlertAction(title: "Einstellungen", style: UIAlertActionStyle.default, handler: {
            alertAction  in
            print("go to settings")
            DispatchQueue.main.async(execute: {
                let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(settingsUrl!, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(settingsUrl!)
                }
            })
        })
        alertController.addAction(actionAbort)
        alertController.addAction(actionToSettings)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    fileprivate func hintToLocationSettings() {
        let alertController : UIAlertController = UIAlertController(title: "Ortungsdienste", message: "Austria-Forum hat derzeit keine Berechtigung Lokalisierung im Hintergrund durchzuführen. Wollen Sie das in den Einstellungen ändern?", preferredStyle: UIAlertControllerStyle.alert)
        let actionAbort : UIAlertAction = UIAlertAction(title: "Abbruch", style: UIAlertActionStyle.cancel, handler: {
            cancleAction in
            print("pressed cancle")
            DispatchQueue.main.async(execute: {
                self.switchAllowBackgroundLocation.setOn(false, animated: true)
                self.switchAllowSignificantChange.setOn(false, animated: true)
                
            })
            
            
        })
        let actionToSettings : UIAlertAction = UIAlertAction(title: "Einstellungen", style: UIAlertActionStyle.default, handler: {
            alertAction  in
            print("go to settings")
            let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(settingsUrl!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(settingsUrl!)
            }
        })
        alertController.addAction(actionAbort)
        alertController.addAction(actionToSettings)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    fileprivate func askUserForPushAllowence(){
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert,.sound,.badge],
                completionHandler: { (granted,error) in
                    if !UserData.sharedInstance.wasPushPermissionAsked! {
                        UserData.sharedInstance.wasPushPermissionAsked = true
                        self.setAFPushSetting(granted: granted)
                    }
            })
        } else {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [UIUserNotificationType.alert,  UIUserNotificationType.badge , UIUserNotificationType.sound], categories: nil))
        }
    
    }
    
    private func setAFPushSetting(granted: Bool){
        if granted {
            print("changed Notification setting to : \(granted)")
            UserData.sharedInstance.allowPushNotification = true
            } else {
            print("changed Notification setting to : \(granted)")
            UserData.sharedInstance.allowPushNotification = false
        }
        DispatchQueue.main.async(execute: {
                self.synchronizeAppSettingsWithSystemSettings()
        })
        
    }
    
    
    //MARK: Picker View Delegates
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView.tag == self.locationIntervalPickerTag {
            return self.pickerOptions.count
        } else if pickerView.tag == self.pushIntervalPickerTag {
            return self.pushPickerOptions.count
        } else if pickerView.tag == self.categoryPickerTag {
            return self.categoryPickerOptions.count
        }
        
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == self.locationIntervalPickerTag {
            return self.pickerOptions[row]
        } else if pickerView.tag == self.pushIntervalPickerTag{
            return self.pushPickerOptions[row]
        } else if pickerView.tag == self.categoryPickerTag{
            return self.categoryPickerOptions[row]
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == self.locationIntervalPickerTag {
            UserData.sharedInstance.notificationIntervalInSeconds = self.pickerValues[row]
            self.handleOptionsSwitch()
        } else if pickerView.tag == self.pushIntervalPickerTag{
            UserData.sharedInstance.locationChangeValue = self.pushPickerValues[row]
            self.handleOptionsSwitch()
        } else if pickerView.tag == self.categoryPickerTag {
            UserData.sharedInstance.categorySelected = self.categoryPickerValues[row]
        }
    }
}

