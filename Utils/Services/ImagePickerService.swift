//
//  ImagePickerService.swift
//  Utils
//
//  Created by Nahuel Gladstein on 6/13/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import ReactiveSwift
import UIKit
import MobileCoreServices

public enum ImagePickerServiceError: Error {
    
    case sourceTypeNotAvailable
    
}

public enum ImagePickerMedia {
    case image(UIImage)
    case video(URL)
    case other([String : Any])
}

public protocol ImagePickerServiceType {
    /**
     Observe imageSignal to get the ImagePickerMedia selected by the user
     */
    var imageSignal: Signal<ImagePickerMedia, ImagePickerServiceError> { get }
    
    /**
     Presents the picker to the user so it can take or select a picture. If the user didn't give permission to the app to use the source type selected
        a prompt asking it will be shown.
     - parameter source: Source type for the picker to show. Can be .camera or .photoLibrary.
     - parameter onPermissionNotGranted: Block called if the user denies permission. If the user gives permission the camera will be shown.
     */
    func presentImagePickerController(for source: UIImagePickerControllerSourceType, _ onPermissionNotGranted: @escaping () -> Void)
    
    /**
     Tells if the device has a camera.
     */
    var cameraIsAvailable: Bool { get }
}

@objc
public final class ImagePickerService: NSObject, ImagePickerServiceType {
    
    public let imageSignal: Signal<ImagePickerMedia, ImagePickerServiceError>
    fileprivate let _imageObserver: Signal<ImagePickerMedia, ImagePickerServiceError>.Observer
    
    fileprivate weak var _viewController: UIViewController?
    
    public init(viewController: UIViewController) {
        _viewController = viewController
        (imageSignal, _imageObserver) = Signal<ImagePickerMedia, ImagePickerServiceError>.pipe()
    }
    
    public func presentImagePickerController(for source: UIImagePickerControllerSourceType, _ onPermissionNotGranted: @escaping () -> Void) {
        source.isPermitted().startWithResult { [unowned self] in
            switch $0 {
            case .success(let permitted):
                if permitted { self.presentImagePickerController(source) }
                else { onPermissionNotGranted() }
            case .failure(let error): self._imageObserver.send(error: error)
            }
        }
    }
    
    public var cameraIsAvailable: Bool {
        return UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    deinit {
        _imageObserver.sendCompleted()
    }
}

extension ImagePickerService: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        _viewController?.dismiss(animated: true) { [unowned self] in
            let type = info[UIImagePickerControllerMediaType] as! String
            let ImageType = (kUTTypeImage as NSString) as String
            let VideoType = (kUTTypeMovie as NSString) as String

            switch type {
            case ImageType: self._imageObserver.send(value: .image(self.getImage(from: info)!))
            case VideoType: self._imageObserver.send(value: .video(info[UIImagePickerControllerMediaURL] as! URL))
            default:
                if let image = self.getImage(from: info) {
                    self._imageObserver.send(value: .image(image))
                } else {
                    self._imageObserver.send(value: .other(info))
                }
            }
        }
    }

    private func getImage(from info: [String : Any]) -> UIImage? {
        if let image = (info[UIImagePickerControllerEditedImage] as? UIImage) {
            return image
        }
        return info[UIImagePickerControllerOriginalImage] as? UIImage
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        _viewController?.dismiss(animated: true, completion: .none)
    }
    
}

fileprivate extension ImagePickerService {
    
    fileprivate func presentImagePickerController(_ sourceType: UIImagePickerControllerSourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = sourceType
        
        _viewController?.present(imagePickerController, animated: true, completion: .none)
    }
    
}
