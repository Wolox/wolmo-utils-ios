//
//  ImagePickerService.swift
//  Utils
//
//  Created by Nahuel Gladstein on 6/13/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import ReactiveSwift
import UIKit

public enum ImagePickerServiceError: Error {
    
    case sourceTypeNotAvailable
    
}

public protocol ImagePickerServiceType {
    /**
     Observe imageSignal to get the UIImage selected by the user
     */
    var imageSignal: Signal<UIImage, ImagePickerServiceError> { get }
    
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
    
    public let imageSignal: Signal<UIImage, ImagePickerServiceError>
    fileprivate let _imageObserver: Signal<UIImage, ImagePickerServiceError>.Observer
    
    fileprivate weak var _viewController: UIViewController?
    
    public init(viewController: UIViewController) {
        _viewController = viewController
        (imageSignal, _imageObserver) = Signal<UIImage, ImagePickerServiceError>.pipe()
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
    
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingImage image: UIImage,
                                      editingInfo: [String : AnyObject]?) {
        _viewController?.dismiss(animated: true) { [unowned self] in
            self._imageObserver.send(value: image)
        }
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
