//
// ThreadSafeSemaphore.swift
// Copyright (c) 2022, Flowduino
// Authored by Simon J. Stuart on 8th July 2022
//
// Subject to terms, restrictions, and liability waiver of the MIT License
//
import Foundation

/**
  Enforces a `DispatchSemaphore` Lock against the given Value Type to ensure single-threaded access.
 - Author: Simon J. Stuart
 - Version: 1.2.0
 */
@propertyWrapper
public struct ThreadSafeSemaphore<T> {
    
    /**
    Defines whether or not the Lock should be initialized in a Locked or Unlocked state.
     */
    public enum LockState {
        case unlocked
        case locked
    }
    
    public var lock: DispatchSemaphore
    private var value: T
    
    public var wrappedValue: T {
        get {
            lock.wait()
            let result = value
            lock.signal()
            return result
        }
        set {
            lock.wait()
            value = newValue
            lock.signal()
        }
    }
    
    /**
     Invokes your Closure within the confines of the `DispatchSemaphore` Lock (ensuring Mutually-Exclusive Access to your Value for the duration of execution)
     - Parameters:
        - code: The code you want to execute while the Lock is engaged.
     */
    mutating public func withLock(_ code: @escaping (_ value: inout T) -> ()) {
        lock.wait()
        code(&value)
        lock.signal()
    }
    
    /**
     Attempts to engage the `DispatchSemaphore` and, if successful, will invoke the Closure you provide to the `onLock` Closure. Otherwise, invokes the code you provide to the `onCannotLock` Closure.
     - Parameters:
        - onLock: The code to execute if the `DispatchSemaphore` can be acquired for mutually-exclusive access.
        - onCannotLock: The code to execute if the `DispatchSemaphore` is currently locked by another Thread.
     */
    mutating public func withTryLock(_ onLock: @escaping (_ value: inout T) -> (), _ onCannotLock: @escaping ()->()) {
        if lock.wait(timeout: DispatchTime.now()) == .success { // If we are able to acquire the lock...
            onLock(&value) // Invoke the closure within the lock
            lock.signal() // Release the Lock
        }
        else { // If we can't acquire the lock...
            onCannotLock() // Invoke the closure given to execute when the Lock is unavailable
        }
    }
    
    /**
     Initializes a ThreadSafeSempahore-decorated Variable
     - Parameters:
        - wrappedValue: The Initial Value of the Variable
        - lockState: Whether the Lock should be Locked or Unlocked initially
     */
    public init(wrappedValue: T, lockState: LockState = .unlocked) {
        lock = DispatchSemaphore(value: lockState == .unlocked ? 1 : 0)
        value = wrappedValue
    }
}
