//
//  AboutViewModel.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 14.05.18.
//  Copyright © 2018 Paul Neuhold. All rights reserved.
//

import Foundation
import UIKit

class AboutViewModel: ViewModel {
    
    let titleApp = L10n.appTitle
    let titleVersion = L10n.titleVersion
    let titleUsedLibs = L10n.titleUsedLibs
    let titleContent = L10n.titleUsedContent
    let titleDevs = L10n.titleDevelopers
    let titleDevApp = L10n.titleAppDev
    let titleApiDev = L10n.titleApiDev
    let titleIcons = L10n.titleUsedIcons
    let titleAbout = L10n.navTitleAboutShort
    let backButtonTitle = L10n.navTitleSettings
    
    let appDeveloper = "Paul Neuhold"
    let apiDeveloper = "Gerhard Wurzinger"
    
    override init(){}

    var bundleVersion: String? {
        guard let bundleVersion = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String else { return nil }
        return "\(titleVersion) \(bundleVersion)"
    }
    
    var devContent: String {
        let contentApp = "\(titleDevApp): \(appDeveloper)"
        let newLine = "\n"
        let contentApi = "\(titleApiDev): \(apiDeveloper), \(appDeveloper)"
        return "\(contentApp)\(newLine)\(contentApi)"
    }

    var contentAttributedString: NSAttributedString {
        let afAttributeLink : NSMutableAttributedString = NSMutableAttributedString(string: L10n.afShortUrl)
        afAttributeLink.addAttribute( NSAttributedString.Key.link , value: UserData.AF_URL, range: NSMakeRange(0, afAttributeLink.length))
        let fullContentText = NSMutableAttributedString(string: L10n.contentAllContentFromAf)
        fullContentText.append(afAttributeLink)
        return fullContentText
    }
    
    var iconsDescriptionAttributedString: NSAttributedString {
        let icon8Link : NSMutableAttributedString = NSMutableAttributedString(string: L10n.icons8UrlText)
        icon8Link.addAttribute(NSAttributedString.Key.link, value: L10n.icons8UrlSource, range: NSMakeRange(0, icon8Link.length))
        let fullIconsDescriptionText : NSMutableAttributedString = NSMutableAttributedString(string: L10n.contentIconsSource)
        fullIconsDescriptionText.append(icon8Link)
        return fullIconsDescriptionText
    }
    
    var usedLibsAttributedString : NSAttributedString {
        
        let alamoLink : NSMutableAttributedString = NSMutableAttributedString(string: L10n.titleAlalmofire)
        let alamoLicense : NSMutableAttributedString = NSMutableAttributedString(string: L10n.titleLicense)
        
        alamoLink.addAttribute(NSAttributedString.Key.link, value: L10n.urlAlalmofire, range: NSMakeRange(0, alamoLink.length))
        alamoLicense.addAttribute(NSAttributedString.Key.link, value: L10n.licenseAlmofire, range: NSMakeRange(0, alamoLicense.length))
        
//        let swiftyJSONLink : NSMutableAttributedString = NSMutableAttributedString(string: L10n.titleSwiftyjson)
//        let siwftyJSONLizenz : NSMutableAttributedString = NSMutableAttributedString(string: L10n.titleLicense)
//
//        swiftyJSONLink.addAttribute(NSAttributedString.Key.link, value: L10n.urlSwiftyjson, range: NSMakeRange(0, swiftyJSONLink.length))
//        siwftyJSONLizenz.addAttribute(NSAttributedString.Key.link, value: L10n.licenseSwiftyjson, range: NSMakeRange(0, siwftyJSONLizenz.length))
//
        let reachabilityLink : NSMutableAttributedString = NSMutableAttributedString(string: L10n.titleReachability)
        let reachabilityLizenz : NSMutableAttributedString = NSMutableAttributedString(string: L10n.titleLicense)
        
        reachabilityLink.addAttribute(NSAttributedString.Key.link, value: L10n.urlReachability, range: NSMakeRange(0, reachabilityLink.length))
        reachabilityLizenz.addAttribute(NSAttributedString.Key.link, value: L10n.licenseReachability, range: NSMakeRange(0, reachabilityLizenz.length))
        
        let fabricLink : NSMutableAttributedString = NSMutableAttributedString(string: L10n.titleFabric)
        let fabricLizenz : NSMutableAttributedString = NSMutableAttributedString(string: L10n.titleLicense)
        
        fabricLink.addAttribute(NSAttributedString.Key.link, value: L10n.urlFabric, range: NSMakeRange(0, fabricLink.length))
        fabricLizenz.addAttribute(NSAttributedString.Key.link, value: L10n.licenseFabric, range: NSMakeRange(0, fabricLizenz.length))
        
        let openBracket = NSMutableAttributedString(string: " (")
        let closeBracket = NSMutableAttributedString(string: ")")
        let comma = NSMutableAttributedString(string: ", ")
        
        let fullUsedLibContent = NSMutableAttributedString(string: "")
        let attributedStrings : [NSMutableAttributedString] =
            [alamoLink,openBracket,alamoLicense,closeBracket,comma,
           // swiftyJSONLink,openBracket,siwftyJSONLizenz,closeBracket,comma,
            reachabilityLink,openBracket,reachabilityLizenz,closeBracket,comma,
            fabricLink,openBracket,fabricLizenz,closeBracket]
        
        for aStr in attributedStrings {
            fullUsedLibContent.append(aStr)
        }
        return fullUsedLibContent
    }
}
