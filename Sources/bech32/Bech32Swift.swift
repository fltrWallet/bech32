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
//===----------------------------------------------------------------------===//import Cbech32
import Cbech32
import Foundation

public struct Bech32 {}

extension Bech32 {
    public enum Error: Swift.Error {
        case bech32Encode
        case bech32Decode
        case decodeSegWitAddress
        case encodeSegWitAddress
        case hrpHasUppercase
    }
}

public extension Bech32 {
    enum HumanReadablePart: String {
        case main = "bc"
        case testnet = "tb"
    }
}

public extension Bech32 {
    typealias WitnessProgram = (version: Int, program: [UInt8])

    @inlinable
    static func addressEncode(_ hrp: HumanReadablePart, version: Int, witnessProgram: [UInt8]) throws -> String {
        assert(version >= 0 && version <= 16)
        assert(witnessProgram.count >= 2 && witnessProgram.count <= 40)
        let cHrp = hrp.rawValue.cString(using: .ascii)!
        let cString: [Int8] = try Array(unsafeUninitializedCapacity: cHrp.count + 73) { output, setSizeTo in
            let cRet = witnessProgram.withUnsafeBufferPointer { witnessProgram in
                segwit_addr_encode(output.baseAddress!, cHrp, Int32(version), witnessProgram.baseAddress!, witnessProgram.count)
            }
            guard cRet == 1 else { //, let position = output.firstIndex(of: 0) else {
                throw Error.encodeSegWitAddress
            }
            setSizeTo = cHrp.count + 73
        }
        return String(cString: cString)
    }
    
    @inlinable
    static func addressDecode(_ hrp: HumanReadablePart, address: String) throws -> WitnessProgram {
        var outputVersion: Int32 = -1
        let cString = address.cString(using: .utf8)
        let cHrp = hrp.rawValue.cString(using: .utf8)
        let witnessProgram: [UInt8] = try Array(unsafeUninitializedCapacity: 40) { output, setSizeTo in
            setSizeTo = 40
            let cRet = segwit_addr_decode(&outputVersion, output.baseAddress!, &setSizeTo, cHrp, cString)
            guard cRet == 1, outputVersion >= 0 else {
                throw Error.decodeSegWitAddress
            }
        }
        return (Int(outputVersion), witnessProgram)
    }
    
    @inlinable
    static func bech32Encode(_ hrp: String, data: [UInt8]) throws -> String {
        let cHrp = hrp.cString(using: .ascii)
        let result: [Int8] = try Array(unsafeUninitializedCapacity: hrp.count + data.count + 8) { result, setSizeTo in
            let cRet = data.withUnsafeBufferPointer { data in
                bech32_encode(result.baseAddress!, cHrp, data.baseAddress!, data.count, BECH32_ENCODING_BECH32)
            }
            guard cRet == 1 else { //, let position = result.firstIndex(of: 0) else {
                throw Error.bech32Encode
            }
            setSizeTo = hrp.count + data.count + 8
        }
        return String(cString: result)
    }
    
    @inlinable
    static func bech32Decode(_ input: String) throws -> (hrp: String, data: [UInt8]) {
        let cInput = input.cString(using: .ascii)
        var result: [UInt8] = []
        let cHrp: [Int8] = try Array(unsafeUninitializedCapacity: input.count - 6) { hrp, setHrpSizeTo in
            result = try Array(unsafeUninitializedCapacity: input.count) { result, setResultSizeTo in
                let cRet = bech32_decode(hrp.baseAddress!, result.baseAddress!, &setResultSizeTo, cInput)
                guard cRet == BECH32_ENCODING_BECH32 || cRet == BECH32_ENCODING_BECH32M else {
                       // , let position = hrp.firstIndex(of: 0) else {
                    throw Error.bech32Decode
                }
                setHrpSizeTo = input.count - 6
            }
        }
        return (String(cString: cHrp), result)
    }
}
