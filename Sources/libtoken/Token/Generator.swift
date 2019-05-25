//
//  Generator.swift
//  libtoken
//
//  Created by Mason Phillips on 5/25/19.
//

import Foundation
import CommonCrypto

struct Generator: CustomStringConvertible {
    let type     : TokenType
    let digits   : Int
    let secret   : Data
    let algorithm: Algorithm
    
    var description: String {
        var rtr = ""
        rtr += "\t\(algorithm.description) \(digits)-digit "
        switch type {
        case .hotp(let counter):
            let h = base32Encode(secret)
            rtr += "(\(counter))\n\tHOTP(\(h))"
        case .totp(let interval):
            let h = base32Encode(secret)
            rtr += "(\(interval)s)\n\tTOTP(\(h))"
        }
        return rtr
    }
    
    init(type: TokenType, secret: Data, hash: Algorithm, digits: Int) {
        self.type = type
        self.secret = secret
        self.digits = digits
        self.algorithm = hash
    }
    
    enum TokenType {
        case hotp(_ counter: UInt64)
        case totp(_ interval: TimeInterval)
        
        init(type: String, interval: Int) throws {
            switch type {
            case "totp": self = .totp(TimeInterval(interval))
            case "hotp": self = .hotp(UInt64(interval))
            default: throw TokenError.invalidType
            }
        }
        
        internal func value(at time: Date) -> UInt64 {
            switch self {
            case .hotp(let counter): return counter
            case .totp(let interval):
                let sinceEpoch = time.timeIntervalSince1970
                return UInt64(sinceEpoch / interval)
            }
        }
        
        internal func timeRemaining(at time: Date, _ reversed: Bool = false) -> Float {
            switch self {
            case .hotp(let counter):
                return Float(counter)
            case .totp(let interval):
                let epoch = time.timeIntervalSince1970
                let d = Float(interval - epoch.truncatingRemainder(dividingBy: interval))
                let r = Float(interval) - d
                return (reversed) ? d : r
            }
        }
    }
    
    func password(at time: Date, format: Bool) -> String {
        let interval = processDate(at: time)
        let hash = hmac(stepper: interval)
        
        let truncated = truncate(with: hash)
        
        var rtr = String(truncated).padding(toLength: digits, withPad: "0", startingAt: 0)
        let offset = (digits == 8) ? 4 : 3
        if format { rtr.insert(" ", at: rtr.index(rtr.startIndex, offsetBy: offset))}
        
        return rtr
    }
    
    internal func hmac(stepper: Data) -> Data {
        let (algo, length) = self.algorithm.algorithmDetails()
        let hash = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(length))
        defer { hash.deallocate() }
        
        stepper.withUnsafeBytes { kb in
            self.secret.withUnsafeBytes { db in
                CCHmac(algo, db, self.secret.count, kb, stepper.count, hash)
            }
        }
        
        return Data(bytes: hash, count: Int(length))
    }
    
    internal func processDate(at time: Date = Date()) -> Data {
        let interval = type.value(at: time)
        var bigInterval = interval.bigEndian
        return Data(bytes: &bigInterval, count: MemoryLayout<UInt64>.size)
    }
    
    internal func truncate(with hash: Data) -> UInt32 {
        var truncated = hash.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) -> UInt32 in
            let offset = ptr[hash.count - 1] & 0x0f
            
            let tptr = ptr + Int(offset)
            
            return tptr.withMemoryRebound(to: UInt32.self, capacity: 1) { $0.pointee }
        }
        
        truncated = UInt32(bigEndian: truncated)
        truncated &= 0x7fffffff
        truncated = truncated % UInt32(pow(10, 6.0))
        
        return truncated
    }
    
    public static func ==(l: Generator, r: Generator) -> Bool {
        return (l.algorithm == r.algorithm) &&
            (l.digits == r.digits) &&
            (l.secret == r.secret)
    }
}
