//
//  File.swift
//  Austria-Forum
//
//  Created by Paul Neuhold Privat on 22.11.19.
//  Copyright © 2019 Paul Neuhold. All rights reserved.
//

import Foundation

struct PageInfo: Article, Result, Decodable {
    var ResultCode: String
    var license: LicenseMap?
    var title: String
    var url: String
    var page: String
    var query: String
    
    enum CodingKeys: String, CodingKey {
           case url, title, ResultCode, license, query
           case page = "name"
    }
}

