//
//  StartViewController.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 10.12.15.
//  Copyright © 2015 Paul Neuhold. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

class StartViewController: UIViewController {
    
    
    // MARK: - Properties
    
    
    @IBOutlet weak var lStart: UILabel!
    
    
    // MARK: - Override Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserData.sharedInstance.checkIfAppStartsTheFirstTime() {
            self.performSegue(withIdentifier: "toDetailView", sender: self)
        } else {
            self.rememberUserStartedAppTheFirstTime()
        }
   
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
    }
    
    
    // MARK: - Custom Functions
    /*
        just remeber the user started the app for the firsttime
    */
    func rememberUserStartedAppTheFirstTime(){
        UserData.sharedInstance.setValueForKey("App already started once" as AnyObject, key: UserDefaultKeys.kFirstTimeStartingAppString)
       
    }
    
}
