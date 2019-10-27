//
//  LocationTableViewController.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 07.01.16.
//  Copyright © 2016 Paul Neuhold. All rights reserved.
//

import UIKit
import CoreLocation

class NearbyArticlesViewController: UITableViewController, LocationControllerDelegate, LocationErrorDelegate {
    
    var viewModel: NearbyArticlesViewModel?
    
    class func create(viewModel: NearbyArticlesViewModel) -> NearbyArticlesViewController {
        let controller = StoryboardScene.NearbyArticles.nearbyArticlesViewController.instantiate()
        controller.viewModel = viewModel
        return controller
    }
    
    var locationData : Array <String> = []
    var locationCategories : Array <String> = []
    var locationDistances : Array <String> = []
    var numberOfReults : Int = 100
    var noInternetView : LoadingScreen?
    var loadingView : LoadingScreen?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        // Do any additional setup after loading the view.
        MyLocationManager.sharedInstance.requestWhenInUse()
        MyLocationManager.sharedInstance.articlesByLocationDelegate = self
        MyLocationManager.sharedInstance.locationErrorDelegate = self
        
    
        //Register Custom Cell
        let nib = UINib(nibName: "afLocationTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "afLocationTableViewCell")
        self.tableView.rowHeight = 75
        self.tableView.tableFooterView = UIView()
        
        self.loadingView = Bundle.main.loadNibNamed("LoadingScreen", owner: self, options: nil)![0] as? LoadingScreen
        showLoadingScreen()
        
        //Register Pull to refresh
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(NearbyArticlesViewController.pullToRefresh), for: UIControl.Event.valueChanged)
        self.refreshControl?.beginRefreshing()
        
    }
    
    @objc public func pullToRefresh(){
        if (ReachabilityHelper.sharedInstance.connection == ReachabilityType.no_INTERNET){
            noInternet()
        }
        else {
            MyLocationManager.sharedInstance.refreshToCurrentLocation(self, numberOfResults : self.numberOfReults)
        }
        
    }
    
   
    
    func receivedPermissionResult(){
        let locationAuthorizationSystemSetting = MyLocationManager.isAllowedBySystem()
        if locationAuthorizationSystemSetting == false{
            hideLoadingScreen()
            self.hintToSettings(inAppSetting: false)
        } else if locationAuthorizationSystemSetting == true{
            MyLocationManager.sharedInstance.refreshToCurrentLocation(self, numberOfResults: self.numberOfReults)
        }
    }
    
 
    
    func showLoadingScreen() {
        
        
        if let v = self.loadingView {
            self.loadingView?.frame = self.view.frame
            self.loadingView?.frame.origin.y  -= 120
            self.loadingView?.tag = 99
            
            
            v.labelMessage.text = "Bitte Warten ... "
            self.view.addSubview(v)
            v.bringSubviewToFront(self.view)
            v.activityIndicator.startAnimating()
            v.viewLoadingHolder.backgroundColor = UIColor(white: 0.4, alpha: 0.8)
            v.viewLoadingHolder.layer.cornerRadius = 5
            v.viewLoadingHolder.layer.masksToBounds = true;
            print("added loading screen")
        }
        
    }
    
    func hideLoadingScreen() {
        self.loadingView?.activityIndicator.stopAnimating()
        self.loadingView?.removeFromSuperview()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //Always set the current controller as the delegate to ReachabilityHelper
        ReachabilityHelper.sharedInstance.delegate = self
        
        MyLocationManager.sharedInstance.refreshToCurrentLocation(self, numberOfResults: self.numberOfReults)
        
        self.trackViewControllerTitleToAnalytics()
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return self.locationData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let locationCell : afLocationTableViewCell = tableView.dequeueReusableCell(withIdentifier: "afLocationTableViewCell") as! afLocationTableViewCell
        locationCell.labelTitel.text = self.locationData[(indexPath as NSIndexPath).row]
        if self.locationCategories[(indexPath as NSIndexPath).row] == "" {
            locationCell.labelCategory.text = "Keiner Kategorie zugeordnet"
        } else {
            locationCell.labelCategory.text = self.locationCategories[(indexPath as NSIndexPath).row]
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
        locationCell.labelDistance.text = self.locationDistances[(indexPath as NSIndexPath).row]
        return locationCell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedArticle : LocationArticleResult = LocationArticleHolder.sharedInstance.articles[(indexPath as NSIndexPath).row]
        //convert the LocationResult to be a Searchresult for handling in the DetailViewController - this would be a good place for an Adapter ;)
        
        SearchHolder.sharedInstance.selectedItem = SearchResult(title: selectedArticle.title, name: selectedArticle.name, url: selectedArticle.url, score: 100, licenseResult: selectedArticle.licenseResult)
        
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        print("ViewWillDisappear")
        super.viewWillDisappear(animated)
    }
    
    func receivedErrorFromLocationManager(){
        showLocationErrorDialog()
    }
    
}

