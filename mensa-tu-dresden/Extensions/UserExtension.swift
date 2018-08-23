//
//  UserExtension.swift
//  mensa-tu-dresden
//
//  Created by Philipp Matthes on 18.08.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import FirebaseAuth
import Firebase

extension User {
    
    func loginType(completion: @escaping (Authentication.LoginType?) -> ()) {
        let child = MensaDatabase.usersReference().child(self.uid)
        child.observeSingleEvent(of: .value, with: ({
            snapshot in
            guard
                let value = snapshot.value as? [String: Any],
                let type = value["type"] as? String
                else {completion(nil); return}
            completion(Authentication.LoginType(rawValue: type))
        }), withCancel: ({
            error in
            completion(nil)
        }))
    }
    
}
