//
//  SearchArticle.swift
//  Austria-Forum
//
//  Created by Paul Neuhold Privat on 22.11.19.
//  Copyright © 2019 Paul Neuhold. All rights reserved.
//

import Foundation

struct SearchArticle: Article, Decodable {
    var license: LicenseMap?
    var title: String
    var url: String
    var page: String
    var score: Int
}
