//
//  FavouritesTableViewController.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 09.01.16.
//  Copyright © 2016 Paul Neuhold. All rights reserved.
//

import UIKit

class FavouritesTableViewController: UITableViewController {
    
    var noInternetView: LoadingScreen?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //Always set the current controller as the delegate to ReachabilityHelper
        ReachabilityHelper.sharedInstance.delegate = self
    }
    
    // MARK: - Table view data source
    /*
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    
    return FavouritesHolder.sharedInstance.countOfFavourites
    }
    */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return FavouritesHolder.sharedInstance.countOfFavourites
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("favouriteCell", forIndexPath: indexPath)
        
        let articleDict = FavouritesHolder.sharedInstance.favourites[indexPath.row]
        
        if let title = articleDict["title"], let url = articleDict["url"] , let cat = articleDict["category"]{
            cell.textLabel?.text = title
            if cat == "" {
                cell.detailTextLabel?.text = "Url: " + url
            }else  {
                cell.detailTextLabel?.text = "Kategorie: " + cat
            }
            
            
            
        } else {
            cell.textLabel?.text = "from signifcant change launch"
            cell.detailTextLabel?.text = "right"
            
        }
        
        
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (ReachabilityHelper.sharedInstance.connection == ReachabilityType.NO_INTERNET){
            noInternet()
        } else {
            let selectedFavourite = (FavouritesHolder.sharedInstance.favourites[indexPath.row])
            let searchResult : SearchResult = SearchResult(title: selectedFavourite["title"]!, name: selectedFavourite["title"]!, url: selectedFavourite["url"]!, score: 100)
            SearchHolder.sharedInstance.selectedItem = searchResult
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
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

extension FavouritesTableViewController : ReachabilityDelegate {
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
