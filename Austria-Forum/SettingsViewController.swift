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

class SettingsViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, OptionsLocationDelegate {
    
    var viewModel : SettingsViewModel?
    
    class func create(viewModel: SettingsViewModel) -> SettingsViewController {
        let controller = StoryboardScene.SettingsViewController.settingsViewController.instantiate()
        controller.viewModel = viewModel
        return controller
    }

    
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
    @IBOutlet weak var aboutCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //===
        //viewModel?.addDebugOptions()
        //===
        super.viewWillAppear(animated)
    }
    
    
    private func setupUI(){
        self.tableView.backgroundColor = ColorName.background.color
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        self.viewModel?.delegate = self
        
        MyLocationManager.sharedInstance.optionsLocationDelegate = self
        MyLocationManager.sharedInstance.requestAlways()
        self.askUserForPushAllowence()
        
        
        self.synchronizeAppSettingsWithSystemSettings()
        self.setPickerSelection()
        
        self.tableView.allowsSelection = true
        self.adaptPickerAlpha()
        
    }
    
    func receivedAlwaysPermissions() {
        UserData.sharedInstance.locationSignifacantChangeAllowed = true;
        DispatchQueue.main.async(execute: {
            self.synchronizeAppSettingsWithSystemSettings()
        })
    }
    
    fileprivate func addDebugOptions(){
        guard let viewModel = viewModel else { return }
        viewModel.addDebugOptions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.registerObserverForSystemPreferenceChange()
        synchronizeAppSettingsWithSystemSettings()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        super.viewDidDisappear(animated)
    }
    
    func setSwitchOptionValues() {
        self.switchAllowBackgroundLocation.setOn(UserData.sharedInstance.locationDistanceChangeAllowed!, animated: false)
        self.switchAllowPushNotificationOutlet.setOn(UserData.sharedInstance.allowPushNotification!, animated: false)
        self.switchAllowSignificantChange.setOn(UserData.sharedInstance.locationSignifacantChangeAllowed!, animated: false)
        self.switchDisableToolbar.setOn(UserData.sharedInstance.disableToolbar!, animated: false)
    }
    
    func setPickerSelection(){
        guard let viewModel = viewModel else { return }
        let pushTimeIndex = viewModel.pushPickerValues.index(of: UserData.sharedInstance.notificationIntervalInSeconds!)
        intervalPicker.selectRow(pushTimeIndex!, inComponent: 0, animated: false)
        
        let distanceIndex = viewModel.distancePickerValues.index(of: UserData.sharedInstance.locationChangeValue!)
        pushIntervalPicker.selectRow(distanceIndex!, inComponent: 0, animated: false)
        
        let categoryIndex = viewModel.categoryPickerValues.index(of: UserData.sharedInstance.categorySelected!)
        categoryPicker.selectRow(categoryIndex!, inComponent: 0, animated: false)
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
            UserData.sharedInstance.locationDistanceChangeAllowed = systemLocation
            UserData.sharedInstance.locationSignifacantChangeAllowed = systemLocation
        }
        setSwitchOptionValues()
        self.adaptPickerAlpha()
    }
    
    func isLocationAllowedBySystem() -> Bool {
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedAlways {
            return true
        }else {
            return false
        }
    }
    
    fileprivate func registerObserverForSystemPreferenceChange () {
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.appBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    @objc func appBecomeActive (){
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
    
    func updateUI(){
        handleOptionsSwitch()
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
        print("notificationSettings?.types.rawValue \(String(describing: notificationSettings?.types.rawValue))")
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        if cell == aboutCell {
            let controller = AboutViewController.create(viewModel: AboutViewModel())
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    
    //MARK: Picker View Delegates
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel?.numberOfRows(for: pickerView.tag) ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel?.pickerTitle(for: pickerView.tag, at: row) ?? nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel?.didSelectPickerView(at: row, with: pickerView.tag)
    }
}

extension SettingsViewController: ViewModelObserver {
    func signalUpdate() {
        updateUI()
    }
}





