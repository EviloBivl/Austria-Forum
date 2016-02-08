//
//  LicenseManager.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 05.02.16.
//  Copyright © 2016 Paul Neuhold. All rights reserved.
//

import Foundation

class LicenseManager {
    
    class func getImageNameForLicense(licenseName : String) -> String? {
        
        if let license = LicenseName(rawValue: licenseName){
            
            switch (license) {
            case LicenseName.AF:
                return "af_license.png"
            case LicenseName.PD:
                return "publicdomain.png"
            case LicenseName.CC0:
                return "cc-zero.png"
            case LicenseName.CCBY:
                return "by.png"
            case LicenseName.CCBYSA:
                return "by-sa.png"
            case LicenseName.CCBYSA30:
                return "by-sa.png"
            case LicenseName.CCBYND:
                return "by-nd.png"
            case LicenseName.CCBYNC:
                return "by-nc.png"
            case LicenseName.CCBYNCSA:
                return "by-nc-sa.png"
            case LicenseName.CCBYNCND:
                return "by-nc-nd.png"
            }
        }
        
        
        return .None
    }
    
    
    class func getLinkForLicense(licenseName : String) -> String? {
        
        if let license = LicenseName(rawValue: licenseName){
            
            switch (license) {
            case LicenseName.AF:
                return LicenseUrl.AF.rawValue
            case LicenseName.PD:
                return LicenseUrl.PD.rawValue
            case LicenseName.CC0:
                return LicenseUrl.CC0.rawValue
            case LicenseName.CCBY:
                return LicenseUrl.CCBY.rawValue
            case LicenseName.CCBYSA:
                return LicenseUrl.CCBYSA.rawValue
            case LicenseName.CCBYSA30:
                return LicenseUrl.CCBYSA30.rawValue
            case LicenseName.CCBYND:
                return LicenseUrl.CCBYND.rawValue
            case LicenseName.CCBYNC:
                return LicenseUrl.CCBYNC.rawValue
            case LicenseName.CCBYNCSA:
                return LicenseUrl.CCBYNCSA.rawValue
            case LicenseName.CCBYNCND:
                return LicenseUrl.CCBYNCND.rawValue
            }
        }
        return .None
    }
        
}

enum LicenseName : String{
    case AF = "AF"
    case PD = "PD"
    case CC0 = "CC0"
    case CCBY = "CCBY"
    case CCBYSA = "CCBYSA"
    case CCBYSA30 = "CCBYSA30"
    case CCBYND = "CCBYND"
    case CCBYNC = "CCBYNC"
    case CCBYNCSA = "CCBYNCSA"
    case CCBYNCND = "CCBYNCND"
    
    func rawValueToType(raw: String) -> LicenseName? {
        return LicenseName(rawValue: raw)
    }
}

enum LicenseUrl : String {
    case AF = "http://austria-forum.org/af/Lizenzen/Austria-Forum"
    case PD = "https://creativecommons.org/about/pdm/"
    case CC0 = "https://creativecommons.org/publicdomain/zero/1.0/"
    case CCBY = "https://creativecommons.org/licenses/by/4.0/"
    case CCBYSA = "https://creativecommons.org/licenses/by-sa/4.0/"
    case CCBYSA30 = "https://creativecommons.org/licenses/by-sa/3.0/"
    case CCBYND = "https://creativecommons.org/licenses/by-nd/4.0/"
    case CCBYNC = "https://creativecommons.org/licenses/by-nc/4.0/"
    case CCBYNCSA = "https://creativecommons.org/licenses/by-nc-sa/4.0/"
    case CCBYNCND = "https://creativecommons.org/licenses/by-nc-nd/4.0/"
}
