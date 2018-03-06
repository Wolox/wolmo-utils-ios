//
//  MixedAnimation.swift
//  AnimationTest
//
//  Created by Argentino Ducret on 05/03/2018.
//  Copyright © 2018 wolox. All rights reserved.
//

import Foundation
import UIKit

class MixedAnimation {
    let duration: TimeInterval
    let view: UIView
    
    var transformations: [CGAffineTransform] = []
    var actions: [() -> ()] = []
    
    init(view: UIView, duration: TimeInterval) {
        self.duration = duration
        self.view = view
    }
    
    // MARK: - Transforms
    
    func transformIdentity() -> MixedAnimation {
        transformations.append(CGAffineTransform.identity)
        return self
    }
    
    func transform(translationX: CGFloat, translationY: CGFloat) -> MixedAnimation {
        transformations.append(CGAffineTransform(translationX: translationX, y: translationY))
        return self
    }
    
    func transform(rotationAngle: CGFloat) -> MixedAnimation {
        let angleInRadians = (rotationAngle * CGFloat.pi) / 180.0;
        transformations.append(CGAffineTransform(rotationAngle: angleInRadians))
        return self
    }
    
    func transform(scaleX: CGFloat, scaleY: CGFloat) -> MixedAnimation {
        transformations.append(CGAffineTransform(scaleX: scaleX, y: scaleY))
        return self
    }
    
    // MARK: - Actions
    
    func action(positionX: CGFloat, positionY: CGFloat) -> MixedAnimation {
        actions.append {
            self.view.center = CGPoint(x: positionX, y: positionY)
        }
        
        return self
    }
    
    func action(translateX: CGFloat, translateY: CGFloat) -> MixedAnimation {
        actions.append {
            self.view.center = CGPoint(x: self.view.center.x + translateX, y: self.view.center.y + translateY)
        }
        return self
    }
    
    func action(scaleX: CGFloat, scaleY: CGFloat) -> MixedAnimation {
        actions.append {
            let center = self.view.center
            self.view.frame = CGRect(x: self.view.frame.origin.x,
                                     y: self.view.frame.origin.y,
                                     width: self.view.frame.width * scaleX,
                                     height: self.view.frame.height * scaleY)
            self.view.center = center
        }
        return self
    }
    
    func action(alpha: CGFloat) -> MixedAnimation {
        actions.append({
            self.view.alpha = alpha
        })
        return self
    }
    
    func action(moveTo position: UIView.Position) -> MixedAnimation {
        actions.append({
            switch position {
            case .back:
                self.view.superview?.sendSubview(toBack: self.view)
            case .front:
                self.view.superview?.bringSubview(toFront: self.view)
            }
        })
        return self
    }
    
    func startAnimation(completion: ((Bool) -> Void)? = { _ in }) {
        UIView.animate(withDuration: duration, animations: {
            if self.transformations.count > 0 {
                self.view.transform = self.transformations[0]
                for i in 1..<self.transformations.count {
                    self.view.transform = self.view.transform.concatenating(self.transformations[i])
                }
            }
            self.actions.forEach { $0() }
        }, completion: completion)
    }
    
}
