//
//  LicenseResult.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 19.07.16.
//  Copyright © 2016 Paul Neuhold. All rights reserved.
//

import Foundation

public struct License: Decodable {
    public let css : String?
    public let title: String?
    public let url: String?
    public let id: String?
}
