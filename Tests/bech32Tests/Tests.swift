//===----------------------------------------------------------------------===//
//
// This source file is part of the fltrECC open source project
//
// Copyright (c) 2022 fltrWallet AG and the fltrECC project authors
// Licensed under Apache License v2.0
//
// See LICENSE.md for license information
// See CONTRIBUTORS.txt for the list of SwiftNIO project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//
import XCTest
@testable import bech32

class Tests: XCTestCase {
    var validAddresses: [String : (program: [UInt8], hrp: Bech32.HumanReadablePart)] = [:]
    var invalidAddresses: [String : Bech32.HumanReadablePart] = [:]
    var validChecksum: [String] = []
    var invalidChecksum: [String] = []
    
    override func setUp() {
        validAddresses = [
            "BC1QW508D6QEJXTDG4Y5R3ZARVARY0C5XW7KV8F3T4" : (
                [0x00, 0x14, 0x75, 0x1e, 0x76, 0xe8, 0x19, 0x91, 0x96, 0xd4, 0x54,
                 0x94, 0x1c, 0x45, 0xd1, 0xb3, 0xa3, 0x23, 0xf1, 0x43, 0x3b, 0xd6],
                .main
            ),
            "tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sl5k7" : (
                [0x00, 0x20, 0x18, 0x63, 0x14, 0x3c, 0x14, 0xc5, 0x16, 0x68, 0x04,
                 0xbd, 0x19, 0x20, 0x33, 0x56, 0xda, 0x13, 0x6c, 0x98, 0x56, 0x78,
                 0xcd, 0x4d, 0x27, 0xa1, 0xb8, 0xc6, 0x32, 0x96, 0x04, 0x90, 0x32,
                 0x62],
                .testnet
            ),
            "bc1pw508d6qejxtdg4y5r3zarvary0c5xw7kw508d6qejxtdg4y5r3zarvary0c5xw7kt5nd6y" : (
                [0x51, 0x28, 0x75, 0x1e, 0x76, 0xe8, 0x19, 0x91, 0x96, 0xd4, 0x54,
                 0x94, 0x1c, 0x45, 0xd1, 0xb3, 0xa3, 0x23, 0xf1, 0x43, 0x3b, 0xd6,
                 0x75, 0x1e, 0x76, 0xe8, 0x19, 0x91, 0x96, 0xd4, 0x54, 0x94, 0x1c,
                 0x45, 0xd1, 0xb3, 0xa3, 0x23, 0xf1, 0x43, 0x3b, 0xd6],
                .main
            ),
            "BC1SW50QGDZ25J" : (
                [0x60, 0x02, 0x75, 0x1e],
                .main
            ),
            "bc1zw508d6qejxtdg4y5r3zarvaryvaxxpcs" : (
                [0x52, 0x10, 0x75, 0x1e, 0x76, 0xe8, 0x19, 0x91, 0x96, 0xd4, 0x54,
                 0x94, 0x1c, 0x45, 0xd1, 0xb3, 0xa3, 0x23],
                .main
            ),
            "tb1qqqqqp399et2xygdj5xreqhjjvcmzhxw4aywxecjdzew6hylgvsesrxh6hy" : (
                [0x00, 0x20, 0x00, 0x00, 0x00, 0xc4, 0xa5, 0xca, 0xd4, 0x62, 0x21,
                0xb2, 0xa1, 0x87, 0x90, 0x5e, 0x52, 0x66, 0x36, 0x2b, 0x99, 0xd5,
                0xe9, 0x1c, 0x6c, 0xe2, 0x4d, 0x16, 0x5d, 0xab, 0x93, 0xe8, 0x64,
                0x33],
                .testnet
            ),
            "tb1pqqqqp399et2xygdj5xreqhjjvcmzhxw4aywxecjdzew6hylgvsesf3hn0c" : (
                [0x51, 0x20, 0x00, 0x00, 0x00, 0xc4, 0xa5, 0xca, 0xd4, 0x62, 0x21,
                 0xb2, 0xa1, 0x87, 0x90, 0x5e, 0x52, 0x66, 0x36, 0x2b, 0x99, 0xd5,
                 0xe9, 0x1c, 0x6c, 0xe2, 0x4d, 0x16, 0x5d, 0xab, 0x93, 0xe8, 0x64,
                 0x33],
                .testnet
            ),
            "bc1p0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7vqzk5jj0" : (
                [0x51, 0x20, 0x79, 0xbe, 0x66, 0x7e, 0xf9, 0xdc, 0xbb, 0xac, 0x55,
                 0xa0, 0x62, 0x95, 0xce, 0x87, 0x0b, 0x07, 0x02, 0x9b, 0xfc, 0xdb,
                 0x2d, 0xce, 0x28, 0xd9, 0x59, 0xf2, 0x81, 0x5b, 0x16, 0xf8, 0x17,
                 0x98],
                .main
            ),
        ]
        invalidAddresses = [
            "tc1qw508d6qejxtdg4y5r3zarvary0c5xw7kg3g4ty" : .testnet,
            "bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t5" : .main,
            "BC13W508D6QEJXTDG4Y5R3ZARVARY0C5XW7KN40WF2" : .main,
            "bc1rw5uspcuh" : .testnet,
            "bc10w508d6qejxtdg4y5r3zarvary0c5xw7kw508d6qejxtdg4y5r3zarvary0c5xw7kw5rljs90" : .main,
            "bca0w508d6qejxtdg4y5r3zarvary0c5xw7kw508d6qejxtdg4y5r3zarvary0c5xw7kw5rljs90234567789035" : .main,
            "BC1QR508D6QEJXTDG4Y5R3ZARVARYV98GJ9P" : .main,
            "tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sL5k7" : .testnet,
            "bc1zw508d6qejxtdg4y5r3zarvaryvqyzf3du" : .main,
            "tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3pjxtptv" : .testnet,
            "bc1gmk9yu" : .main,
        ]
        validChecksum = [
            "A12UEL5L",
            "an83characterlonghumanreadablepartthatcontainsthenumber1andtheexcludedcharactersbio1tt5tgs",
            "abcdef1qpzry9x8gf2tvdw0s3jn54khce6mua7lmqqqxw",
            "11qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqc8247j",
            "split1checkupstagehandshakeupstreamerranterredcaperred2y9e3w",
        ]
        invalidChecksum = [
            " 1nwldj5",
            "\(0x7f)1axkwrx",
            "an84characterslonghumanreadablepartthatcontainsthenumber1andtheexcludedcharactersbio1569pvx",
            "pzry9x0s0muk",
            "1pzry9x0s0muk",
            "x1b4n0q5v",
            "li1dgmt3",
            "de1lg7wt\(0xff)",
        ]
    }
    
