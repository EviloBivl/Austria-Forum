//
//  PopoverViewController.swift
//  Cashback
//
//  Created by Paul Neuhold on 14.11.19.
//  Copyright © 2019 myWorld Solutions AG. All rights reserved.
//

import Foundation
import UIKit
import Lottie
import SwiftEntryKit

class PopoverViewController: UIViewController, BasePopoverConfiguration {
    
    var buttonAction: (() -> Void)?
    var buttonSkipAction: (() -> Void)?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var animationView: UIView!
    @IBOutlet weak var xButton: UIButton!
    @IBAction func didPressXButton(_ sender: Any) {
        SwiftEntryKit.dismiss()
    }
    
    @IBAction func didPressButton(_ sender: Any) {
        buttonAction?()
    }
    
    @IBAction func didPressSkip(_ sender: Any) {
        buttonSkipAction?()
    }
    
    var viewModel: PopoverBaseModel?
    
    class func create(viewModel: PopoverBaseModel) -> PopoverViewController {
        let controller = StoryboardScene.PopoverViewController.popoverViewController.instantiate()
        controller.viewModel = viewModel
        controller.buttonAction = viewModel.buttonAction
        controller.buttonSkipAction = viewModel.buttonSkipAction
        return controller
//        return PopoverViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        guard let viewModel = viewModel else { return }
        
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        descriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        skipButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        
        let primaryText = UIColor.black
        titleLabel.textColor = primaryText
        descriptionLabel.textColor = primaryText
        skipButton.setTitleColor(primaryText, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.systemBlue
        
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.horizontalCompressionResistancePriority = .required
        
        xButton.setTitle("x", for: .normal)
        xButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .heavy)
        xButton.setTitleColor(.lightGray, for: .normal)
        
        titleLabel.text = viewModel.title
        descriptionLabel.text = viewModel.description
        skipButton.setTitle(viewModel.buttonSkipText, for: .normal)
        button.setTitle(viewModel.buttonText, for: .normal)
        
        setupAnimation(name: viewModel.animationFile, onView: animationView, animationConfig: viewModel.animationConfig)
    }
}
