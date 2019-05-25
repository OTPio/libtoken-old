//
//  TokenExtensions.swift
//  libtoken
//
//  Created by Mason Phillips on 5/25/19.
//

import Foundation
import FontAwesome_swift

extension Token {
    static func extractIssuer(path: String, params: [URLQueryItem]?) throws -> String {
        if path.contains(":") {
            guard var issuer = path.split(separator: ":").first else {
                throw TokenError.issuerInvalid
            }
            if issuer.first == "/" {
                issuer = issuer.dropFirst()
            }
            return String(issuer)
        } else {
            let issuerParam = params?.filter { $0.name == "issuer" }.first?.value
            guard let issuer = issuerParam else {
                throw TokenError.issuerMissing
            }
            return issuer
        }
    }
    
    static func extractUser(path: String) throws -> String {
        if path.contains(":") {
            guard let user = path.split(separator: ":").last else {
                throw TokenError.userInvalid
            }
            return String(user)
        } else {
            return path
        }
    }

    static func extractGenerator(type: String, params: [URLQueryItem]?) throws -> Generator {
        guard
            let secretString = params?.filter({$0.name == "secret"}).first?.value,
            let secret = base32DecodeToData(secretString)
        else { throw TokenError.secretMissing }
        
        let hashString = params?.filter { $0.name == "algorithm" }.first?.value ?? "sha-1"
        let hash = Algorithm(rawValue: hashString) ?? .sha1
        
        let digitsString = params?.filter { $0.name == "digits" }.first?.value
        let digits = Int(digitsString ?? "6") ?? 6
        
        let tokenType = try Token.extractDigits(type: type, params: params)
        
        let generator = Generator(type: tokenType, secret: secret, hash: hash, digits: digits)
        return generator
    }
    
    static func extractDigits(type: String, params: [URLQueryItem]?) throws -> Generator.TokenType {
        switch type {
        case "totp":
            let periodString = params?.filter({$0.name == "period"}).first?.value ?? "30"
            let period = Int(periodString) ?? 30
            return .totp(TimeInterval(period))
        case "hotp":
            guard
                let counterString = params?.filter({$0.name == "counter"}).first?.value,
                let counter = Int(counterString)
            else { throw TokenError.hotpCounterMissing }
            return .hotp(UInt64(counter))
        default: throw TokenError.invalidType
        }
    }
    
    static func extractFontAwesome(params: [URLQueryItem]?) -> FontAwesome? {
        guard let iconString = params?.filter({$0.name == "icon"}).first?.value else {
            return nil
        }
        return FontAwesome(rawValue: iconString)
    }
    
    static func extractInternalItems(params: [URLQueryItem]?) -> (Int?, Bool?) {
        var rtr: (Int?, Bool?) = (nil, nil)
        if let position = params?.filter({$0.name == "position"}).first?.value {
            rtr.0 = Int(position)
        }
        if let flag = params?.filter({$0.name == "today"}).first?.value {
            rtr.1 = Bool(flag)
        }
        
        return rtr
    }
}
