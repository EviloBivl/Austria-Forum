//
//  OptionsTableViewController.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 07.01.16.
//  Copyright © 2016 Paul Neuhold. All rights reserved.
//

import UIKit

class OptionsTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let pickerOptions : [String] = ["5s debug","1 Minute", "5 Minuten" , "10 Minuten" , "15 Minuten", "30 Minuten" , "60 Minuten"]
    let pickerValues : [Int] = [5,1 * 60,5 * 60,10 * 60,15 * 60,30 * 60,60 * 60]
    
    let pushPickerOptions : [String] = ["always","5m debug","20 Meter","50 Meter","100 Meter","250 Meter","500 Meter","1 Km","2 Km"]
    let pushPickerValues : [Int] = [0,5,20,50,100,250,500,1000,2000]
    
    let categoryPickerOptions : [String] = ["Alle","AEIOU","Alltagskultur","AustriaWiki","Bilder & Videos","Community","Geography","Kunst & Kultur","Natur","Politik & Geschichte","Videos","Wissenschaft & Wirtschaft","Biographien","Essays", "Web Books", "force Fail"]
    let categoryPickerValues : [String] = ["ALL","AEIOU","Alltagskultur","AustriaWiki","Bilder_und_Videos","Community","Geography","Kunst_und_Kultur","Natur","Politik_und_Geschichte","Videos","Wissenschaft_und_Wirtschaft","Wissenssammlungen/Biographien","Wissenssammlungen/Essays", "Web_Books", "not_existing"]
    
    
    @IBOutlet weak var switchAllowPushNotificationOutlet: UISwitch!
    @IBOutlet weak var switchAllowBackgroundLocation: UISwitch!
    @IBOutlet weak var switchAllowSignificantChange: UISwitch!
    
    
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
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: .Alert, categories: nil))
        switchAllowPushNotificationOutlet.setOn(UserData.sharedInstance.allowPushNotification!, animated: false)
        self.navigationController?.navigationBarHidden = false
        
        self.setSwitchOptionValues()
        self.setPickerSelection()
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //Always set the current controller as the delegate to ReachabilityHelper
        //not the options view controller ...
    }
    
    func setSwitchOptionValues() {
        self.switchAllowBackgroundLocation.setOn(UserData.sharedInstance.locationDistanceChangeAllowed!, animated: false)
        self.switchAllowPushNotificationOutlet.setOn(UserData.sharedInstance.allowPushNotification!, animated: false)
        self.switchAllowSignificantChange.setOn(UserData.sharedInstance.locationSignifacantChangeAllowed!, animated: false)
    }
    
    func setPickerSelection(){
        let pushTimeIndex = self.pickerValues.indexOf(UserData.sharedInstance.notificationIntervalInSeconds!)
        self.intervalPicker.selectRow(pushTimeIndex!, inComponent: 0, animated: false)
        
        let distanceIndex = self.pushPickerValues.indexOf(UserData.sharedInstance.locationChangeValue!)
        self.pushIntervalPicker.selectRow(distanceIndex!, inComponent: 0, animated: false)
        
        let categoryIndex = self.categoryPickerValues.indexOf(UserData.sharedInstance.categorySelected!)
        self.categoryPicker.selectRow(categoryIndex!, inComponent: 0, animated: false)
    }
    
    
    
    // MARK: - IBActions
    
    @IBAction func switchAllowPushNotificationsAction(sender: UISwitch) {
        if self.isPushSystemAllowed(){
            UserData.sharedInstance.allowPushNotification = sender.on
        }
    }
    
    @IBAction func switchAllowBackgroundLocationAction(sender: UISwitch) {
        let locationAuthorizationSystemSetting = MyLocationManager.sharedInstance.isAllowedBySystem()
        if locationAuthorizationSystemSetting == false{
            self.hintToLocationSettings()
        } else {
            UserData.sharedInstance.locationDistanceChangeAllowed = sender.on
            self.handleOptionsSwitch()
        }
    }
    
    @IBAction func switchAllowSignificantChangeAction(sender: UISwitch) {
        let locationAuthorizationSystemSetting = MyLocationManager.sharedInstance.isAllowedBySystem()
        if locationAuthorizationSystemSetting == false{
            self.hintToLocationSettings()
        } else {
            UserData.sharedInstance.locationSignifacantChangeAllowed = sender.on
            self.handleOptionsSwitch()
        }
    }
    
    private func handleOptionsSwitch() {
        MyLocationManager.sharedInstance.startIfAllowed()
    }
    
    private func isPushSystemAllowed () -> Bool {
        let notificationSettings = UIApplication.sharedApplication().currentUserNotificationSettings()
        if notificationSettings?.types.rawValue != 7 {
            self.showToSettingsPushHint()
            return false
        }
        else {
            return true
        }
    }
    
    private func showToSettingsPushHint() {
        let alertController : UIAlertController = UIAlertController(title: "Mitteilungszentrale", message: "Austria-Forum darf zur Zeit keine vollständigen Mitteiungen schicken. Wenn Sie das ganze Potential ausschöpfen wollen, können sie diese in den Einstellungen aktivieren.", preferredStyle: UIAlertControllerStyle.Alert)
        let actionAbort : UIAlertAction = UIAlertAction(title: "Abbruch", style: UIAlertActionStyle.Cancel, handler: {
            cancleAction in
            print("pressed cancle")
            dispatch_async(dispatch_get_main_queue(), {
                self.switchAllowPushNotificationOutlet.setOn(false, animated: true)
            })
            
        })
        let actionToSettings : UIAlertAction = UIAlertAction(title: "Einstellungen", style: UIAlertActionStyle.Default, handler: {
            alertAction  in
            print("go to settings")
            let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
            UIApplication.sharedApplication().openURL(settingsUrl!)
        })
        alertController.addAction(actionAbort)
        alertController.addAction(actionToSettings)
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    private func hintToLocationSettings() {
        let alertController : UIAlertController = UIAlertController(title: "Ortungsdienste", message: "Austria-Froum darf zur Zeit nicht auf ihren Standort zugreifen. Sie können dies in den Einstellungen ändern wenn Sie wollen.", preferredStyle: UIAlertControllerStyle.Alert)
        let actionAbort : UIAlertAction = UIAlertAction(title: "Abbruch", style: UIAlertActionStyle.Cancel, handler: {
            cancleAction in
            print("pressed cancle")
            dispatch_async(dispatch_get_main_queue(), {
                self.switchAllowBackgroundLocation.setOn(false, animated: true)
                self.switchAllowSignificantChange.setOn(false, animated: true)
                
            })

            
        })
        let actionToSettings : UIAlertAction = UIAlertAction(title: "Einstellungen", style: UIAlertActionStyle.Default, handler: {
            alertAction  in
            print("go to settings")
            let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
            UIApplication.sharedApplication().openURL(settingsUrl!)
        })
        alertController.addAction(actionAbort)
        alertController.addAction(actionToSettings)
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    
    //MARK: Picker View Delegates
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView.tag == self.locationIntervalPickerTag {
            return self.pickerOptions.count
        } else if pickerView.tag == self.pushIntervalPickerTag {
            return self.pushPickerOptions.count
        } else if pickerView.tag == self.categoryPickerTag {
            return self.categoryPickerOptions.count
        }
        
        return 0
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == self.locationIntervalPickerTag {
            return self.pickerOptions[row]
        } else if pickerView.tag == self.pushIntervalPickerTag{
            return self.pushPickerOptions[row]
        } else if pickerView.tag == self.categoryPickerTag{
            return self.categoryPickerOptions[row]
        }
        return ""
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
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
    
    // MARK: - Table view data source
    /*
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 3
    }
    */
    /*
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return 3
    }
    */
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("optionCell", forIndexPath: indexPath)
    
    // Configure the cell...
    cell.textLabel?.text = self.options[indexPath.row]
    return cell
    }
    */
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}

