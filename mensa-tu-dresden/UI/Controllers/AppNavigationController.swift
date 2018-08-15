//
//  AppNavigationController.swift
//  mensa-tu-dresden
//
//  Created by Philipp Matthes on 10.08.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import Material

class AppNavigationController: NavigationController {
    open override func prepare() {
        super.prepare()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}
