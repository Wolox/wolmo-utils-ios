//
//  URLSessionExtension.swift
//  Utils
//
//  Created by Nahuel Gladstein on 6/26/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import Foundation

public extension URLSession {
    
    /**
     Returns a URLSession that uses .returnCacheDataElseLoad as cache policy.
     */
    public static func cacheSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        return URLSession(configuration: configuration)
    }
    
}
