//
//  Authentication.swift
//  mensa-tu-dresden
//
//  Created by Philipp Matthes on 11.08.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn

class Authentication {
    static var user: User!
    static var loginType: LoginType!
    
    enum LoginType: String {
        case facebook
        case google
        case anonymous
    }
    
    @discardableResult static func signOut() -> Bool {
        guard
            loginType != .anonymous,
            let _ = try? Auth.auth().signOut()
        else {return false}
        
        if let loginType = loginType {
            switch loginType {
            case .facebook:
                FBSDKLoginManager().logOut()
            case .google:
                GIDSignIn.sharedInstance()?.signOut()
                GIDSignIn.sharedInstance()?.disconnect()
            default:
                break
            }
        }
        user = nil
        loginType = nil
        
        return true
    }
}
