//
//  FAExtensions.swift
//  libtoken
//
//  Created by Mason Phillips on 5/25/19.
//

import Foundation
import FontAwesome_swift

extension FontAwesome {
    public func iconName() -> String? {
        let v = self.rawValue
        let rtr = FontAwesomeIcons.filter { $0.value == v }
        return rtr.first?.key
    }
}

extension String {
    public func closestBrand() -> FontAwesome {
        let keys = Array(FontAwesomeBrandIcons.keys).sortedByFuzzyMatchPattern(self)
        let firstKey = keys.first!
        let value = FontAwesomeBrandIcons[firstKey]!
        return FontAwesome(rawValue: value)!
    }
}
