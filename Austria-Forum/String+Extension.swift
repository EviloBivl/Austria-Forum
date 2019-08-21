//
//  String+Extension.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 31.03.17.
//  Copyright © 2017 Paul Neuhold. All rights reserved.
//

import Foundation

extension String {
    
    func getSkinnedAFUrl() -> String{
        if self.contains("?skin=page"){
            return self
        } else if self.contains("&skin=page"){
            return self
        } else if self.contains("?"){
            return self.appending("&skin=page")
        } else {
            return self.appending("?skin=page")
        }
    }
    
    func removeAFSkin () -> String {
        if self.contains("?skin=page"){
            return self.replacingOccurrences(of: "?skin=page", with: "")
        } else if self.contains("&skin=page") {
            return self.replacingOccurrences(of: "&skin=page", with: "")
        } else {
            return self
        }
    }
    
    func stripGETParameters() -> String {
        if (self.contains("?")){
            return self.components(separatedBy: "?").first!
        } else{
            return self
        }
    }
    
    func index(of char: Character) -> Int? {
        guard let index = self.index(where: { $0 == char}) else { return nil }
        return self.distance(from: startIndex, to: index)
    }
}
