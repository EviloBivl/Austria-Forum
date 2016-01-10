//
//  FavouritesHolder.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 09.01.16.
//  Copyright © 2016 Paul Neuhold. All rights reserved.
//

import Foundation

class FavouritesHolder {
    
    static let sharedInstance = FavouritesHolder()
    let pListWorker: ReadWriteToPList
    
    var favourites : Array<[String:String]> = [[:]]
    var countOfFavourites : Int = 0
    
    private init(){
        
        self.pListWorker = ReadWriteToPList()
        pListWorker.loadFavourites()
        self.favourites = pListWorker.favourites
        self.countOfFavourites = pListWorker.countOfFavourites
    }
    
    func refresh(){
        pListWorker.loadFavourites()
        self.favourites = pListWorker.favourites
        self.countOfFavourites = pListWorker.countOfFavourites

    }
    
    
    
    
    
}
