//
//  LoginController.swift
//  mensa-tu-dresden
//
//  Created by Philipp Matthes on 11.08.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import FirebaseAuth
import Material
import CoreLocation
import FlyoverKit

class LoginController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(rgb: 0xff4757)
        let image = UIImageView(image: UIImage(named: "mensa-tu-dresden"))
        view.layout(image).center().height(100).width(100)
        login()
    }
    
    func login() {
        Auth.auth().signInAnonymously() {
            (authResult, error) in
            guard let result = authResult else {fatalError(error!.localizedDescription)}
            Authentication.user = result.user
            
            MensaDatabase.usersReference().updateChildValues([
                result.user.uid : ["points": 0]
            ])
            
            let mensaController = MensaController()
            let searchController = SearchBarController(rootViewController: mensaController)
           
            let navController = AppNavigationController(rootViewController: searchController)
            navController.navigationBar.isHidden = true
            self.show(navController, sender: self)
        }
    }
    
}
