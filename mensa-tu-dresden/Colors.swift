//
//  Colors.swift
//  mensa-tu-dresden
//
//  Created by Philipp Matthes on 10.08.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit
import Material

class Colors {
    static let all = [
        UIColor(rgb: 0xeb3b5a),
        UIColor(rgb: 0xfa8231),
        UIColor(rgb: 0xf7b731),
        UIColor(rgb: 0x20bf6b),
        UIColor(rgb: 0x0fb9b1),
        UIColor(rgb: 0x45aaf2),
        UIColor(rgb: 0x4b7bec),
        UIColor(rgb: 0xa55eea),
    ]
    
    static func colorFor(tag: NSLinguisticTag) -> UIColor {
        var index = 0
        switch tag {
            case _ where [
                NSLinguisticTag.adjective,
            ].contains(tag):
                index = 1
            
            case _ where [
                NSLinguisticTag.adverb,
                NSLinguisticTag.preposition,
                NSLinguisticTag.pronoun,
            ].contains(tag):
                index = 2
            
            case _ where [
                NSLinguisticTag.classifier,
                NSLinguisticTag.dash,
                NSLinguisticTag.determiner,
                NSLinguisticTag.number,
            ].contains(tag):
                index = 3
            
            case _ where [
                NSLinguisticTag.idiom,
                NSLinguisticTag.interjection,
            ].contains(tag):
                index = 4
            
            case _ where [
                NSLinguisticTag.noun,
            ].contains(tag):
                index = 5
                
            case _ where [
                NSLinguisticTag.organizationName,
                NSLinguisticTag.personalName,
                NSLinguisticTag.placeName,
            ].contains(tag):
                index = 6
            
            case _ where [
                NSLinguisticTag.verb,
            ].contains(tag):
                index = 7
            
            default:
                index = 8
        }
        return all[index % all.count]
    }
    
    static let backgroundColor = UIColor(rgb: 0x34495e)
    static let redColor = UIColor(rgb: 0xFF4757)
    
    static func colorFor(string: String?) -> UIColor {
        guard let string = string else {return all.first!}
        return all[string.count % all.count]
    }
}
