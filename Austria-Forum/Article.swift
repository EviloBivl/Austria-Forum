//
//  Article.swift
//  Austria-Forum
//
//  Created by Paul Neuhold Privat on 22.11.19.
//  Copyright © 2019 Paul Neuhold. All rights reserved.
//

import Foundation

protocol Article {
    var license: LicenseMap? { get set }
    var title: String { get set }
    var url: String { get set }
    var page: String { get set }
}

protocol Result: Decodable {
    var ResultCode: String { get set }
}
