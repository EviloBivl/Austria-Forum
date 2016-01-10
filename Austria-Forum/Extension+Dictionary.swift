//
//  NSDictionary+Extension_NSDictionary.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 10.01.16.
//  Copyright © 2016 Paul Neuhold. All rights reserved.
//

import Foundation


extension Dictionary {
    
    func isEqual(toCompare: [String:String]) -> Bool {
        
        //count of entries are simply not equal
        if self.count != toCompare.count {
            return false
        }
        
        for (key, val) in self {
            if let v = val as? String, k = key as? String {
                if toCompare[k] != v{
                    return false
                }
            }
        }
        return true
    }
}
