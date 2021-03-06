//  File name   : Data+Hex.swift
//
//  Author      : Phuc, Tran Huu
//  Editor      : Dung Vu
//  Created date: 11/20/14
//  --------------------------------------------------------------
//  Copyright © 2012, 2019 Fiision Studio. All Rights Reserved.
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

import Foundation

public extension Data {
    // MARK: - Validate Hex
    var isHex: Bool {
        /* Condition validation */
        if count <= 0 || (count % 2) != 0 { return false }
        var isHex = true

        let input = [UInt8](self)
        for index in stride(from: 0, to: count, by: 2) {
            let v1 = input[index]
            let v2 = input[index + 1]

            // Check v1
            isHex = isHex && ((v1 >= 48 && v1 <= 57) || // '0-9'
                (v1 >= 65 && v1 <= 70) || // 'A-F'
                (v1 >= 97 && v1 <= 102)) // 'a-f'

            // Check v2
            isHex = isHex && ((v2 >= 48 && v2 <= 57) || // '0-9'
                (v2 >= 65 && v2 <= 70) || // 'A-F'
                (v2 >= 97 && v2 <= 102)) // 'a-f'

            if !isHex { break }
        }
        return isHex
    }

    // MARK: - Decode Hex
    func decodeHexData() -> Data? {
        /* Condition validation */
        if !isHex { return nil }

        var output = [UInt8](repeating: 0, count: count / 2)
        let input = [UInt8](self)

        for index in stride(from: 0, to: count, by: 2) {
            var b1 = input[index]
            var b2 = input[index + 1]

            if b1 >= 48, b1 <= 57 { // '0-9'
                b1 -= 48
            } else if b1 >= 65, b1 <= 70 { // 'A-F'
                b1 -= 55 // A = 10, 'A' = 65 -> b = 65 - 55
            } else { // 'a-f'
                b1 -= 87 // a = 10, 'a' = 97 -> b = 97 - 87
            }

            if b2 >= 48, b2 <= 57 { // '0-9'
                b2 -= 48
            } else if b2 >= 65, b2 <= 70 { // 'A-F'
                b2 -= 55 // A = 10, 'A' = 65 -> b = 65 - 55
            } else { // 'a-f'
                b2 -= 87 // a = 10, 'a' = 97 -> b = 97 - 87
            }

            output[index / 2] = (b1 << 4 | b2)
        }
        return Data(output)
    }

    func decodeHexString() -> String? { decodeHexData()?.toString() }

    // MARK: - Encode Hex
    func encodeHexData() -> Data? {
        /* Condition validation */
        if count <= 0 { return nil }

        let length = count * 2
        var output = [UInt8](repeatElement(0, count: length))

        var offset = 0
        let input = [UInt8](self)

        for index in stride(from: 0, to: length, by: 2) {
            let v = input[offset]

            var b1 = (v & 0xf0) >> 4
            var b2 = v & 0x0f

            if b1 >= 0, b1 <= 9 { // '0-9'
                b1 += 48
            } else { // 'a-f'
                b1 += 87 // a = 10, 'a' = 97 -> b = 10 + 87
            }

            if b2 >= 0, b2 <= 9 { // '0-9'
                b2 += 48
            } else { // 'a-f'
                b2 += 87 // a = 10, 'a' = 97 -> b = 10 + 87
            }

            output[index] = b1
            output[index + 1] = b2
            offset += 1
        }
        return Data(output)
    }

    func encodeHexString() -> String? { encodeHexData()?.toString() }
}
