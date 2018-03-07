//
//  Animation.swift
//  AnimationTest
//
//  Created by Argentino Ducret on 05/03/2018.
//  Copyright © 2018 wolox. All rights reserved.
//

import Foundation
import UIKit

typealias Transform = CGAffineTransform
typealias Action = () -> ()

struct Animation {
    let transform: Transform?
    let action: Action?
    let duration: TimeInterval
    
    init(transform: Transform, duration: TimeInterval) {
        self.transform = transform
        self.duration = duration
        self.action = .none
    }
    
    init(action: @escaping Action, duration: TimeInterval) {
        self.action = action
        self.duration = duration
        self.transform = .none
    }
    
}
