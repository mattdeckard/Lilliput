import Foundation
import XCTest

class _MockFunction<T: Equatable, ReturnType> {
    typealias Signature = (T) -> ReturnType
    typealias TBinding = Binding<T>
    typealias Bindings = [(TBinding, ReturnType)]

    var bindings: Bindings

    init(bindings: Bindings) {
        self.bindings = bindings
    }
}

class MockFunction<T: Equatable, ReturnType>: _MockFunction<T, ReturnType> {
    var invocationCount = 0
    let defaultReturn: ReturnType

    init(bindings: Bindings, defaultReturn: ReturnType) {
        self.defaultReturn = defaultReturn
        super.init(bindings: bindings)
    }

    func unbox() -> Signature {
        return {
            (arg: T) in
            self.invocationCount++
            for (binding, returnValue) in self.bindings {
                if arg == binding.boundArgument {
                    return returnValue
                }
            }
            return self.defaultReturn
        }
    }
}

class MockFunctionUsingDefaultConstructorForReturn<T: Equatable, ReturnType: DefaultConstructible>: MockFunction<T, ReturnType> {
    init(bindings: Bindings) {
        super.init(bindings: bindings, defaultReturn: ReturnType())
    }
}

class MockFunctionWithoutDefaultReturn<T: Equatable, ReturnType>: _MockFunction<T, ReturnType> {
    override init(bindings: Bindings) { // FIXME: why is this needed?
        super.init(bindings: bindings)
    }

    func orElse(defaultReturn: ReturnType) -> MockFunction<T, ReturnType> {
        return MockFunction<T, ReturnType>(bindings: self.bindings, defaultReturn: defaultReturn)
    }
}

// MARK: Bindings

class Binding<T: Equatable> {
    let boundArgument: T

    init(_ arg: T) {
        boundArgument = arg
    }

    func then<ReturnType>(returnValue: ReturnType) -> MockFunctionWithoutDefaultReturn<T, ReturnType> {
        return MockFunctionWithoutDefaultReturn<T, ReturnType>(bindings: [(self, returnValue)])
    }

    func then<ReturnType>(returnValue: ReturnType) -> MockFunctionUsingDefaultConstructorForReturn<T, ReturnType> {
        return MockFunctionUsingDefaultConstructorForReturn<T, ReturnType>(bindings: [(self, returnValue)])
    }
}

// MARK: Syntactic Sugar

func when<T: Equatable>(arg: T) -> Binding<T> {
    return Binding(arg)
}

extension XCTestCase {
    func verifyNever<T: Equatable, ReturnType>(mockFunc: MockFunction<T, ReturnType>,
        inFile filePath: String = __FILE__,
        atLine lineNumber: UInt = __LINE__) -> () {
            if (mockFunc.invocationCount != 0) {
                self.recordFailureWithDescription("Mocked function was called more than zero times", inFile: filePath, atLine: lineNumber, expected: true)
            }
    }

    func verifyAtLeastOnce<T: Equatable, ReturnType>(mockFunc: MockFunction<T, ReturnType>,
        inFile filePath: String = __FILE__,
        atLine lineNumber: UInt = __LINE__) -> () {
            if (mockFunc.invocationCount < 1) {
                self.recordFailureWithDescription("Mocked function was not called at least once", inFile: filePath, atLine: lineNumber, expected: true)
            }
    }
}
