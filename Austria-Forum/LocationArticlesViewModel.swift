//
//  LocationArticlesViewModel.swift
//  Austria-Forum
//
//  Created by Paul Neuhold Privat on 02.02.20.
//  Copyright © 2020 Paul Neuhold. All rights reserved.
//

import Foundation
import CoreLocation

class LocationArticlesViewModel {
    
    var locationArticles: [afLocationTableViewCell.Content] = [afLocationTableViewCell.Content]()
    var locationManager: MyLocationManager
    var isLoading: Bool = false
    weak var delegate: LocationArticlesViewControllerDelegate?
    
    init(locationManager: MyLocationManager){
        self.locationManager = locationManager
        self.locationManager.add(observer: self)
    }
    
    deinit {
        self.locationManager.remove(observer: self)
    }
    
    func numberOfRows(for section: Int) -> Int? {
        return locationArticles.count
    }
    
    var numberOfSections: Int {
        return 1
    }
    
    func content(at indexPath: IndexPath) -> afLocationTableViewCell.Content? {
        guard locationArticles.indices.contains(indexPath.row) else { return nil }
        return locationArticles[indexPath.row]
    }
    
    func loadData(){
        guard let coordinates = locationManager.lastCoordinates, !isLoading else {
            locationManager.requestWhenInUse()
            return
        }
        isLoading = true
        delegate?.signalUpdate()
        RequestManager.sharedInstance.getArticlesByLocation(self, location: coordinates , numberOfResults: 250)
    }
    
}

extension LocationArticlesViewModel: MyLocationManagerObserver {
    func didUpdateLocation(location: CLLocationCoordinate2D) {
        loadData()
    }
    
    func didChangeAuthorizationStatus(status: CLAuthorizationStatus) {
        loadData()
    }
}


extension LocationArticlesViewModel: NetworkDelegation {
    func onRequestSuccess(_ from: String) {
        isLoading = false
        locationArticles.removeAll()
        locationArticles = LocationArticleHolder.sharedInstance.articles.compactMap {
            return afLocationTableViewCell.Content(title: $0.title,
                                                   category: CategoriesListed.GetBeautyCategoryFromUrlString($0.url),
                                                   distance: $0.distanceString,
                                                   url: $0.url)
        }
        DispatchQueue.main.async {
            self.delegate?.signalUpdate()
        }
    }
    
    func onRequestFailed() {
        isLoading = false
        DispatchQueue.main.async {
            self.delegate?.signalUpdate()
        }
    }
    
    func noInternet() {
        isLoading = false
        DispatchQueue.main.async {
            self.delegate?.signalUpdate()
        }
    }
}
