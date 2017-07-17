//
//  ImageFetcher.swift
//  Utils
//
//  Created by Nahuel Gladstein on 6/13/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import UIKit
import ReactiveSwift

public protocol ImageFetcherType {
    
    /**
     Fetches an image asynchronously from a URL, returning a value or an error in the SignalProducer when done.
     - parameter imageURL: the url of the image to fetch.
     - parameter session: the URLSession to use to make the request. Default: URLSession.shared.
     You can use URLSession.cacheSession to use .returnCacheDataElseLoad cache policy.
     */
    func fetchImage(_ imageURL: URL, with session: URLSession) -> SignalProducer<UIImage, ImageFetcherError>
    
}

public enum ImageFetcherError: Error {
    case invalidImageFormat
    case fetchError(Error)
}

public class ImageFetcher: ImageFetcherType {
    
    public func fetchImage(_ imageURL: URL, with session: URLSession = URLSession.shared) -> SignalProducer<UIImage, ImageFetcherError> {
        return session
            .reactive.data(with: URLRequest(url: imageURL))
            .flatMapError { SignalProducer(error: .fetchError($0)) }
            .flatMap(.concat) { data, response -> SignalProducer<UIImage, ImageFetcherError> in                
                if let image = UIImage(data: data) {
                    return SignalProducer(value: image)
                } else {
                    return SignalProducer(error: .invalidImageFormat)
                }
        }
    }
    
}
