//
//  Token.swift
//  libtoken
//
//  Created by Mason Phillips on 5/25/19.
//

import Foundation
import SwiftBase32
import FontAwesome_swift

struct Token: CustomStringConvertible {
    public let generator: Generator
    public let issuer   : String
    public let user     : String
    public let icon     : FontAwesome
    
    var description: String {
        var rtr = ""
        rtr += "\(issuer): \(user)\n"
        rtr += generator.description
        return rtr
    }
    
    public init(from url: URL) throws {
        guard
            url.scheme == "otpauth",
            url.host == "totp" || url.host == "hotp",
            let type = url.host
        else { throw TokenError.invalidFormat }
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw TokenError.urlComponents
        }
        
        let path = components.path
        
        let issuer = try Token.extractIssuer(path: path, params: components.queryItems)
        let user = try Token.extractUser(path: path)
        let generator = try Token.extractGenerator(type: type, params: components.queryItems)
        let icon = Token.extractFontAwesome(params: components.queryItems)
        
        self.init(generator: generator, issuer: issuer, user: user, icon: icon)
    }
    
    init(generator: Generator, issuer: String, user: String, icon: FontAwesome?) {
        self.generator = generator
        self.issuer = issuer
        self.user = user
        
        self.icon = icon ?? .dev
    }
    
    public func password(at date: Date = Date(), format: Bool = false) -> String {
        return generator.password(at: date, format: format)
    }
    
    public func timeRemaining(at date: Date = Date(), reversed: Bool = true) -> Float {
        return generator.type.timeRemaining(at: date, reversed)
    }
}
