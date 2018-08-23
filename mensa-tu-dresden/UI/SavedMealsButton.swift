//
//  SavedMealsButton.swift
//  mensa-tu-dresden
//
//  Created by Philipp Matthes on 21.08.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation

import Foundation
import Material
import Alamofire
import MIBadgeButton_Swift

import UIKit

class SavedMealsButton: MIBadgeButton {
    
    func prepare(forTintColor tintColor: UIColor) {
        setImage(Icon.menu, for: .normal)
        self.tintColor = tintColor
        imageView?.layer.cornerRadius = self.frame.height / 2
        imageView?.layer.masksToBounds = true
        if let trackedMeals = Meal.trackedMeals {
            self.badgeString = "\(trackedMeals.count)"
            self.badgeEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 0, right: 0)
            self.badgeAnchor = .TopLeft(topOffset: 0.0, leftOffset: 0.0)
            self.badgeTextColor = .white
            self.badgeBackgroundColor = tintColor
        }
    }
    
    func updateBadge() {
        if let trackedMeals = Meal.trackedMeals {
            self.badgeString = "\(trackedMeals.count)"
        } else {
            self.badgeString = nil
        }
    }
    
}

