//
//  Array+Extension.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 20.05.18.
//  Copyright © 2018 Paul Neuhold. All rights reserved.
//

import Foundation

extension Array {
    func element(at index: Int) -> Element? {
        guard self.indices.contains(index) else { return nil }
        return self[index]
    }
}
