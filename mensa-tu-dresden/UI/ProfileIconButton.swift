//
//  ProfileIconButton.swift
//  mensa-tu-dresden
//
//  Created by Philipp Matthes on 18.08.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import Material
import Alamofire
import MIBadgeButton_Swift

import UIKit

class ProfileIconButton: MIBadgeButton {
    
    func prepareProfilePic(url: URL?, withLove love: Bool) {
        setImage(Icon.favorite, for: .normal)
        tintColor = Colors.loveButtonColor
        imageView?.layer.cornerRadius = self.frame.height / 2
        imageView?.layer.masksToBounds = true
        if let url = url {
            Alamofire.request(url).responseData {
                response in
                guard
                    let data = response.data,
                    let image = UIImage(data: data)
                    else {return}
                self.setImage(image, for: .normal)
                self.imageView?.layer.cornerRadius = self.frame.height / 2
                self.imageView?.layer.masksToBounds = true
                if love {
                    DispatchQueue.main.async {
                        self.badgeString = "♥"
                        self.badgeEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 0, right: 0)
                        self.badgeAnchor = .TopLeft(topOffset: 0.0, leftOffset: 0.0)
                        self.badgeTextColor = Colors.redColor
                        self.badgeBackgroundColor = .clear
                    }
                }
            }
        }
    }
    
    func update() {
        self.badgeTextColor = Colors.loveButtonColor
        self.tintColor = Colors.loveButtonColor
    }
    
}
