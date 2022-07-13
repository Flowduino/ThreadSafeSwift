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
 - Version: 1.0
 */
@propertyWrapper
public struct ThreadSafeSemaphore<T> {
    public var lock = DispatchSemaphore(value: 1)
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
    
    public init(wrappedValue: T) {
        lock.wait()
        value = wrappedValue
        lock.signal()
    }
}
