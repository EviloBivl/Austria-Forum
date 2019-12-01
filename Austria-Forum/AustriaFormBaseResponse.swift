//
//  BaseResponse.swift
//  Austria-Forum
//
//  Created by Paul Neuhold Privat on 22.11.19.
//  Copyright © 2019 Paul Neuhold. All rights reserved.
//

import Foundation

public struct AustriaFormBaseResponse<T>: Decodable where T: Decodable {
    public let id: Int
    public let result: T
}

public struct ResultMap<T>: Decodable where T: Decodable {
    public let map: T
}

public struct ResultList<T>: Decodable where T: Decodable {
    public let list: [T]
}

struct LicenseMap: Decodable {
    let map: License
}
