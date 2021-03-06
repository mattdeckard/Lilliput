import Foundation
import XCTest

class MockBuilder<A: Equatable, B: Equatable> {
    let testCase: XCTestCase

    init(testCase: XCTestCase) {
        self.testCase = testCase
    }

    func returning<ReturnType: DefaultConstructible>(_ returnType: ReturnType.Type) -> MockFunctionUsingDefaultConstructorForReturn<A, B, ReturnType> {
        return MockFunctionUsingDefaultConstructorForReturn<A, B, ReturnType>(testCase: self.testCase)
    }


    func returning<ReturnType>(_ returnType: ReturnType.Type) -> MockFunctionWithoutDefaultReturn<A, B, ReturnType> {
        return MockFunctionWithoutDefaultReturn<A, B, ReturnType>(testCase: self.testCase)
    }
}

extension XCTestCase {
    func mock<A: Equatable, B: Equatable>(_ a: A.Type, _ b: B.Type) -> MockBuilder<A, B> {
        return MockBuilder<A, B>(testCase: self)
    }

    func mock<A: Equatable>(_ a: A.Type) -> MockBuilder<A, NoArgument> {
        return MockBuilder<A, NoArgument>(testCase: self)
    }
}
