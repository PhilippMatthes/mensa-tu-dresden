//
//  Models.swift
//  mensa-tu-dresden
//
//  Created by Philipp Matthes on 10.08.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage
import FirebaseAnalytics
import FirebaseDatabase
import Material


struct Rating {
    
    enum VoteType: Int {
        case down = -1
        case up = 1
    }
    
    let stars: Int
    let comment: String
    let createdBy: String
    let userName: String
    var votes: [String: Int]
    
    var reference: DatabaseReference?
    
    var voteCount: Int {
        get {
            return votes.values.reduce(0, +)
        }
    }
    
    func databaseStorable() -> [AnyHashable : Any] {
        return [
            "stars": stars,
            "comment": comment,
            "createdBy": createdBy,
            "votes": votes,
            "userName": userName
        ]
    }
    
    init(stars: Int, comment: String, userName: String, votesReference: DatabaseReference? = nil) {
        self.stars = stars
        self.comment = comment
        self.userName = userName
        self.createdBy = Authentication.user.uid
        self.votes = [Authentication.user.uid : 1]
        self.reference = votesReference
    }
    
    init?(value: AnyObject, votesReference: DatabaseReference? = nil) {
        guard
            let data = value as? [String: Any],
            let stars = data["stars"] as? Int,
            let userName = data["userName"] as? String,
            let comment = data["comment"] as? String,
            let createdBy = data["createdBy"] as? String,
            let votes = data["votes"] as? [String: Int]
        else {return nil}
        self.stars = stars
        self.comment = comment
        self.userName = userName
        self.createdBy = createdBy
        self.votes = votes
        self.reference = votesReference
    }
    
    func publish(aboutMeal meal: Meal) {
        let ref = MensaDatabase.ratingsReference(meal: meal).child(Authentication.user.uid)
        let post = databaseStorable()
        ref.updateChildValues(post)
    }
    
    func vote(_ type: VoteType) {
        guard let ratingsReference = self.reference else {return}
        ratingsReference.child("votes").updateChildValues(
            [Authentication.user.uid : type.rawValue]
        )
    }
    
    func alreadyVoted() -> VoteType? {
        for (key, value) in votes {
            if key == Authentication.user.uid {
                switch value {
                case VoteType.down.rawValue:
                    return VoteType.down
                case VoteType.up.rawValue:
                    return VoteType.up
                default:
                    continue
                }
            }
        }
        return nil
    }
}
