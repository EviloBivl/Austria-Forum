//
//  ViewModel.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 14.05.18.
//  Copyright © 2018 Paul Neuhold. All rights reserved.
//

import Foundation

protocol ViewModelObserver: class {
    func signalUpdate()
}

class ViewModel {
    weak var delegate: ViewModelObserver? 
}
