//
//  AndTests.swift
//  jsonfunctionsTests
//
//  Created by Christos Koninis on 12/02/2019.
//

import XCTest
import JSON
@testable import jsonfunctions

class AndTests: XCTestCase {

    func testAnd_twoBooleans() {
        
        XCTAssertNil(try JsonFunctions().applyRule("""
                                                  {"and": [null, true]}
                                                  """, to: nil))
        
        XCTAssertEqual(true, try JsonFunctions().applyRule("""
                                                  {"and": [true, true]}
                                                  """, to: nil))

        XCTAssertEqual(false, try JsonFunctions().applyRule("""
                                                    { "and" : [true, false] }
                                                    """, to: nil))

        XCTAssertEqual(true, try JsonFunctions().applyRule("""
                                                   { "and" : [true] }
                                                   """, to: nil))
        XCTAssertEqual(false, try JsonFunctions().applyRule("""
                                                      { "and" : [false] }
                                                     """, to: nil))
    }

    func testAnd_mixedArguments() {
        XCTAssertEqual(3, try JsonFunctions().applyRule("""
                { "and": [1, 3] }
                """, to: nil))

        XCTAssertEqual("a", try JsonFunctions().applyRule("""
                { "and": ["a"] }
                """, to: nil))

        XCTAssertEqual("", try JsonFunctions().applyRule("""
                { "and": [true,"",3] }
                """, to: nil))
    }
}
