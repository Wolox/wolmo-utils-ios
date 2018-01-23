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

/**
 Enum to represent all media types an UIImagePickerController can get.
 For full details, please visit: https://developer.apple.com/documentation/mobilecoreservices/uttype
 */
public enum ImagePickerMediaType {
    case image
    case video
    case other(CFString)
}

/**
 Enum to represent all possible medias an UIImagePickerController can get.
 Some types are particularly identified, for others you can use its dictionary to get information.
 For more information refer to `func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])`.
 */
public enum ImagePickerMedia {
    case image(UIImage)
    case video(URL)
    case other([String : Any])
}

/**
 Service that provides a way to get media.
 */
public protocol ImagePickerServiceType {
    /**
     Observe imageSignal to get the ImagePickerMedia selected by the user
     */
    var imageSignal: Signal<ImagePickerMedia, ImagePickerServiceError> { get }
    
    /**
     Presents the picker to the user so it can take or select a picture or other media.
     If the user didn't give permission to the app to use the source type selected a prompt asking it will be shown.
     - parameter source: Source type for the picker to show. Can be .camera or .photoLibrary.
     - parameter onPermissionNotGranted: Block called if the user denies permission. If the user gives permission the camera will be shown.
     */
    func presentImagePickerController(from source: UIImagePickerControllerSourceType,
                                      for media: [ImagePickerMediaType],
                                      _ onPermissionNotGranted: @escaping () -> Void)
    
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
    
    public func presentImagePickerController(from source: UIImagePickerControllerSourceType,
                                             for media: [ImagePickerMediaType],
                                             _ onPermissionNotGranted: @escaping () -> Void) {
        source.isPermitted().startWithResult { [unowned self] in
            switch $0 {
            case .success(let permitted):
                if permitted { self.presentImagePickerController(source: source, media: media) }
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
            let type = info[UIImagePickerControllerMediaType] as! CFString

            if UTTypeConformsTo(type, ImagePickerMediaType.image.mediaTypeString) {
                self._imageObserver.send(value: .image(self.getImage(from: info)!))
            } else if UTTypeConformsTo(type, ImagePickerMediaType.video.mediaTypeString) {
                self._imageObserver.send(value: .video(info[UIImagePickerControllerMediaURL] as! URL))
            } else {
                self._imageObserver.send(value: .other(info))
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
    
    fileprivate func presentImagePickerController(source sourceType: UIImagePickerControllerSourceType, media mediaTypes: [ImagePickerMediaType]) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = sourceType
        imagePickerController.mediaTypes = mediaTypes.map { ($0.mediaTypeString as NSString) as String }
        
        _viewController?.present(imagePickerController, animated: true, completion: .none)
    }
    
}

fileprivate extension ImagePickerMediaType {

    fileprivate var mediaTypeString: CFString {
        switch self {
        case .image: return kUTTypeImage
        case .video: return kUTTypeAudiovisualContent
        case .other(let typeString): return typeString
        }
    }

}
