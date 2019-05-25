//
//  TokenError.swift
//  libtoken
//
//  Created by Mason Phillips on 5/25/19.
//

import Foundation

public enum TokenError: Error {
    case invalidFormat, urlComponents
    case issuerMissing, issuerInvalid, userInvalid, secretMissing, secretInvalid, hotpCounterMissing, algorithmInvalid
    case invalidType
    
    case generalError(message: String)
}
