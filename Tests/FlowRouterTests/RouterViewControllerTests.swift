import XCTest
@testable import FlowRouter

final class RouterViewControllerTests: XCTestCase {
    
    func testRouterViewControllerCanBeSubclassed() throws {
        // This test verifies that RouterViewController can be subclassed
        // and that all required protocols are properly implemented
        
        // Create a simple test view controller that inherits from RouterViewController
        class TestViewController: RouterViewController {
            required init?(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            required init(uuid: String, scheme: String, query: [String: Any], option: RouteOption) {
                super.init(uuid: uuid, scheme: scheme, query: query, option: option)
            }
        }
        
        // Create an instance to verify it compiles and runs
        let testVC = TestViewController(
            uuid: "test-uuid",
            scheme: "test://scheme",
            query: [:],
            option: RouteOption()
        )
        
        XCTAssertNotNil(testVC)
        XCTAssertEqual(testVC.uuid, "test-uuid")
        XCTAssertEqual(testVC.scheme, "test://scheme")
    }
    
    func testRouterPageProtocolImplementation() throws {
        // Test that RouterViewController properly implements RouterPageProtocol
        let testVC = TestRouterViewController(
            uuid: "test-uuid",
            scheme: "test://scheme",
            query: ["key": "value"],
            option: RouteOption()
        )
        
        XCTAssertNotNil(testVC)
        XCTAssertEqual(testVC.uuid, "test-uuid")
        XCTAssertEqual(testVC.scheme, "test://scheme")
        XCTAssertEqual(testVC.query["key"] as? String, "value")
    }
}

// A test implementation of RouterViewController for testing purposes
private class TestRouterViewController: RouterViewController {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(uuid: String, scheme: String, query: [String: Any], option: RouteOption) {
        super.init(uuid: uuid, scheme: scheme, query: query, option: option)
    }
}
