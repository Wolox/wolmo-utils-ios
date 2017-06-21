//
//  ImagePickerService.swift
//  Utils
//
//  Created by Nahuel Gladstein on 6/13/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import ReactiveSwift
import UIKit
import AVFoundation
import Photos
import Result

public enum ImagePickerServiceError: Error {
    
    case sourceTypeNotAvailable
    
}

public protocol ImagePickerServiceType {
    /**
     Observe imageSignal to get the UIImage selected by the user
     */
    var imageSignal: Signal<UIImage, ImagePickerServiceError> { get }
    
    /**
     Presents the camera to the user so it can take a picture. If the user didn't give permission to the app to use the camera
        a prompt asking it will be shown.
     - parameter permissionNotGranted: Block called when the user denies permission. If the user gives permission the camera will be shown.
     */
    func presentCameraTypeImagePickerController(_ permissionNotGranted: @escaping (Void) -> Void)
    
    /**
     Presents the media library to the user so it can select a picture. If the user didn't give permission to the app to use the library
        a prompt asking it will be shown.
     - parameter permissionNotGranted: Block called when the user denies permission. If the user gives permission the library will be shown.
     */
    func presentGalleryTypeImagePickerController(_ permissionNotGranted: @escaping (Void) -> Void)
    
    /**
     Tells if the device has a camera.
     */
    var cameraIsAvailable: Bool { get }
}

@objc
public final class ImagePickerService: NSObject, ImagePickerServiceType {
    
    public let imageSignal: Signal<UIImage, ImagePickerServiceError>
    fileprivate let _imageObserver: Signal<UIImage, ImagePickerServiceError>.Observer
    
    fileprivate weak var _viewController: UIViewController?
    
    init(viewController: UIViewController) {
        _viewController = viewController
        (imageSignal, _imageObserver) = Signal<UIImage, ImagePickerServiceError>.pipe()
    }
    
    public func presentCameraTypeImagePickerController(_ permissionNotGranted: @escaping (Void) -> Void) {
        if cameraIsAvailable {
            hasCameraPermission().startWithValues { [unowned self] in
                $0 ? self.presentImagePickerController(.camera) : permissionNotGranted()
            }
        } else {
            _imageObserver.send(error: ImagePickerServiceError.sourceTypeNotAvailable)
        }
    }
    
    public func presentGalleryTypeImagePickerController(_ permissionNotGranted: @escaping (Void) -> Void) {
        hasPhotosPermission().startWithValues { [unowned self] in
            $0 ? self.presentImagePickerController(.photoLibrary) : permissionNotGranted()
        }
    }
    
    public var cameraIsAvailable: Bool {
        return UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    deinit {
        _imageObserver.sendCompleted()
    }
}

fileprivate extension ImagePickerService {
    
    fileprivate func hasCameraPermission() -> SignalProducer<Bool, NoError> {
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
    
    fileprivate func hasPhotosPermission() -> SignalProducer<Bool, NoError> {
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

extension ImagePickerService: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        _viewController?.dismiss(animated: true) { [unowned self] in
            self._imageObserver.send(value: image)
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        _viewController?.dismiss(animated: true, completion: nil)
    }
    
}

fileprivate extension ImagePickerService {
    
    fileprivate func presentImagePickerController(_ sourceType: UIImagePickerControllerSourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = sourceType
        
        _viewController?.present(imagePickerController, animated: true, completion: nil)
    }
    
}
