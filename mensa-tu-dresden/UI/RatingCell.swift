//
//  RatingCell.swift
//  mensa-tu-dresden
//
//  Created by Philipp Matthes on 11.08.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import Material
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class RatingCell: TableViewCell {
    
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var upperLabel: UILabel!
    @IBOutlet weak var lowerLabel: UILabel!
    @IBOutlet weak var userCountLabel: UILabel!
    @IBOutlet weak var upButton: IconButton!
    @IBOutlet weak var downButton: IconButton!
    var separator: UIView!
    
    var rating: Rating!
    
    override func prepare() {
        super.prepare()
        upperLabel?.numberOfLines = 0
        upperLabel?.font = NiceTableViewCell.textLabelFont
        upperLabel?.textColor = .white
        lowerLabel?.numberOfLines = 0
        lowerLabel?.font = NiceTableViewCell.detailTextLabelFont
        lowerLabel?.textColor = .white
        userLabel?.font = RobotoFont.thin(with: 10)
        userLabel?.textColor = .white
        userCountLabel?.font = NiceTableViewCell.textLabelFont
        userCountLabel?.textColor = .white
        if separator == nil {
            separator = UIView()
            separator.backgroundColor = .white
            backgroundView?.layout(separator).bottom().left().right().height(5.0)
        }
    }
    
    func prepareFor(rating: Rating) {
        self.rating = rating
        upperLabel.text = rating.comment
        var stars = ""
        for _ in 0..<rating.stars {
            stars += "★"
        }
        userLabel.text = rating.userName
        lowerLabel.text = stars
        userCountLabel.text = "\(rating.voteCount)"
        backgroundColor = .clear
        pulseColor = .white
        upButton.pulseColor = .white
        downButton.pulseColor = .white
        if let alreadyVoted = rating.alreadyVoted() {
            upButton.tintColor = alreadyVoted == .up ? .white : Colors.backgroundColor
            downButton.tintColor = alreadyVoted == .down ? .white : Colors.backgroundColor
        } else {
            upButton.tintColor = Colors.backgroundColor
            downButton.tintColor = Colors.backgroundColor
        }
        if rating.createdBy == Authentication.user.uid {
            contentView.layer.borderWidth = 2.0
            contentView.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    @IBAction func upButtonPressed(_ sender: Any) {
        rating.vote(.up)
    }
    
    @IBAction func downButtonPressed(_ sender: Any) {
        rating.vote(.down)
    }
    
    
    static let identifier = "RatingCell"
}
