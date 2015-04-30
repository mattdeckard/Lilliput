import Cocoa
import XCTest

class LilliputTests: XCTestCase {

    class TestClass {
        typealias StringFilter = (String) -> (String)
        let stringFilter : StringFilter

        init(stringFilter : StringFilter) {
            self.stringFilter = stringFilter
        }

        func useStringFilter(inString: String) -> String {
            return self.stringFilter(inString)
        }
    }

    func testBasicFunctionMocking() {
        let mockStringFilter = MockFunc<String, String>()
        var capturedArg : String?
        let expectedResult = "result"
        when(mockStringFilter) {
            (arg: String) in
            capturedArg = arg
            return expectedResult
        }

        let passedArg = "argument"
        let result = (*mockStringFilter)(passedArg)

        verifyAtLeastOnce(mockStringFilter)
        XCTAssertEqual(capturedArg!, passedArg)
        XCTAssertEqual(result, expectedResult)
    }

    func testThatWeCanInjectTheMock() {
        let mockStringFilter = MockFunc<String, String>()
        var capturedArg : String?
        let expectedResult = "aResult"
        when(mockStringFilter) {
            (arg: String) in
            capturedArg = arg
            return expectedResult
        }

        let passedArg = "anArgument"
        let testClass = TestClass(stringFilter: *mockStringFilter)

        let result = testClass.useStringFilter(passedArg)

        verifyAtLeastOnce(mockStringFilter)
        XCTAssertEqual(capturedArg!, passedArg)
        XCTAssertEqual(result, expectedResult)
    }

    func testMockConstructorThatUsesRealFunction() {
        func realFunction(String) -> String {
            return ""
        }

        let mockFunction = mock(realFunction)

        let expectedResult = "aResult"
        var capturedArg : String?
        when(mockFunction) {
            (arg: String) in
            capturedArg = arg
            return expectedResult
        }

        let passedArg = "argument"
        let result = (*mockFunction)(passedArg)

        verifyAtLeastOnce(mockFunction)
        XCTAssertEqual(capturedArg!, passedArg)
        XCTAssertEqual(result, expectedResult)
    }
}