//  Project name: FwiCore
//  File name   : Data+FwiHexTest.swift
//
//  Author      : Phuc, Tran Huu
//  Created date: 11/23/14
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2012, 2016 Fiision Studio.
//  All Rights Reserved.
//  --------------------------------------------------------------
//
//  Permission is hereby granted, free of charge, to any person obtaining  a  copy
//  of this software and associated documentation files (the "Software"), to  deal
//  in the Software without restriction, including without limitation  the  rights
//  to use, copy, modify, merge,  publish,  distribute,  sublicense,  and/or  sell
//  copies of the Software,  and  to  permit  persons  to  whom  the  Software  is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF  ANY  KIND,  EXPRESS  OR
//  IMPLIED, INCLUDING BUT NOT  LIMITED  TO  THE  WARRANTIES  OF  MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO  EVENT  SHALL  THE
//  AUTHORS OR COPYRIGHT HOLDERS  BE  LIABLE  FOR  ANY  CLAIM,  DAMAGES  OR  OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING  FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN  THE
//  SOFTWARE.
//
//
//  Disclaimer
//  __________
//  Although reasonable care has been taken to  ensure  the  correctness  of  this
//  software, this software should never be used in any application without proper
//  testing. Fiision Studio disclaim  all  liability  and  responsibility  to  any
//  person or entity with respect to any loss or damage caused, or alleged  to  be
//  caused, directly or indirectly, by the use of this software.

import XCTest
@testable import FwiCore


class DataFwiHexTest: XCTestCase {

    // MARK: Setup
    override func setUp() {
        super.setUp()
    }

    // MARK: Tear Down
    override func tearDown() {
        super.tearDown()
    }

    // MARK: Test Cases
    func testIsHex() {
        var hexData = "FwiCore".toData()
        XCTAssert(hexData?.isHex() == false, "Invalid hex data should always return false.")

        hexData = "467769436f7265".toData()
        XCTAssert(hexData?.isHex() == true, "467769436f7265 is a valid hex.")
    }

    func testDecodeHexData() {
        var hexData = "FwiCore".toData()
        XCTAssertNil(hexData?.decodeHexData(), "Expected nil data for invalid hex.")

        let data = "FwiCore".toData()
        hexData = "467769436f7265".toData()
        XCTAssertEqual(hexData?.decodeHexData(), data, "Expected 'FwiCore'.")
    }
    func testDecodeHexString() {
        let hexData = "467769436f7265".toData()
        XCTAssertEqual(hexData?.decodeHexString(), "FwiCore", "Expected 'FwiCore'.")
    }

    func testEncodeHexData() {
        var data = "".toData()
        XCTAssertNil(data?.encodeHexData(), "Empty data should return nil.")

        data = "FwiCore".toData()
        let hexData = "467769436f7265".toData()
        XCTAssertEqual(data?.encodeHexData(), hexData, "Expected '467769436f7265'.")
    }
    func testEncodeHexString() {
        XCTAssertNil("".toData()?.encodeHexString(), "Empty string should return nil.")

        let data = "FwiCore".toData()
        XCTAssertEqual(data?.encodeHexString(), "467769436f7265", "Expected '467769436f7265'.")
    }
}