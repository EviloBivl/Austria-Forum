//
//  BasePopoverViewController.swift
//  Cashback
//
//  Created by Paul Neuhold on 11.11.19.
//  Copyright © 2019 myWorld Solutions AG. All rights reserved.
//

import Foundation
import UIKit
import Lottie

protocol PopoverBaseModel {
    var title: String { get set }
    var animationFile: String { get set }
    var description: String { get set }
    var buttonText: String { get set }
    var buttonSkipText: String { get set }
    var buttonAction: (() -> Void)? { get set }
    var buttonSkipAction: (() -> Void)? { get set }
    var animationConfig: AnimationConfiguration { get set }
}

public enum PopoverType {
    case location
    case push
    
    var title: String {
        switch self {
        case .location:
            return "Finde Artikel in deiner Nähe"
        case .push:
            return "Bleib auf dem Laufenden"
        }
    }
    var animationFile: String {
        switch self {
        case .location:
            return "permission_location"
        case .push:
            return "permission_push"
        }
    }
    
    var animationLicense: String {
        switch self {
            case .location:
                return "@Victor Del Bono"
            case .push:
                return "@Allan Ribas"
        }
    }
    
    var description: String {
        switch self {
        case .location:
            return "Die Freigabe deines Standorts ermöglicht es Artikel anzuzeigen die sich in deiner Nähe befinden."
        case .push:
            return "Erhalte Mitteilungen wenn du dich in der Nähe eines spannenden Artikels befindest."
        }
    }
    var buttonText: String {
        switch self {
        case .location:
            return "Erlauben"
        case .push:
            return "Erlauben"
        }
    }
    var buttonSkipText: String {
        switch self {
        case .location:
            return "Nicht jetzt"
        case .push:
            return "Nicht jetzt"
        }
    }
    
    var heightMultiplier: CGFloat {
        switch self {
        case .location: return 2
        case .push: return 1
        }
    }
    
    var widthMultiplier: CGFloat {
        switch self {
        case .location: return 2
        case .push: return 1
        }
    }
    
    var animationSpeed: CGFloat {
        //1 is default
        switch self {
        case .location: return 0.5
        case .push: return 1.0
        }
    }
    
    var repeatCount: Float {
        //0 values are infinite counts
        switch self {
        case .location: return 3
        case .push: return 2
        }
    }
    
    var keyPaths: [(colorProvider: ColorValueProvider, forKeyPath: AnimationKeypath)] {
        switch self {
        case .push:
            var paths: [(colorProvider: ColorValueProvider, forKeyPath: AnimationKeypath)] = [(colorProvider: ColorValueProvider, forKeyPath: AnimationKeypath)]()
           
            let animatingBadgePath = AnimationKeypath(keypath: "Shape Layer 1.*.Fill 1.Color")
            
            let buttonTextColorProvider = ColorValueProvider(UIColor.systemBlue.lottieColorValue)
            
            paths.append((colorProvider: buttonTextColorProvider, forKeyPath: animatingBadgePath))
            
            return paths
        case .location:
            return  [(colorProvider: ColorValueProvider, forKeyPath: AnimationKeypath)]()
        }
    }
}

protocol BasePopoverConfiguration {
    var buttonAction: (() -> Void)? { get set }
    var buttonSkipAction: (() -> Void)? { get set }
    /// @name the name of the lottie json animation file
    /// @onView a container view in which the animation will be loaded. height and width will be equal to the container View
    func setupAnimation(name: String, onView: UIView, animationConfig: AnimationConfiguration)
}

extension BasePopoverConfiguration {
    func setupAnimation(name: String, onView: UIView, animationConfig: AnimationConfiguration){
        let animation = AnimationView(name: name)
        onView.addSubview(animation)
        
        animation.loopMode = animationConfig.lottieLoopMode
        animation.animationSpeed = animationConfig.animationSpeed

        
        animationConfig.keyPaths.forEach {
            animation.setValueProvider($0.colorProvider, keypath: $0.forKeyPath)
        }
        animation.contentMode = .scaleAspectFit
        animation.play()
        animation.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            animation.centerYAnchor.constraint(equalToSystemSpacingBelow: onView.centerYAnchor, multiplier: 1).isActive = true
            animation.centerXAnchor.constraint(equalToSystemSpacingAfter: onView.centerXAnchor, multiplier: 1).isActive = true
            animation.heightAnchor.constraint(equalTo: onView.heightAnchor, multiplier: animationConfig.heightMultiplier).isActive = true
            animation.widthAnchor.constraint(equalTo: onView.widthAnchor, multiplier: animationConfig.widthMultiplier).isActive = true
        } else {
            let centerY = NSLayoutConstraint(item: animation, attribute: .centerY, relatedBy: .equal, toItem: onView, attribute: .centerY, multiplier: 1, constant: 0)
            let centerX = NSLayoutConstraint(item: animation, attribute: .centerX, relatedBy: .equal, toItem: onView, attribute: .centerX, multiplier: 1, constant: 0)
            let height = NSLayoutConstraint(item: animation, attribute: .height, relatedBy: .equal, toItem: onView, attribute: .height, multiplier: animationConfig.heightMultiplier, constant: 0)
            let width = NSLayoutConstraint(item: animation, attribute: .width, relatedBy: .equal, toItem: onView, attribute: .width, multiplier: animationConfig.widthMultiplier, constant: 0)
            onView.addConstraints([centerY,centerX,height,width])
        }
    }
}


struct AnimationConfiguration {
    let animationSpeed: CGFloat
    let lottieLoopMode: LottieLoopMode
    let keyPaths: [(colorProvider: ColorValueProvider, forKeyPath: AnimationKeypath)]
    let heightMultiplier: CGFloat
    let widthMultiplier: CGFloat
}

struct PopoverModel: PopoverBaseModel {
    var title: String
    var animationFile: String
    var description: String
    var buttonText: String
    var buttonSkipText: String
    var buttonAction: (() -> Void)?
    var buttonSkipAction: (() -> Void)?
    var animationConfig: AnimationConfiguration
    
    init(type: PopoverType,
         buttonAction: (() -> Void)? = nil,
         buttonSkipAction: (() -> Void)? = nil) {
        self.title = type.title
        self.animationFile = type.animationFile
        self.description = type.description
        self.buttonText = type.buttonText
        self.buttonSkipText = type.buttonSkipText
        self.buttonAction = buttonAction
        self.buttonSkipAction = buttonSkipAction
        self.animationConfig = AnimationConfiguration(animationSpeed: type.animationSpeed,
                                                      lottieLoopMode: type.repeatCount == 0 ? .loop : .repeat(type.repeatCount),
                                                      keyPaths: type.keyPaths,
                                                      heightMultiplier: type.heightMultiplier,
                                                      widthMultiplier: type.widthMultiplier)
    }
}
