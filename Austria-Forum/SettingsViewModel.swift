//
//  SettingsViewModel.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 14.05.18.
//  Copyright © 2018 Paul Neuhold. All rights reserved.
//

import Foundation

class SettingsViewModel: ViewModel {
    
    public enum SettingsPickerType: Int {
        case location = 0
        case push = 1
        case category = 2
        
        static func type(for int: Int) -> SettingsPickerType? {
            switch int {
            case 0:
                return .location
            case 1:
                return .push
            case 2:
                return .category
            default:
                return nil
            }
        }
    }
    
    
    var pushPickerOptions : [String] = ["1 Minute", "5 Minuten" , "10 Minuten" , "15 Minuten", "30 Minuten" , "60 Minuten", "2 Stunden"]
    var pushPickerValues : [Int] = [1 * 60,5 * 60,10 * 60,15 * 60,30 * 60,60 * 60, 120*60]
    
    var distancePickerOptions : [String] = ["20 Meter","50 Meter","100 Meter","250 Meter","500 Meter","1 Km","2 Km"]
    var distancePickerValues : [Int] = [20,50,100,250,500,1000,2000]
    
    var categoryPickerOptions : [String] = ["Alle","AEIOU","Alltagskultur","AustriaWiki","Bilder & Videos","Community","Geography","Kunst & Kultur","Natur","Politik & Geschichte","Videos","Wissenschaft & Wirtschaft","Biographien","Essays", "Web Books"]
    var categoryPickerValues : [String] = ["ALL","AEIOU","Alltagskultur","AustriaWiki","Bilder_und_Videos","Community","Geography","Kunst_und_Kultur","Natur","Politik_und_Geschichte","Videos","Wissenschaft_und_Wirtschaft","Wissenssammlungen/Biographien","Wissenssammlungen/Essays", "Web_Books"]
    
    
    
    override init(){
        
    }
    
    func numberOfRows(for pickerViewTag: Int) -> Int {
        guard let type = SettingsPickerType.type(for: pickerViewTag) else {
            return 0
        }
        switch type {
        case .location:
            return distancePickerOptions.count
        case .push:
            return pushPickerOptions.count
        case .category:
            return categoryPickerOptions.count
        }
    }
    
    func pickerTitle(for pickerViewTag: Int, at pickerRow: Int) -> String? {
        guard let type = SettingsPickerType.type(for: pickerViewTag) else {
                return nil
        }
        switch type {
        case .location:
            return distancePickerOptions.element(at: pickerRow)
        case .push:
            return pushPickerOptions.element(at: pickerRow)
        case .category:
            return categoryPickerOptions.element(at: pickerRow)
        }
    }
    
    func pickerType(for pickerViewTag: Int) -> SettingsPickerType? {
        return SettingsPickerType.init(rawValue: pickerViewTag)
    }
    
    func didSelectPickerView(at row: Int, with pickerTagView: Int){
        guard let pickerType = SettingsPickerType.type(for: pickerTagView) else { return }
        switch pickerType {
        case .location:
            UserData.sharedInstance.notificationIntervalInSeconds = pushPickerValues[row]
            delegate?.signalUpdate()
        case .push:
            UserData.sharedInstance.locationChangeValue = distancePickerValues[row]
            delegate?.signalUpdate()
        case .category:
            UserData.sharedInstance.categorySelected = categoryPickerValues[row]
            break
        }
    }
    
    
    
    
    func addDebugOptions(){
        pushPickerOptions.insert("5s debug", at: 0)
        pushPickerValues.insert(5, at: 0)
        
        distancePickerValues.insert(0, at: 0)
        distancePickerOptions.insert("always", at: 0)
        
        categoryPickerValues.append("not_existing")
        categoryPickerOptions.append("force fail");
    }
    
    
    
    
}
