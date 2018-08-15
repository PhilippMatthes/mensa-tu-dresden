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


struct Token {
    let text: String
    let tag: NSLinguisticTag
    
    func chipBarItem() -> Token.TokenChipItem {
        let item = TokenChipItem(title: "\(text)   ")
        item.token = self
        item.titleLabel?.isUserInteractionEnabled = false
        item.backgroundColor = Colors.colorFor(tag: tag)
        item.titleColor = .white
        item.pulseColor = .white
        let crossButton = IconButton(image: Icon.cm.close)
        crossButton.tintColor = .white
        crossButton.isUserInteractionEnabled = false
        item.layout(crossButton).right(5).centerVertically().height(18).width(18)
        return item
    }
    
    class TokenChipItem: ChipItem {
        
        var token: Token!
        
    }
    
}
