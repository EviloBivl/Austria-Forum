//
//  WeakBox.swift
//  Austria-Forum
//
//  Created by Paul Neuhold Privat on 03.02.20.
//  Copyright © 2020 Paul Neuhold. All rights reserved.
//

import Foundation

public struct WeakBox<T: AnyObject> {
    private(set) weak var object: T?
    init(_ value: T) {
        self.object = value
    }
}

public protocol Observer: class {}

public protocol Observable: class {
    
    associatedtype ObserverType
    
    var weakObservers: [WeakBox<AnyObject>] { get set }
}

public extension Observable {
    
    func add(observer: Observer) {
        cleanupObservers()
        
        let index = weakObservers.firstIndex { $0.object === observer}
        guard index == nil else {
            return
        }
        
        weakObservers.append(WeakBox(observer))
    }
    
    func remove(observer: Observer) {
        cleanupObservers()
        
        let index = weakObservers.firstIndex { $0.object === observer}
        guard let unwrappedIndex = index else {
            return
        }
        
        _ = weakObservers.remove(at: unwrappedIndex)
    }
    
    private func cleanupObservers() {
        weakObservers = weakObservers.filter { $0.object != nil }
    }
    
    var observers: [ObserverType] {
        return weakObservers.compactMap { $0.object as? ObserverType }
    }
}