    func testAddressDecodeEncode() {
        for a in validAddresses {
            var result: Bech32.WitnessProgram?
            do {
                result = try Bech32.addressDecode(a.value.hrp, address: a.key)
            } catch {}
            XCTAssertNotNil(result)
            XCTAssertEqual(result!.program.count, Int(a.value.program[1]))
            XCTAssertEqual(result!.program, Array(a.value.program[2...]))
            
            var reAddress: String?
            do {
                reAddress = try Bech32.addressEncode(a.value.hrp, version: result!.version, witnessProgram: result!.program)
            } catch {}
            XCTAssertNotNil(reAddress)
            XCTAssertEqual(reAddress!, a.key.lowercased())
        }
        
        func failingFunc(_ hrp: Bech32.HumanReadablePart, _ invalidAddress: String) throws {
            _ = try Bech32.addressDecode(hrp, address: invalidAddress)
        }
        
        for i in invalidAddresses {
            XCTAssertThrowsError(try failingFunc(i.value, i.key))
        }
    }

    func testBech32DecodeEncode() {
        for c in validChecksum {
            var result: (String, [UInt8])?
            do {
                result = try Bech32.bech32Decode(c)
            } catch {}
            XCTAssertNotNil(result)

            var rebuild: String?
            do {
                rebuild = try Bech32.bech32Encode(result!.0, data: result!.1)
            } catch {}
            XCTAssertNotNil(rebuild)
            XCTAssertEqual(rebuild!, c.lowercased())
        }
        
        func failingFunc(_ str: String) throws {
            _ = try Bech32.bech32Decode(str)
        }
        
        for i in invalidChecksum {
            XCTAssertThrowsError(try failingFunc(i))
        }
    }
}
