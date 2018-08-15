//
//  AppChipBarController.swift
//  mensa-tu-dresden
//
//  Created by Philipp Matthes on 13.08.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import Material

class AppChipBarController: ChipBarController {
    
    var meal: Meal!
    var tokens: [Token]!
    var likeButton: IconButton!
    var showsTokens = false
    
    override func prepare() {
        super.prepare()
        
        prepareChipBar()
        prepareNavigationBar()
    }
    
    func prepareChipBar() {
        chipBar.delegate = self
        chipBar.chipBarStyle = .auto
        chipBarAlignment = .hidden
    }
    
    func showTokens() {
        let options: NSLinguisticTagger.Options = [.joinNames, .omitWhitespace, .omitPunctuation]
        
        let tagger = NSLinguisticTagger(tagSchemes: NSLinguisticTagger.availableTagSchemes(forLanguage: "de"), options: Int(options.rawValue))
        
        let inputString = meal.name
        tagger.string = inputString
        
        tokens = [Token]()
        
        let range = NSRange(location: 0, length: inputString.utf16.count)
        tagger.enumerateTags(in: range, scheme: .nameTypeOrLexicalClass, options: options) {
            tag, tokenRange, sentenceRange, stop in
            guard
                let range = Range(tokenRange, in: inputString),
                let tag = tag
                else { return }
            let token = String(inputString[range])
            self.tokens.append(Token(text: token, tag: tag))
            let items = tokens.map {$0.chipBarItem()}
            chipBar.chipItems = items
        }
        
        self.chipBarAlignment = .top
        showsTokens = true
    }
    
    func hideTokens() {
        self.chipBarAlignment = .hidden
        showsTokens = false
    }
    
    func prepareNavigationBar() {
        let color = Colors.colorFor(string: self.meal.mensa)
        likeButton = IconButton(image: Icon.cm.star)
        likeButton.tintColor = meal.isTracked() ? color : Colors.backgroundColor
        likeButton.addTarget(self, action: #selector(likeButtonTouched(sender:)), for: .touchUpInside)
        navigationItem.rightViews = [likeButton]
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.tintColor = color
    }
    
    @objc func likeButtonTouched(sender: IconButton) {
        
        let mealIsTracked = meal.isTracked()
        
        if !showsTokens && !mealIsTracked {
            showTokens()
            return
        }

        var alert: UIAlertController
        if mealIsTracked {
            meal.untrack()
            alert = UIAlertController(title: "Entfavorisiert", message: "Du bekommst nun keine Benachrichtigungen mehr zu diesem Gericht.", preferredStyle: .alert)
        } else {
            meal.track(forTokens: tokens)
            alert = UIAlertController(title: "Favorisiert", message: "Du bekommst nun eine Benachrichtigung, wenn dieses Gericht erneut angeboten wird.", preferredStyle: .alert)
        }
        
        sender.tintColor = mealIsTracked ? Colors.backgroundColor : Colors.colorFor(string: meal.mensa)
        
        let action = UIAlertAction(title: "Alles klar", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true)
        hideTokens()
    }
    
}

extension AppChipBarController: ChipBarDelegate {
    func chipBar(chipBar: ChipBar, willSelect chipItem: ChipItem) {
        guard let item = chipItem as? Token.TokenChipItem else {return}
        self.tokens = self.tokens.filter {$0.text != item.token.text}
        chipBar.chipItems = self.tokens.map {$0.chipBarItem()}
    }
}
