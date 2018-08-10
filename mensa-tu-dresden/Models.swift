//
//  Models.swift
//  mensa-tu-dresden
//
//  Created by Philipp Matthes on 10.08.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation


struct Rating: Codable, Equatable {
    let meal: Meal
    let userSpecificRatings: [UserSpecificRating]
    
    enum CodingKeys: String, CodingKey {
        case meal = "meal"
        case userSpecificRatings = "userSpecificRatings"
    }
}

struct UserSpecificRating: Codable, Equatable {
    let uid: String
    let rating: Int
    let comment: String
    
    enum CodingKeys: String, CodingKey {
        case uid = "uid"
        case rating = "rating"
        case comment = "comment"
    }
}

struct Meal: Codable, Equatable {
    let name: String
    let mensa: String
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case mensa = "mensa"
    }
    
    init(name: String, mensa: String) {
        self.name = name
        self.mensa = mensa
    }
}
