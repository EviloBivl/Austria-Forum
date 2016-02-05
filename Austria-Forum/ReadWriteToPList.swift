//
//  ReadWriteToPList.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 08.01.16.
//  Copyright © 2016 Paul Neuhold. All rights reserved.
//

import Foundation


class ReadWriteToPList {
    
    static let kFavourites : String = "kFavourites"
    /*
    You need to call loadGameData() before you can access the favourites
    */
    var favourites : Array<[String:String]> = [[:]]
    
    /*
    You need to call loadGameData() before you can access the number favourites
    */
    var countOfFavourites : Int = 0
    
    func loadFavourites() -> Bool {
        
        // getting path to GameData.plist
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths[0] as! NSString
        let path = documentsDirectory.stringByAppendingPathComponent("Favourites.plist")
        
        let fileManager = NSFileManager.defaultManager()
        
        //check if file exists
        if(!fileManager.fileExistsAtPath(path)) {
            // If it doesn't, copy it from the default file in the Bundle
            if let bundlePath = NSBundle.mainBundle().pathForResource("Favourites", ofType: "plist") {
                
                let resultDictionary = NSMutableDictionary(contentsOfFile: bundlePath)
                print("Bundle Favourites.plist file is --> \(resultDictionary?.description)")
                
                do {
                    try fileManager.copyItemAtPath(bundlePath, toPath: path)
                } catch _ {
                    print("exception happend")
                    return false
                }
                
                print("copy")
            } else {
                print("Favourites.plist not found. Please, make sure it is part of the bundle.")
                return false
            }
        } else {
            print("Favourites.plist already exits at path.")
            // use this to delete file from documents directory
            //fileManager.removeItemAtPath(path, error: nil)
        }
        
        
        let myDict = NSDictionary(contentsOfFile: path)
        
        if let dict = myDict {
            //loading values
            print("loaded values are:")
            for (key,val) in dict {
                if key as! String == "Favourites"{
                    self.favourites = val as! Array<[String : String]>
                }
                if key as! String == "CountOfFavourites" {
                    self.countOfFavourites = val as! Int
                }
               
            }
            //...
        } else {
            print("WARNING: Couldn't create dictionary from Favourites.plist!")
            return false
        }
        return true
    }
    
    func saveFavourite(articleToSave : [String:String]) -> Bool {
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths.objectAtIndex(0) as! NSString
        let path = documentsDirectory.stringByAppendingPathComponent("Favourites.plist")
        
        let dict: NSMutableDictionary = [:]
        self.countOfFavourites++
        dict.setObject(self.countOfFavourites, forKey: "CountOfFavourites")
        self.favourites.append(articleToSave)
        dict.setObject(self.favourites, forKey: "Favourites")
        
        //writing to Favourite.plist
        if dict.writeToFile(path, atomically: false) {
            return true
        } else {
            self.favourites.removeLast()
            self.countOfFavourites--
            return false
        }
    }
    
    func isFavourite (article: [String:String]) -> Bool {
        
        
         if (!article.keys.contains("url")){
            print("The Key \"url\" is not within the givin Dictionary for CHECKING if the article is a Favourite")
            return false
         }
        
        //first reload the values
        if !self.loadFavourites() {
            return false
        }
        //search if the given article url exists
        for dict in self.favourites {
            if dict["url"] == article["url"]{
                return true
            }
            if dict["url"]?.stringByAppendingString("?skin=page") == article["url"]{
                return true
            }
        }
        return false
    }
    
    /*
    In Order to remove a Favourite properly the given article MUST contain the Url. Removing based on category or title is not working
    */
    func removeFavourite(articleToRemove: [String: String]) -> Bool {
        
        if (!articleToRemove.keys.contains("url")){
            print("The Key \"url\" is not within the given Dictionary for REMOVEING a Favourite")
            return false
        }
        
        var removeIt : Bool = false
        var removeIndex = 0
        //first reload all values
        if !self.loadFavourites() {
            return false
        }
        //remove it from the loaded values
        for arrayElement in self.favourites {
            if arrayElement["url"] == articleToRemove["url"]{
                removeIt = true
                break
            }
            removeIndex++
        }
        if removeIt {
            self.favourites.removeAtIndex(removeIndex)
            self.countOfFavourites--
            
            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
            let documentsDirectory = paths.objectAtIndex(0) as! NSString
            let path = documentsDirectory.stringByAppendingPathComponent("Favourites.plist")
            
            let dict: NSMutableDictionary = [:]
            dict.setObject(self.countOfFavourites, forKey: "CountOfFavourites")
            dict.setObject(self.favourites, forKey: "Favourites")
            if dict.writeToFile(path, atomically: false) {
                return true
            } else {
                return false
            }
            
        }
        return false
    }
}