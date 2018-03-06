//
//  UIViewExtension.swift
//  AnimationTest
//
//  Created by Argentino Ducret on 24/01/2018.
//  Copyright © 2018 wolox. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    enum Position {
        case back
        case front
    }
    
    func simpleAnimation() -> SimpleAnimation {
        return SimpleAnimation(view: self)
    }
    
    func mixedAnimation(withDuration duration: TimeInterval) -> MixedAnimation {
        return MixedAnimation(view: self, duration: duration)
    }
    
    func chainedAnimation(loop: Bool = false, completion: @escaping () -> () = { }) -> ChainedAnimation {
        return ChainedAnimation(view: self, loop: loop, completion: completion)
    }
    
}
