//
//  PushNotificationTimeIntervalSelectionViewModel.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 15.11.18.
//  Copyright © 2018 Paul Neuhold. All rights reserved.
//

import Foundation

class PushNotificationTimeIntervalSelectionViewModel: SelecteionTableViewControllerInfoProtocol {
    
    var pushPickerOptions : [String] = ["1 Minute", "5 Minuten" , "10 Minuten" , "15 Minuten", "30 Minuten" , "60 Minuten", "2 Stunden"]
    var pushPickerValues : [Int] = [1 * 60,5 * 60,10 * 60,15 * 60,30 * 60,60 * 60, 120*60]
    
    
    init(){}
    
    var numberOfRows: Int {
        return pushPickerValues.count
    }
    var numberOfSections: Int = 1
    
    func titleForRow(at index: Int) -> String? {
        guard pushPickerValues.indices.contains(index) else { return nil }
        return pushPickerOptions[index]
    }
    
    var title: String {
        return L10n.settingsTitlePushinterval
    }
    
    func cellType(at: IndexPath) -> SettingsSelectionViewController.CellType? {
        return SettingsSelectionViewController.CellType.pushIntervalRow
    }
    
    func content(at: IndexPath) -> String? {
        guard pushPickerOptions.indices.contains(at.row) else { return nil }
        return pushPickerOptions[at.row]
    }
    
}
