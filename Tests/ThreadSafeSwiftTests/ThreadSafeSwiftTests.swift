import XCTest
@testable import ThreadSafeSwift

final class ThreadSafeSwiftTests: XCTestCase {
    func testWithLock() throws {
        @ThreadSafeSemaphore var myInts: [Int] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        
        // Increment every Value by 1
        _myInts.withLock { value in
            for (index, val) in value.enumerated() {
                value[index] = val + 1
            }
        }
        // Assert that each Value has been incremented by 1
        _myInts.withLock { value in
            for (index, val) in value.enumerated() {
                XCTAssertEqual(index + 1, val, "Value \(index) should be \(index + 1) but is \(val)")
            }
        }
    }
    
    func testTryWithLock() throws {
        @ThreadSafeSemaphore var myInts: [Int] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        
        _myInts.withTryLock { value in
            // If we got the Lock
            for (index, val) in value.enumerated() {
                value[index] = val + 1
            }
        } _: {
            // If we couldn't get the Lock
            XCTFail("We SHOULD have been able to acquire the Lock, but couldn't")
        }

        // Assert that each Value has been incremented by 1
        _myInts.withLock { value in
            for (index, val) in value.enumerated() {
                XCTAssertEqual(index + 1, val, "Value \(index) should be \(index + 1) but is \(val)")
            }
        }
    }
}
