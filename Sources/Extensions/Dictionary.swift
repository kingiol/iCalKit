//
//  Dictionary.swift
//  iCalKit
//
//  Created by Kingiol on 2019/5/24.
//  Copyright © 2019 iCalKit. All rights reserved.
//

import Foundation

extension Dictionary where Key: Hashable, Value: Any {

    func filterKey(isIncluded: (Key) -> Bool) -> Key? {
        return self.keys.filter(isIncluded).first
    }

}

extension Dictionary where Key == String {

    func filterKeyHasPrefix(_ prefix: String) -> Key? {
        return filterKey(isIncluded: { $0.hasPrefix(prefix) })
    }

}
