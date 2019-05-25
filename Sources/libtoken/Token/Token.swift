//
//  Token.swift
//  libtoken
//
//  Created by Mason Phillips on 5/25/19.
//

import Foundation
import FontAwesome_swift

public struct Token: CustomStringConvertible {
    let generator: Generator
    public let issuer   : String
    public let user     : String
    public let icon     : FontAwesome
    
    internal var position: Int
    internal var todayFlag: Bool
    
    public var description: String {
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
        let (position, flag) = Token.extractInternalItems(params: components.queryItems)
        
        self.init(generator: generator, issuer: issuer, user: user, icon: icon, position: position, today: flag)
    }
    
    init(generator: Generator, issuer: String, user: String, icon: FontAwesome?, position: Int? = nil, today: Bool? = nil) {
        self.generator = generator
        self.issuer = issuer
        self.user = user
        
        self.icon = icon ?? .dev
        self.position = position ?? 0
        self.todayFlag = today ?? false
    }
    
    public func password(at date: Date = Date(), format: Bool = false) -> String {
        return generator.password(at: date, format: format)
    }
    
    public func timeRemaining(at date: Date = Date(), reversed: Bool = true) -> Float {
        return generator.type.timeRemaining(at: date, reversed)
    }
    
    mutating func set(position: Int) {
        self.position = position
    }
    
    mutating func set(todayFlag: Bool) {
        self.todayFlag = todayFlag
    }
    
    public func serialize() -> URL {
        var components = URLComponents()
        components.scheme = "otpauth"
        
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "secret", value: base32Encode(generator.secret)),
            URLQueryItem(name: "issuer", value: issuer),
            URLQueryItem(name: "icon", value: icon.iconName()),
            URLQueryItem(name: "position", value: "\(position)"),
            URLQueryItem(name: "today", value: "\(todayFlag)")
        ]
        
        switch generator.type {
        case .hotp(let counter):
            queryItems.append(URLQueryItem(name: "counter", value: "\(Int(counter))"))
            components.host = "hotp"
        case .totp(let interval):
            queryItems.append(URLQueryItem(name: "period", value: "\(Int(interval))"))
            components.host = "totp"
        }
        
        components.path = "/\(user):\(issuer)"
        components.queryItems = queryItems
        
        return components.url!
    }
}
