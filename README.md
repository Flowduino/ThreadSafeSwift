# ThreadSafeSwift

<p>
    <img src="https://img.shields.io/badge/Swift-5.1%2B-yellowgreen.svg?style=flat" />
    <img src="https://img.shields.io/badge/License-MIT-blue.svg" />
    <a href="https://github.com/apple/swift-package-manager">
      <img src="https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat" />
    </a>
</p>

Collection of Property Wrappers and other Types explicitly designed to provide quick, simple, and efficient Thread-Safety in your Swift projects.

## Installation
### Xcode Projects
Select `File` -> `Swift Packages` -> `Add Package Dependency` and enter `https://github.com/Flowduino/ThreadSafeSwift.git`

### Swift Package Manager Projects
You can use `ThreadSafeSwift` as a Package Dependency in your own Packages' `Package.swift` file:
```swift
let package = Package(
    //...
    dependencies: [
        .package(
            url: "https://github.com/Flowduino/ThreadSafeSwift.git",
            .upToNextMajor(from: "1.0.0")
        ),
    ],
    //...
)
```

From there, refer to `ThreadSafeSwift` as a "target dependency" in any of _your_ package's targets that need it.

```swift
targets: [
    .target(
        name: "YourLibrary",
        dependencies: [
          "ThreadSafeSwift",
        ],
        //...
    ),
    //...
]
```
You can then do `import ThreadSafeSwift` in any code that requires it.

## Usage

Here are some quick and easy usage examples for the features provided by `ThreadSafeSwift`:

### ThreadSafeSemaphore - Property Wrapper
You can use the `ThreadSafeSemaphore` Property Wrapper to encapsulate any Value Type behind a Thread-Safe `DispatchSemaphore`.
This is extremely easy for most types:
```swift
@ThreadSafeSemaphore var myInt: Int
```

Further, you can access the underlying `DispatchSemaphore` directly, which is useful where you need to acquire the Lock for multiple operations that must performed *Atomically*:
```swift
@ThreadSafeSemaphore var myInts: [Int]

//...

func incrementEveryIntegerByOne() {
    _myInts.lock.wait()
    for (index,val) in myInts.enumerated() {
        myInts[index] = val + 1
    }
    _myInts.lock.signal()
}
```
Of course, for Arrays, you really should try to minimize the number of get/set operations required, and the duration throughout which the `DispatchSemaphore` is locked:
```swift
@ThreadSafeSemaphore var myInts: [Int]

//...

func incrementEveryIntegerByOne() {
    var values = myInts // This would marshal the `DispatchSemaphore` and return a copy of the Array, then release the `DispatchSemaphore`
    for (index,val) in values.enumerated() {
        myInts[index] = val + 1
    }
    myInts = values // This would marshal the `DispatchSempahore` and replace the entire Array with our modified one, then release the `DispatchSemaphore`
}
```
## License

`ThreadSafeSwift` is available under the MIT license. See the [LICENSE file](./LICENSE) for more info.
