//
//  MonthlyArticle.swift
//  Austria-Forum
//
//  Created by Paul Neuhold Privat on 22.11.19.
//  Copyright © 2019 Paul Neuhold. All rights reserved.
//

import Foundation

struct MonthlyArticle: Article, Result,  Decodable {
    var license: LicenseMap?
    var title: String
    var url: String
    var page: String
    var ResultCode: String
    
    enum CodingKeys: String, CodingKey {
        case title, url, license, ResultCode
        case page = "name"
    }
}
