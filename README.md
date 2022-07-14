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
            .upToNextMajor(from: "1.1.0")
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

### `@ThreadSafeSemaphore` - Property Wrapper
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

### `ThreadSafeSemaphore.withLock` - Execute a Closure while retaining the Lock
Often, it is necessary to perform more than one operation on a Value... and when you need to do this, you'll want to ensure that you retain the `DispatchSemaphore` lock against the value for the duration of these operations.
To facilitate this, we can use the `withLock` method against any `ThreadSafeSemaphore` decorated variable:
```swift
@ThreadSafeSemaphore var myInts: [Int] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9] 
```
Here we have a `ThreadSafeSemaphore` decorated Array of Integers.

If we want to perform any number of operations against any number of values within this Array, we can now do so in a thread-safe manner using `withLock`:
```swift
func incrementEachValueByOne() {
    _myInts.withLock { value in
        for (index, val) in value.enumerated() {
            value[index] = val + 1
        }
    }
}
```
Please pay attention to the preceeding underscore `_` before `myInts` when invoking the `withLock` method. This is important, as the underscore instructs Swift to reference the Property Decorator rather than its `wrappedValue`.

**IMPORTANT NOTE:** - You must *not* reference the variable itself (in the above example, `myInts`) within the scope of the Closure. If you do, the Thread will lock at that command and proceed no further. All mutations to the value must be performed against `value` as defined within the scope of the Closure itself (as shown above).

So, as you can see, we can now encapsulate *complex types* with the `@ThreadSafeSemaphore` decorator and operate against all of its members within the safety of the `DispatchSemaphore` lock.

### `ThreadSafeSemaphore.withTryLock` - Execute a Closure while retaining the Lock IF we can acquire it, otherwise execute a failure Closure
As with `ThreadSafeSemaphore.withLock` (explained above), we may need to perform one or more operations within the context of the `DispatchSemaphore` only *if* it is possible to obtain the `DispatchSemaphore` Lock at that time. Where it is not possible to acquire the `DispatchSemaphore` lock at that moment, we may want to execute another piece of conditional code.

We can do that easily:
```swift
@ThreadSafeSemaphore var myInts: [Int] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
```
Again, we declare our `@ThreadSafeSemaphore` decorated Variable.

Now let's see how we would use `withTryLock` against `myInts`:
```swift
func incrementEachValueByOne() {
    _myInts.withTryLock { value in
        // If we got the Lock
        for (index, val) in value.enumerated() {
            value[index] = val + 1
        }
    } _: {
        // If we couldn't get the Lock
        print("We wanted to acquire the Lock, but couldn't... so we can do something else instead!")
    }
}
```
**IMPORTANT NOTE:** - You must *not* reference the variable itself (in the above example, `myInts`) within the scope of the *either* Closure. If you do, the Thread will lock at that command and proceed no further. All mutations to the value must be performed against `value` as defined within the scope of the Closure itself (as shown above).

These *Conditional Closures* are extremely useful where your code needs to progress down a different execution path depending on whether it can or cannot acquire the `DispatchSemaphore` lock at the point of execution.

**TIP:** - I use this very approach to implement "Revolving Door Locks" for Collections. A feature that will be added to this library very soon!

## License

`ThreadSafeSwift` is available under the MIT license. See the [LICENSE file](./LICENSE) for more info.
