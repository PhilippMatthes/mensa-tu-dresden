//
//  MensaDatabase.swift
//  mensa-tu-dresden
//
//  Created by Philipp Matthes on 12.08.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class MensaDatabase {
    
    static let reference = Database.database().reference()
    
    static func usersReference() -> DatabaseReference {
        return reference.child("users")
    }
    
    static func restaurantsReference(meal: Meal) -> DatabaseReference {
        return reference.child("restaurants").child(meal.mensa)
    }
    
    static func mealsReference(meal: Meal) -> DatabaseReference {
        return restaurantsReference(meal: meal).child("meals").child(meal.name)
    }
    
    static func ratingsReference(meal: Meal) -> DatabaseReference {
        return mealsReference(meal: meal).child("ratings")
    }
    
}
