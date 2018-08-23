//
//  LoginController.swift
//  mensa-tu-dresden
//
//  Created by Philipp Matthes on 11.08.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import Material
import CoreLocation
import FlyoverKit
import GoogleSignIn
import FBSDKLoginKit

// GIDSignInDelegate, GIDSignInUIDelegate, FBSDKLoginButtonDelegate

class LoginController: UIViewController {
    
    /*
    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
    @IBOutlet weak var googleLoginButton: FlatButton!
    @IBOutlet weak var anonymousLoginButton: FlatButton!
    */
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    /*
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        guard
            error == nil,
            let tokenString = FBSDKAccessToken.current()?.tokenString
            else {return}
        let credential = FacebookAuthProvider.credential(withAccessToken: tokenString)
        Auth.auth().signInAndRetrieveData(with: credential) {
            authResult, error in
            self.handleLoginWith(authResult, andError: error, loginType: .facebook)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Log Out!")
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard
            error == nil,
            let authentication = user.authentication
        else {return}
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        print(user.authentication)
        Auth.auth().signInAndRetrieveData(with: credential) {
            authResult, error in
            self.handleLoginWith(authResult, andError: error, loginType: .google)
        }
    }
     */
    
    static func fromStoryboard() -> LoginController {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let loginController = storyBoard.instantiateViewController(withIdentifier: "LoginController") as! LoginController
        return loginController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signInAnonymously()
        
        /*
        Auth.auth().addStateDidChangeListener {
            auth, user in
            guard user == nil else {return}
            self.navigationController?.popToRootViewController(animated: true)
        }
        
        prepareGoogleSignIn()
        prepareFacebookSignIn()
        prepareAnonymousButton()
        */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /*
        navigationController?.navigationBar.isHidden = true
        if isMovingToParent {
            if let facebookToken = FBSDKAccessToken.current()?.tokenString {
                let credential = FacebookAuthProvider.credential(withAccessToken: facebookToken)
                Auth.auth().signInAndRetrieveData(with: credential) {
                    authResult, error in
                    self.handleLoginWith(authResult, andError: error, loginType: .facebook)
                }
                return
            } else if let signedInWithGoogle = GIDSignIn.sharedInstance()?.hasAuthInKeychain() {
                if signedInWithGoogle {
                    GIDSignIn.sharedInstance()?.signInSilently()
                    return
                }
            }
        }
        showButtons()
        */
    }
    
    /*
    func prepareGoogleSignIn() {
        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.uiDelegate = self
        googleLoginButton.titleLabel?.font = RobotoFont.regular(with: 16.0)
        googleLoginButton.pulseColor = .white
        googleLoginButton.backgroundColor = Colors.backgroundColor
    }
    
    func prepareFacebookSignIn() {
        facebookLoginButton.delegate = self
        for constraint in facebookLoginButton.constraints {
            if constraint.constant == 28 {
                facebookLoginButton.removeConstraint(constraint)
            }
        }
        facebookLoginButton.titleLabel?.font = RobotoFont.regular(with: 16.0)
        facebookLoginButton.backgroundColor = Colors.backgroundColor
    }
    
    func prepareAnonymousButton() {
        anonymousLoginButton.backgroundColor = Colors.backgroundColor
    }
    
    @IBAction func signIn(_ sender: UIButton) {
        switch sender {
        case googleLoginButton:
            GIDSignIn.sharedInstance()?.signIn()
        case anonymousLoginButton:
            signInAnonymously()
        default:
            break
        }
    }
    */
    
    func signInAnonymously() {
        Auth.auth().signInAnonymously() {
            (authResult, error) in
            self.handleLoginWith(authResult, andError: error, loginType: .anonymous)
        }
    }
    
    func handleLoginWith(_ result: AuthDataResult?, andError error: Error?, loginType type: Authentication.LoginType) {
        guard
            error == nil,
            let result = result
        else {
            NSLog("%@", "User could not be signed in")
            return
        }
        
        NSLog("%@", "\(result.user.displayName ?? "Anonymous user") was logged in")
        
        // hideButtons()
        
        presentUI(forUser: result.user, andLoginType: type)
    }
    
    func presentUI(forUser user: User, andLoginType type: Authentication.LoginType) {
        Authentication.user = user
        Authentication.loginType = type
        
        MensaDatabase.usersReference().updateChildValues([
            user.uid : ["points": 0, "type": type.rawValue]
        ])
        
        let mensaController = MensaController()
        let searchController = AppSearchBarController(rootViewController: mensaController, tintColor: Colors.backgroundColor)
        let navigationController = AppNavigationController(rootViewController: searchController)
        navigationController.navigationBar.isHidden = true
        present(navigationController, animated: false)
        // navigationController?.pushViewController(searchController, animated: true)
    }
    
    /*
    func showButtons() {
        for button in [facebookLoginButton, anonymousLoginButton, googleLoginButton] {
            button?.isEnabled = true
            button?.isHidden = false
        }
        indicator.isHidden = true
    }
    
    func hideButtons() {
        for button in [facebookLoginButton, anonymousLoginButton, googleLoginButton] {
            button?.isEnabled = false
            button?.isHidden = true
        }
        indicator.isHidden = false
    }
    */
    
}
