//
//  ChainedAnimation.swift
//  AnimationTest
//
//  Created by Argentino Ducret on 05/03/2018.
//  Copyright © 2018 wolox. All rights reserved.
//

import Foundation
import UIKit

class ChainedAnimation {
    let view: UIView
    let loop: Bool
    let completion: () -> ()
    
    var simpleAnimations: [Any] = []
    
    private var currentAnimation = 0
    
    init(view: UIView, loop: Bool = false, completion: @escaping () -> () = { }) {
        self.view = view
        self.loop = loop
        self.completion = completion
    }
    
    // MARK: - Add Methods
    
    func add(animation: MixedAnimation) -> ChainedAnimation {
        simpleAnimations.append(animation)
        return self
    }
    
    func add(animation: SimpleAnimation) -> ChainedAnimation {
        simpleAnimations.append(animation)
        return self
    }
    
    // MARK: - Start Methods
    
    func startAnimation() {
        if let mixedAnimation = simpleAnimations[currentAnimation] as? MixedAnimation {
            mixedAnimation.startAnimation(completion: animationCompletion)
        } else if let simpleAnimation = simpleAnimations[currentAnimation] as? SimpleAnimation {
            simpleAnimation.startAnimation(completion: animationCompletion)
        }
    }
    
}

// MARK: - Private Methods
fileprivate extension ChainedAnimation {
    
    func animationCompletion(completed: Bool) {
        currentAnimation += 1
        if currentAnimation >= simpleAnimations.count {
            currentAnimation = 0;
            completion()
            if !loop {
                return
            }
        }
        
        if let mixedAnimation = simpleAnimations[currentAnimation] as? MixedAnimation {
            mixedAnimation.startAnimation(completion: animationCompletion)
        } else if let simpleAnimation = simpleAnimations[currentAnimation] as? SimpleAnimation {
            simpleAnimation.startAnimation(completion: animationCompletion)
        }
    }
    
}
