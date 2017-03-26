//
//  AboutViewController.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 07.04.16.
//  Copyright © 2016 Paul Neuhold. All rights reserved.
//

import Foundation
import UIKit

class AboutViewController: UIViewController, UITextViewDelegate {
    
    
    //MARK: IBOutlets
    
    @IBOutlet weak var appTitleLabel: UILabel!
    @IBOutlet weak var appVersionLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var usedLibsTextView: UITextView!
    @IBOutlet weak var iconsDescription: UITextView!
    
    
    //MARK: Properties
    
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        self.setRessources()
//        if let title = self.title {
//            self.screenName = title
//        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.trackViewControllerTitleToAnalytics()
    }
    
    
    //MARK: Custom Functions
    fileprivate func setRessources(){
        if let bundleVersion = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] {
            appVersionLabel.text?.append(" \(bundleVersion)")
        }
        appTitleLabel.text = "Austria-Forum"
        
        
        buildAndSetContentText()
        buildAndSetUsedLibsText()
        buildAndSetIconsDescription()
        
        contentTextView.delegate = self
        contentTextView.isUserInteractionEnabled = true
        contentTextView.isScrollEnabled = false
        contentTextView.dataDetectorTypes = UIDataDetectorTypes.link
        contentTextView.isSelectable = true
        
        usedLibsTextView.delegate = self
        usedLibsTextView.isUserInteractionEnabled = true
        usedLibsTextView.isScrollEnabled = false
        usedLibsTextView.dataDetectorTypes = UIDataDetectorTypes.link
        usedLibsTextView.isSelectable = true

       
        iconsDescription.delegate = self
        iconsDescription.isUserInteractionEnabled = true
        iconsDescription.dataDetectorTypes = UIDataDetectorTypes.link
        iconsDescription.isSelectable = true
        iconsDescription.isScrollEnabled = false
        
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        print("should interact with url: \(URL.absoluteString)")
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(URL)
        }
        return false
    }
    
    fileprivate func buildAndSetIconsDescription() {
        
        let icon8Link : NSMutableAttributedString = NSMutableAttributedString(string: "icons8.com")
        icon8Link.addAttribute(NSLinkAttributeName, value: "http://www.icons8.com", range: NSMakeRange(0, icon8Link.length))
        let fullIconsDescriptionText : NSMutableAttributedString = NSMutableAttributedString(string: "Die in der Toolbar verwendeten Icons stammen von ")
        fullIconsDescriptionText.append(icon8Link)
        iconsDescription.attributedText = fullIconsDescriptionText
        
    }
    
    fileprivate func buildAndSetContentText(){

        let afAttributeLink : NSMutableAttributedString = NSMutableAttributedString(string: "austria-forum.org")
        afAttributeLink.addAttribute(NSLinkAttributeName, value: UserData.AF_URL, range: NSMakeRange(0, afAttributeLink.length))
        let fullContentText = NSMutableAttributedString(string: "Alle angezeigten Inhalte dieser App wurden zur Verfügung gestellt von ")
        fullContentText.append(afAttributeLink)
        contentTextView.attributedText = fullContentText
    }
    
    fileprivate func buildAndSetUsedLibsText(){
        
        let alamoLink : NSMutableAttributedString = NSMutableAttributedString(string: "AlamoFire")
        let alamoLicense : NSMutableAttributedString = NSMutableAttributedString(string: "Lizenz")
        
        alamoLink.addAttribute(NSLinkAttributeName, value: "https://github.com/Alamofire/Alamofire", range: NSMakeRange(0, alamoLink.length))
        alamoLicense.addAttribute(NSLinkAttributeName, value: "https://github.com/Alamofire/Alamofire/blob/master/LICENSE", range: NSMakeRange(0, alamoLicense.length))
        
        let swiftyJSONLink : NSMutableAttributedString = NSMutableAttributedString(string: "SwiftyJSON")
        let siwftyJSONLizenz : NSMutableAttributedString = NSMutableAttributedString(string: "Lizenz")
        
        swiftyJSONLink.addAttribute(NSLinkAttributeName, value: "https://github.com/SwiftyJSON/SwiftyJSON", range: NSMakeRange(0, swiftyJSONLink.length))
        siwftyJSONLizenz.addAttribute(NSLinkAttributeName, value: "https://github.com/SwiftyJSON/SwiftyJSON/blob/master/LICENSE", range: NSMakeRange(0, siwftyJSONLizenz.length))
        
        let reachabilityLink : NSMutableAttributedString = NSMutableAttributedString(string: "Reachability")
        let reachabilityLizenz : NSMutableAttributedString = NSMutableAttributedString(string: "Lizenz")
        
        reachabilityLink.addAttribute(NSLinkAttributeName, value: "https://github.com/ashleymills/Reachability.swift", range: NSMakeRange(0, reachabilityLink.length))
        reachabilityLizenz.addAttribute(NSLinkAttributeName, value: "https://github.com/ashleymills/Reachability.swift/blob/master/LICENSE", range: NSMakeRange(0, reachabilityLizenz.length))
        
        let fabricLink : NSMutableAttributedString = NSMutableAttributedString(string: "Fabric")
        let fabricLizenz : NSMutableAttributedString = NSMutableAttributedString(string: "Lizenz")
        
        fabricLink.addAttribute(NSLinkAttributeName, value: "https://fabric.io", range: NSMakeRange(0, fabricLink.length))
        fabricLizenz.addAttribute(NSLinkAttributeName, value: "https://fabric.io/privacy", range: NSMakeRange(0, fabricLizenz.length))
        
        let openBracket = NSMutableAttributedString(string: " (")
        let closeBracket = NSMutableAttributedString(string: ")")
        let comma = NSMutableAttributedString(string: ", ")
        
        let fullUsedLibContent = NSMutableAttributedString(string: "")
        let attributedStrings : [NSMutableAttributedString] = [alamoLink,openBracket,alamoLicense,closeBracket,comma,swiftyJSONLink,openBracket,siwftyJSONLizenz,closeBracket,comma,
                                                               reachabilityLink,openBracket,reachabilityLizenz,closeBracket,comma,fabricLink,openBracket,fabricLizenz,closeBracket]
        for aStr in attributedStrings {
            fullUsedLibContent.append(aStr)
        }
        
        usedLibsTextView.attributedText = fullUsedLibContent
        
        
        
        
    }
    
    /*
     NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:@"Google"];
     [str addAttribute: NSLinkAttributeName value: @"http://www.google.com" range: NSMakeRange(0, str.length)];
     yourTextView.attributedText = str;
 */
}
