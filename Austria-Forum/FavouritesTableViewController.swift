//
//  FavouritesTableViewController.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 09.01.16.
//  Copyright © 2016 Paul Neuhold. All rights reserved.
//

import UIKit
import PKHUD

class FavouritesTableViewController: UITableViewController {
    var viewModel: FavouritesViewModel?
    
    class func create(viewModel: FavouritesViewModel) -> FavouritesTableViewController {
        let controller = StoryboardScene.FavouriteViewController.favouritesTableViewController.instantiate()
        controller.viewModel = viewModel
        return controller
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        self.tableView.rowHeight = 60
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return FavouritesHolder.sharedInstance.countOfFavourites
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favouriteCell", for: indexPath)
        
        let articleDict = FavouritesHolder.sharedInstance.favourites[(indexPath as NSIndexPath).row]
        
        if let title = articleDict["title"], let url = articleDict["url"] , let cat = articleDict["category"]{
            cell.textLabel?.text = title
            if cat == "" {
                cell.detailTextLabel?.text = "Url: " + url
            }else  {
                cell.detailTextLabel?.text = "Kategorie: " + cat
            }
            
            
            
        } else {
          //nothing 
        }
        
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (ReachabilityHelper.sharedInstance.connection == ReachabilityType.no_INTERNET){
            noInternet()
        } else {
            let selectedFavourite = (FavouritesHolder.sharedInstance.favourites[(indexPath as NSIndexPath).row])
            //Note: we ignore the license here for now - because we load it with getPageInfo anyway
            let searchResult : SearchResult = SearchResult(title: selectedFavourite["title"], name: selectedFavourite["title"], url: selectedFavourite["url"], score: 100,
            licenseResult: .none)
            SearchHolder.sharedInstance.selectedItem = searchResult
            _ = self.navigationController?.popViewController(animated: true)
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
