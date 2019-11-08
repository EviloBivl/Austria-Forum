//
//  SettingsSelectionViewController.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 15.11.18.
//  Copyright © 2018 Paul Neuhold. All rights reserved.
//

import Foundation
import UIKit

protocol SelecteionTableViewControllerInfoProtocol {
    var numberOfRows: Int { get }
    var numberOfSections: Int { get }
    func cellType(at: IndexPath) -> SettingsSelectionViewController.CellType?
    func content(at: IndexPath) -> String?
}

class SettingsSelectionViewController: UITableViewController {
    
    var viewModel : SelecteionTableViewControllerInfoProtocol?
    
    enum CellType {
        case pushIntervalRow
        case locationDistanceRow
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = PushNotificationTimeIntervalSelectionViewModel()
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let _ = viewModel?.cellType(at: indexPath) else { return UITableViewCell()}
        
        let cell = UITableViewCell()
        cell.textLabel?.text = viewModel?.content(at: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfRows ?? 0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.numberOfSections ?? 0
    }
    
    
}
