//
//  Colors.swift
//  mensa-tu-dresden
//
//  Created by Philipp Matthes on 10.08.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit
import Material

class Colors {
    static let all = [
        UIColor(rgb: 0xeb3b5a),
        UIColor(rgb: 0xfa8231),
        UIColor(rgb: 0xf7b731),
        UIColor(rgb: 0x20bf6b),
        UIColor(rgb: 0x0fb9b1),
        UIColor(rgb: 0x45aaf2),
        UIColor(rgb: 0x4b7bec),
        UIColor(rgb: 0xa55eea),
        
    ]
    
    static func colorFor(string: String?) -> UIColor {
        guard let string = string else {return all.first!}
        return all[string.count % all.count]
    }
}
