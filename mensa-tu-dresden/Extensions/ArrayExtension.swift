//
//  ArrayExtension.swift
//  mensa-tu-dresden
//
//  Created by Philipp Matthes on 21.08.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation

extension Collection where Indices.Iterator.Element == Index {
    subscript (has index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
