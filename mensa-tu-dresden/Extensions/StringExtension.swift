//
//  StringExtension.swift
//  mensa-tu-dresden
//
//  Created by Philipp Matthes on 10.08.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func generateAttributedString(with searchTerm: String, backgroundColor: UIColor) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        guard
            searchTerm != "",
            let regex = try? NSRegularExpression(pattern: searchTerm.trimmingCharacters(in: .whitespacesAndNewlines).folding(options: .diacriticInsensitive, locale: .current), options: .caseInsensitive)
        else {return attributedString}
        let range = NSRange(location: 0, length: self.utf16.count)
        for match in regex.matches(in: self.folding(options: .diacriticInsensitive, locale: .current), options: .withTransparentBounds, range: range) {
            attributedString.addAttribute(NSAttributedString.Key.backgroundColor, value: backgroundColor, range: match.range)
        }
        return attributedString
    }
    
    func attributed(withBackgroundColor color: UIColor) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        let range = NSRange(location: 0, length: self.utf16.count)
        attributedString.addAttribute(NSAttributedString.Key.backgroundColor, value: color, range: range)
        return attributedString
    }
}
