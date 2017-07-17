//
//  UIImagePickerControllerSourceTypeExtension.swift
//  Utils
//
//  Created by Nahuel Gladstein on 6/26/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import Foundation
import ReactiveSwift
import AVFoundation
import Photos
import Result

internal extension UIImagePickerControllerSourceType {
    
    internal func isPermitted() -> SignalProducer<Bool, ImagePickerServiceError> {
        switch self {
        case .camera:
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return SignalProducer(error: .sourceTypeNotAvailable) }
            return hasCameraPermission()
        case .photoLibrary, .savedPhotosAlbum: return hasPhotosPermission()
        }
    }
    
}

fileprivate extension UIImagePickerControllerSourceType {

    fileprivate func hasCameraPermission() -> SignalProducer<Bool, ImagePickerServiceError> {
        return SignalProducer { observable, _ in
            switch AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) {
            case .notDetermined:
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) {
                    observable.send(value: $0)
                }
            case .authorized: observable.send(value: true)
            case .denied, .restricted: observable.send(value: false)
            }
        }
    }
    
    fileprivate func hasPhotosPermission() -> SignalProducer<Bool, ImagePickerServiceError> {
        return SignalProducer { observable, _ in
            switch PHPhotoLibrary.authorizationStatus() {
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization {
                    observable.send(value: $0 == .authorized)
                }
            case .authorized: observable.send(value: true)
            case .denied, .restricted: observable.send(value: false)
            }
        }
    }
    
}
