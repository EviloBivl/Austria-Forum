//
//  LocationTableViewController.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 07.01.16.
//  Copyright © 2016 Paul Neuhold. All rights reserved.
//

import UIKit
import CoreLocation

class LocationTableViewController: UITableViewController {
    
    
    
    var locationData : Array <String> = []
    var locationCategories : Array <String> = []
    var locationDistances : Array <String> = []
    var numberOfReults : Int = 40
    var noInternetView : LoadingScreen?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = false
        // Do any additional setup after loading the view.
        
        
        //Register Custom Cell
        let nib = UINib(nibName: "afLocationTableViewCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "afLocationTableViewCell")
        self.tableView.rowHeight = 60
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //Always set the current controller as the delegate to ReachabilityHelper
        ReachabilityHelper.sharedInstance.delegate = self
        
        MyLocationManager.sharedInstance.refreshToCurrentLocation(self, numberOfResults: self.numberOfReults)
    }
    
    @IBAction func refreshResults(sender: UIBarButtonItem) {
        if (ReachabilityHelper.sharedInstance.connection == ReachabilityType.NO_INTERNET){
                noInternet()
        }
        else {
                MyLocationManager.sharedInstance.refreshToCurrentLocation(self, numberOfResults : self.numberOfReults)
        }
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - UITableView
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return self.locationData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let locationCell : afLocationTableViewCell = tableView.dequeueReusableCellWithIdentifier("afLocationTableViewCell") as! afLocationTableViewCell
        locationCell.labelTitel.text = self.locationData[indexPath.row]
        if self.locationCategories[indexPath.row] == "" {
            locationCell.labelCategory.text = "Keiner Kategorie zugeordnet"
        } else {
            locationCell.labelCategory.text = self.locationCategories[indexPath.row]
        }
//        var distString = ""
//        if self.locationDistances[indexPath.row] <= 1000 {
//            distString += "\(self.locationDistances[indexPath.row])" + " m"
//        } else {
//            distString += "\(self.locationDistances[indexPath.row]/1000)"
//            let decimalIndex = distString.characters.indexOf(".")
//            if let index = decimalIndex {
//                distString = distString.substringToIndex(index.advancedBy(3)) + " Km"
//                distString = distString.stringByReplacingOccurrencesOfString(".", withString: ",")
//            }
//        }
        locationCell.labelDistance.text = self.locationDistances[indexPath.row]
        return locationCell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedArticle : LocationArticleResult = LocationArticleHolder.sharedInstance.articles[indexPath.row]
        //convert the LocationResult to be a Searchresult for handling in the DetailViewController - this would be a good place for an Adapter ;)
        
        SearchHolder.sharedInstance.selectedItem = SearchResult(title: selectedArticle.title, name: selectedArticle.name, url: selectedArticle.url, score: 100, license: selectedArticle.license)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
}

extension LocationTableViewController : NetworkDelegation {
    
    func onRequestFailed(from: String?){
        
        
    }
    func onRequestSuccess(from: String?){
        print("Success in LocaitonTableView")
        print("appending to tableview Location")
        
        //delete previous results
        dispatch_async(dispatch_get_main_queue(), {
            self.locationCategories.removeAll()
            self.locationData.removeAll()
            self.locationDistances.removeAll()
            
            for result in LocationArticleHolder.sharedInstance.articles {
                self.locationCategories.append(CategoriesListed.GetBeautyCategoryFromUrlString(result.url))
                self.locationData.append(result.title)
                self.locationDistances.append(result.distanceString)
            }
            
            self.tableView.reloadData()
        })
        
//              
//        //add new results
//        dispatch_async(dispatch_get_main_queue()) {
//            for result in LocationArticleHolder.sharedInstance.articles {
//                self.locationCategories.append(CategoriesListed.GetBeautyCategoryFromUrlString(result.url))
//                self.locationData.append(result.title)
//                self.locationDistances.append(result.distance)
//                let indexPath = NSIndexPath(forRow: self.locationData.count - 1, inSection: 0)
//                self.tableView.beginUpdates()
//                self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
//                self.tableView.endUpdates()
//            }
//            
//        }
//        
        
    }
    
 

}

extension LocationTableViewController : ReachabilityDelegate {
    func noInternet() {
        
        self.noInternetView = NSBundle.mainBundle().loadNibNamed("LoadingScreen", owner: self, options: nil)[0] as? LoadingScreen
        self.noInternetView?.frame = self.view.frame
        self.noInternetView?.frame.origin.y  -= 100
        self.noInternetView?.tag = 99
        
        if let v = self.noInternetView {
            
            v.labelMessage.text = "Bitte überprüfen Sie ihre Internetverbindung."
            self.view.addSubview(v)
            v.bringSubviewToFront(self.view)
            v.activityIndicator.startAnimating()
            v.viewLoadingHolder.backgroundColor = UIColor(white: 0.4, alpha: 0.9)
            v.viewLoadingHolder.layer.cornerRadius = 5
            v.viewLoadingHolder.layer.masksToBounds = true;
            print("added no Internet Notification")
        }
        self.performSelector("hideNoInternetView", withObject: self, afterDelay: 1)
    }
    
    func hideNoInternetView(){
        print("hided no internet notification")
        for v in self.view.subviews {
            if v.tag == 99{
                v.removeFromSuperview()
            }
        }
    }
    
    func InternetBack() {
        hideNoInternetView()
    }
}
