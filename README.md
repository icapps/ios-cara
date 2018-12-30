![](./Images/CaraShield.jpg)

[![CI Status](http://img.shields.io/travis/icapps/ios-cara.svg?style=flat)](https://travis-ci.org/icapps/ios-cara)
[![Language Swift 4.0](https://img.shields.io/badge/Language-Swift%204.2-orange.svg?style=flat)](https://swift.org)

> Cara is the webservice layer that is (or should be) most commonly used throughout our apps.

## TOC

- [Installation](#installation)
- [Features](#features)
    - [Configuration](#configuration)
    - [Trigger a Request](#trigger-a-request)
    - [Serialization](#serialization)
        - [Custom Serializer](#custom-serializer)
        - [Codable Serializer](#codable-serializer)
    - [Public Key Pinning](#public-key-pinning)
- [Contribute](#contribute)
  - [How to contribute?](#how-to-contribute-)
  - [Contributors](#contributors)
- [License](#license)

## Installation 💾

Cara is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your `Podfile`:

```ruby
pod 'Cara', git: 'https://github.com/icapps/ios-cara.git', commit: '...'
```

_Pass the correct commit reference to make sure your code doesn't break in future updates._

## Features

### Configuration

In order to use the service layer you have to configure it. This can be done by implementing the `Configuration` protocol and passing it to the `Service` init function.

```swift
let configuration: Configuration = SomeConfiguration()
let service = Service(configuration: configuration)
```

Once this is done you are good to go. For more information on what configuration options are available, take a look at the documentation inside the `Configuration.swift` file.

### Trigger a Request

In order to trigger a request you have to do 2 things:
- Create a request that conforms to `Request`.
    
    _The request configuration will be done in this instance. For more information on what options are available, take a look at the documentation inside the `Request.swift` file._

- Create a serializer  that conforms to `Serializer`.

    _The serialization of the response will be done here. You have to implement the `serialize(data:error:response:)` function and this will be called when the response completes._

Once both instances are created and you `Service` is configured, you can execute the request.

```swift
let request: Request = SomeRequest()
let serializer: Serializer = JSONSerializer()
service.execute(request, with: serializer) { response in
    ...
}
```

The `response` returned by the completion block is the same as result of the serializer's `serialize(data:error:response:)` function.

### Serialization

With every request execution you have to pass a serializer. In most cases you will be able to use our `CodableSerializer`, but when you want to define a custom way of serializing your data, there is room for that too.

#### Custom Serializer

Create a custom class that conforms to `Serializer`. Here is a small example of how to do this.

```swift
struct CustomSerializer: Serializer {
    enum Response {
        case .success
        case .failure(Error)
    }

    func serialize(data: Data?, error: Error?, response: URLResponse?) -> Response {
        // data: data returned from the service request
        // error: error returned from the service request
        // response: the service request response

        if let error = error {
            return .failure(error)
        } else {
            return .success
        }
    }
}
```

#### Codable Serializer

We aleady supplied our **Cara** framework with one serializer: the `CodableSerializer`.

This serializer can parse the json data returned from the service to your codable models. Here is an example of a simple `Codable` model:

```swift
class User: Codable {
    let name: String
}
```

Let's now see how we can serialize the result of a request to a single `User` model:

```swift
let request = SomeRequest()
let serializer = CodableSerializer<User>()
service.execute(request, with: serializer) { response in
    switch response {
    case .success(let model):
        // The `model` instance is the parsed user model.
    case .failure(let error):
        // The `error` instance is the error returned from the service request.
    }
    ...
}
```

But what if multiple models are returned? Easy:

```swift
let request = SomeRequest()
let serializer = CodableSerializer<[User]>()
service.execute(request, with: serializer) { response in
    switch response {
    case .success(let models):
        // The `models` array contains the parsed `User` models.
    case .failure(let error):
        // The `error` instance is the error returned from the service request.
    }
    ...
}
```

When required you can pass a custom `JSONDecoder` through the `init`.

### Public Key Pinning

You can also make sure that some URL's are pinned for security reasons. It's fairly simple on how you can do this. Just add the correct host with it's SHA256 encryped public key to the `publicKeys` property of the `Configuration`.

```swift
class SomeConfiguration: Configuration {
    ...

    var publicKeys: PublicKeys? {
        return [
            "apple.com": "9GzkflclMUOxhMgy32AWL/OGkMZF/5NIjvL8M/4rb3k=",
            "google.com": "l2Z/zhy2hByKIqvgRkpKRm6M234/2HAEwiPXx5T8YYI="
        ]
    }
}
```

> There is a quick way to get the correct public key for a certain domain. Go to [SSL Server Test](https://www.ssllabs.com/ssltest/) by SSL Labs in order to perform an analysis of the SSL configuration of any web server. In the inputfield you enter the domain in order to get the process started. On the next page click the first IP address that appears, and on the page after, you'll notice the `Pin SHA256` field. The value is the public key string we need.

## Contribute

### How to contribute ❓

1. Add a Github issue describing the missing functionality or bug.
2. Implement the changes according to the `Swiftlint` coding guidelines.
3. Make sure your changes don't break the current version. (`deprecate` is needed)
4. Fully test the added changes.
5. Send a pull-request.

### Contributors 🤙

- Jelle Vandebeeck, [@fousa](https://github.com/fousa)

## License

Cara is available under the MIT license. See the LICENSE file for more info.
