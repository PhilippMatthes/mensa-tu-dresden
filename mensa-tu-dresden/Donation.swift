//
//  Donation.swift
//  mensa-tu-dresden
//
//  Created by Philipp Matthes on 16.08.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import StoreKit

class Donation {
    
    static let cached = Donation()
    var userHasDonated: Bool?
    
    static var userHasDonated: Bool {
        get {
            if let cached = Donation.cached.userHasDonated {
                return cached
            }
            guard let donated = UserDefaults.standard.object(forKey: "Donated") as? Bool else {return false}
            return donated
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "Donated")
            Donation.cached.userHasDonated = newValue
        }
    }
    
}
