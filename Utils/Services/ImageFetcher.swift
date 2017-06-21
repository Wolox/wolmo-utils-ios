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
    
    func fetchImage(_ imageURL: URL) -> SignalProducer<UIImage, ImageFetcherError>
    
}

public enum ImageFetcherError: Error {
    case invalidImageFormat
    case fetchError(Error)
}

public class ImageFetcher: ImageFetcherType {
    
    /**
     Fetches an image asynchronously from a URL, returning a value or an error in the SignalProducer when done.
     - parameter imageURL: the url of the image to fetch.
     */
    public func fetchImage(_ imageURL: URL) -> SignalProducer<UIImage, ImageFetcherError> {
        return URLSession.shared
            .reactive.data(with: URLRequest(url: imageURL))
            .flatMapError { SignalProducer(error: .fetchError($0)) }
            .flatMap(.concat) { data, _ -> SignalProducer<UIImage, ImageFetcherError> in
                if let image = UIImage(data: data) {
                    return SignalProducer(value: image)
                } else {
                    return SignalProducer(error: .invalidImageFormat)
                }
        }
    }
    
}
