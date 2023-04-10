//
//  SwolematesTests.swift
//  SwolematesTests
//

import XCTest

@testable import Swolemates

final class SwolematesTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAddMemberThrows() {
        func testAddMember() async throws{
            
            let client = UsersTable().client
            let (messages,_)=try await MessageTable().loadMessageandMembers(client, "ty")
            
            
            XCTAssert(messages.count>0)
        }
    }
    
    func testDecodeToUser() async {
        
           }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
