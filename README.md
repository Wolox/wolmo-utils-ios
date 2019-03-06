## WolMo - Utils iOS

WolMo - Utils iOS is a framework which provides specific utilities for iOS used at [Wolox](http://www.wolox.com.ar/).

## Table of Contents

  * [Installation](#installation)
    * [Carthage](#carthage)
  * [Usage](#usage)
    * [ImageFetcher](#image-fetcher)
    * [ImagePickerService](#image-picker-service)
    * [UserManager](#user-manager)
  * [Contributing](#contributing)
  * [About](#about)
  * [License](#license)

## Installation

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with Homebrew using the following command:

```
brew update
brew install carthage
```
To download wolmo-utils-iOS, add this to your Cartfile:
```
github "Wolox/wolmo-utils-ios" "master"
```

## Usage

Right now the framework has 2 utilities: [ImageFetcher](#ImageFetcher) and [ImagePickerService](#ImagePickerService).

### Image Fetcher

[ImageFetcher](https://github.com/Wolox/wolmo-utils-ios/blob/master/Utils/Services/ImageFetcher.swift) fetches an image from an URL and returns a `SignalProducer` with the resulting `UIImage` or an `ImageFetcherError` if there is one. Using this Service is pretty straightforward, it only has one method and it's parameters are self explanatory.  
`ImageFetcher` implements the `ImageFetcherType` protocol. You should use this protocol as the type in your code so if you you need to provide a mock implementation you just implement it in your mock object.

### Image Picker Service

[ImagePickerService](https://github.com/Wolox/wolmo-utils-ios/blob/master/Utils/Services/ImagePickerService.swift) handles the process to let the user pick an image from the library or use the camera to take one. If there are permissions that need to be asked, it will ask for them.  
In case the user grants permission, it will continue to the library or camera depending on what the user selected.  
If the user denies permission, `ImagePickerService` provides a block that you can use to specify how to proceed.  
The resulting image will be returned in the public signal `imageSignal`.  
Also you can check if the device has an available camera checking the boolean `cameraAvailable`.  
As with the other utils, a protocol is provided and implemented by this class (`ImagePickerServiceType`) so you can use it as your type and provide a mock implementation if needed.

### User Manager

The framework provides a [UserManager](Utils/UserManager/UserManager.swift) intended to manage the current user. It also stores the user session exposing a way to update it whenever the user logs in, logs out, updates and expires. These transitions are expected to be handled outside the framework, but always letting UserManager know about them.

When a user is logged in or signed up, `login:` must be called providing the fetched user. This will make `UserManager` know a valid session is being used.

The same way, when the user is logged out, `logout` must be called. This will make `UserManager` remove the stored session token.

The function `update:` receiving a user can be useful to make `UsenManager` store an updated `User`.

### Storing a User

`UserManager` can provide the current user reading the property `currentUser`. This property is set when `bootstrapSession` is called, which must be called only once. 

This function fetches the current user if an instance of [CurrentUserFetcherType](Utils/UserManager/CurrentUserFetcher.swift) is provided. Since the user is not persisted in the device, and only stored in memory the user needs to be fetched every time the application is launched.

## Contributing
1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Run tests.
5. Push your branch (`git push origin my-new-feature`)
6. Create a new Pull Request

## About

This project is maintained by [Nahuel Gladstein](https://github.com/nahuelwolox) and it is written by [Wolox](http://www.wolox.com.ar).

![Wolox](https://raw.githubusercontent.com/Wolox/press-kit/master/logos/logo_banner.png)

## License
**WolMo - Utils iOS** is available under the MIT [license](LICENSE.txt).

    Copyright (c) 2016 Francisco Depascuali <francisco.depascuali@wolox.com.ar>

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