extension NearbyArticlesViewController : NetworkDelegation {
    
    func onRequestFailed(){
        print("no location articles")
        noInternet()
        self.refreshControl?.endRefreshing()
    }
    func onRequestSuccess(_ from: String){
        print("Success in LocaitonTableView")
        print("appending to tableview Location")
        hideLoadingScreen()
        self.refreshControl?.endRefreshing()
        //delete previous results
        DispatchQueue.main.async(execute: {
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
    
    func hintToSettings(inAppSetting: Bool) {
        let alertController : UIAlertController = UIAlertController(title: "Ortungsdienste", message: "Austria-Forum darf zur Zeit nicht auf ihren Standort zugreifen. Sie können dies in den Einstellungen ändern wenn Sie wollen.", preferredStyle: UIAlertController.Style.alert)
        let actionAbort : UIAlertAction = UIAlertAction(title: "Abbruch", style: UIAlertAction.Style.cancel, handler: {
            cancleAction in
            _ = self.navigationController?.popViewController(animated: true)
        })
        let actionToSettings : UIAlertAction = UIAlertAction(title: "Einstellungen", style: UIAlertAction.Style.default, handler: {
            alertAction  in
            print("go to settings")
            if inAppSetting{
                self.performSegue(withIdentifier: "toSettings", sender: self)
            } else {
                let settingsUrl = URL(string: UIApplication.openSettingsURLString)
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(settingsUrl!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                    UIApplication.shared.openURL(settingsUrl!)
                }
                
            }
        })
        alertController.addAction(actionAbort)
        alertController.addAction(actionToSettings)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    func showLocationErrorDialog(){
        let alertController : UIAlertController = UIAlertController(title: "Ortungsdienste", message: "Austria-Forum konnte keine Artikel in der Nähe finden da aktuell nicht die Berechtigung für Ihren Standort geben ist. Wollen Sie dies in den Einstellungen ändern?", preferredStyle: UIAlertController.Style.alert)
        let actionAbort : UIAlertAction = UIAlertAction(title: "Nein", style: UIAlertAction.Style.cancel, handler: {
            cancleAction in
            _ = self.navigationController?.popViewController(animated: true)
            
        })
        let actionToSettings : UIAlertAction = UIAlertAction(title: "Einstellungen", style: UIAlertAction.Style.default, handler: {
            alertAction  in
            let settingsUrl = URL(string: UIApplication.openSettingsURLString)
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(settingsUrl!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            } else {
                UIApplication.shared.openURL(settingsUrl!)
            }
        })
        alertController.addAction(actionAbort)
        alertController.addAction(actionToSettings)
        self.present(alertController, animated: true, completion: nil)
    }
    
}

extension NearbyArticlesViewController : ReachabilityDelegate {
    func noInternet() {
        
        self.noInternetView = Bundle.main.loadNibNamed("LoadingScreen", owner: self, options: nil)![0] as? LoadingScreen
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
        self.perform(#selector(NearbyArticlesViewController.hideNoInternetView), with: self, afterDelay: 1)
        
    }
    
    @objc func hideNoInternetView(){
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
