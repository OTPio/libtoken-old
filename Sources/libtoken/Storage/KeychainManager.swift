//
//  KeychainManager.swift
//  libtoken
//
//  Created by Mason Phillips on 5/25/19.
//

import Foundation
import KeychainAccess

public class TokenManager {
    public static let shared: TokenManager = TokenManager()
    
    private let mainKeychain: Keychain
    public  var tokens      : [Token]
    
    init() {
        mainKeychain = Keychain(service: "io.matrixstudios.libtoken", accessGroup: "main").synchronizable(true).accessibility(.afterFirstUnlock)
        tokens = mainKeychain.allKeys().compactMap { [mainKeychain] key -> Token? in
            guard
                let urlString = mainKeychain[key],
                let url = URL(string: urlString),
                let token = try? Token(from: url)
            else { return nil }
            return token
        }
    }
    
    public func add(_ token: Token) {
        tokens.append(token)
    }
    
    public func add(_ url: URL?) -> Bool {
        guard
            let url = url,
            let token = try? Token(from: url)
        else { return false }
        self.add(token)
        return true
    }
    
    public func remove(_ token: Token) {
        tokens = tokens.filter { $0 != token }
    }
    
    public func synchronize() {
        try? mainKeychain.removeAll()
        for token in tokens {
            let url = token.serialize()
            let key = "\(token.issuer):\(token.user)"
            try? mainKeychain.set(url.absoluteString, key: key)
        }
    }
}
