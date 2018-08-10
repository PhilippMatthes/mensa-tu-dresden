//
//  NiceTableViewCell.swift
//  mensa-tu-dresden
//
//  Created by Philipp Matthes on 10.08.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import Material

class NiceTableViewCell: TableViewCell {
    
    static let identifier = "NiceTableViewCell"
    
    static let textLabelFont = RobotoFont.medium(with: 16.0)
    static let detailTextLabelFont = RobotoFont.light(with: 15.0)
    static let highlightedBackgroundColor = UIColor(rgb: 0x34495e)
    
    override func prepare() {
        super.prepare()
        textLabel?.numberOfLines = 0
        textLabel?.font = NiceTableViewCell.textLabelFont
        textLabel?.textColor = .white
        detailTextLabel?.numberOfLines = 0
        detailTextLabel?.font = NiceTableViewCell.detailTextLabelFont
        detailTextLabel?.textColor = .white
    }
    
    func highlight(search: String) {
        textLabel?.attributedText = textLabel?.text?.generateAttributedString(with: search, backgroundColor: NiceTableViewCell.highlightedBackgroundColor)
        detailTextLabel?.attributedText = detailTextLabel?.text?.generateAttributedString(with: search, backgroundColor: NiceTableViewCell.highlightedBackgroundColor)
    }
    
}
