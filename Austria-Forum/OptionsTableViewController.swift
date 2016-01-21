//
//  OptionsTableViewController.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 07.01.16.
//  Copyright © 2016 Paul Neuhold. All rights reserved.
//

import UIKit

class OptionsTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    let pickerOptions : [String] = ["1 Minute", "5 Minuten" , "10 Minuten" , "15 Minuten", "30 Minuten" , "60 Minuten"]
    let pickerValues : [Int] = [1,5,10,15,30,60]
    
    @IBOutlet weak var switchAllowPushNotificationOutlet: UISwitch!
    @IBOutlet weak var switchAllowBackgroundLocation: UISwitch!
    @IBOutlet weak var switchAllowSignificantChange: UISwitch!
    
    
    @IBOutlet weak var intervalPicker: UIPickerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor(red: 243.0/255, green: 243.0/255, blue: 243.0/255, alpha: 1)
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: .Alert, categories: nil))
        switchAllowPushNotificationOutlet.setOn(UserData.sharedInstance.allowPushNotification!, animated: false)
        self.navigationController?.navigationBarHidden = false
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - IBActions
    
    @IBAction func switchAllowPushNotificationsAction(sender: UISwitch) {
        UserData.sharedInstance.allowPushNotification = sender.on
    }
    
    @IBAction func switchAllowBackgroundLocationAction(sender: UISwitch) {
        UserData.sharedInstance.locationDistanceChangeAllowed = sender.on
    }
 
    @IBAction func switchAllowSignificantChangeAction(sender: UISwitch) {
        UserData.sharedInstance.locationSignifacantChangeAllowed = sender.on
    }
    
   //MARK: Picker View Delegates
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return self.pickerOptions.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return pickerOptions[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        UserData.sharedInstance.notificationIntervalInMinutes = self.pickerValues[row]
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
