//
//  AboutViewController.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 07.04.16.
//  Copyright © 2016 Paul Neuhold. All rights reserved.
//

import Foundation
import UIKit

class AboutViewController: UIViewController {
    
    var viewModel: AboutViewModel?
    
    class func create(viewModel: AboutViewModel) -> AboutViewController {
       let controller = StoryboardScene.About.aboutViewController.instantiate()
       controller.viewModel = viewModel
       return controller
    }

    //MARK: IBOutlets
    @IBOutlet weak var appTitleLabel: UILabel!
    @IBOutlet weak var appVersionLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var usedLibsTextView: UITextView!
    @IBOutlet weak var iconsDescription: UITextView!
    @IBOutlet weak var developersTitle: UILabel!
    @IBOutlet weak var developersTextView: UITextView!
    @IBOutlet weak var contentTitleLabel: UILabel!
    @IBOutlet weak var usedLibsLabel: UILabel!
    @IBOutlet weak var usedIconsLabel: UILabel!
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        self.setupUI()
    }
    
    //MARK: Custom Functions
    fileprivate func setupUI(){
        guard let viewModel = viewModel else { return }
        
        navigationItem.backBarButtonItem?.title = viewModel.backButtonTitle
        appVersionLabel.text = viewModel.bundleVersion
        appTitleLabel.text = viewModel.titleApp
        
        contentTitleLabel.text = viewModel.titleContent
        contentTextView.attributedText = viewModel.contentAttributedString
        usedLibsLabel.text = viewModel.titleUsedLibs
        usedLibsTextView.attributedText = viewModel.usedLibsAttributedString
        usedIconsLabel.text = viewModel.titleIcons
        iconsDescription.attributedText = viewModel.iconsDescriptionAttributedString
        
        developersTitle.text = viewModel.titleDevs
        developersTextView.text = viewModel.devContent
        
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
}

extension AboutViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        print("should interact with url: \(URL.absoluteString)")
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        } else {
            UIApplication.shared.openURL(URL)
        }
        return false
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
