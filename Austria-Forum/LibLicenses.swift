//
//  Acknowledgements.swift
//  Cashback
//
//  Created by Paul Neuhold on 19.03.19.
//  Copyright © 2019 myWorld Solutions AG. All rights reserved.
//
import Foundation


public struct LibLicenses: Decodable {
    
    public let stringsTable: String?
    public let title: String?
    public let licensesList: [LibLicense]?
    
    
    enum CodingKeys: String, CodingKey {
        case licensesList = "PreferenceSpecifiers"
        case title = "Title"
        case stringsTable = "StringsTable"
    }
    
    public init?(plistFile: String) {
        guard let url = Bundle.main.url(forResource: plistFile, withExtension: "plist") else { return nil }
        do {
            let data = try Data(contentsOf:url)
            self = try PropertyListDecoder().decode(LibLicenses.self, from: data)
        } catch {
            print(error)
            return nil
        }
    }
}

public struct LibLicense: Decodable {
    public var footerText: String?
    public var licenseText: String?
    public var type: String?
    public var title: String?
    
    private enum CodingKeys: String, CodingKey {
        case footerText = "FooterText"
        case licenseText = "License"
        case title = "Title"
        case type = "Type"
    }
}

