//
//  AppSearchbarController.swift
//  mensa-tu-dresden
//
//  Created by Philipp Matthes on 18.08.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation

import Material

typealias DonationDelegateViewController = UIViewController

class AppSearchBarController: SearchBarController {
    var tintColor: UIColor!
    
    var backIcon: IconButton!
    var searchIcon: IconButton!
    var savedMealsButton: SavedMealsButton!
    var heartIconButton: ProfileIconButton!
    
    init(rootViewController: UIViewController, tintColor: UIColor) {
        self.tintColor = tintColor
        super.init(rootViewController: rootViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareSearchBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        heartIconButton.update()
        savedMealsButton.updateBadge()
    }
    
    func prepareSearchBar() {
        searchBar.placeholder = "Suchen"
        
        searchIcon = IconButton(image: Icon.cm.search)
        searchIcon.addTarget(self, action: #selector(toggleSearchBar), for: .touchUpInside)
        searchIcon.tintColor = self.tintColor
        
        savedMealsButton = SavedMealsButton(type: .custom)
        savedMealsButton.prepare(forTintColor: self.tintColor)
        savedMealsButton.addTarget(self, action: #selector(showSavedMealsController), for: .touchUpInside)
        
        heartIconButton = ProfileIconButton(type: .custom)
        heartIconButton.prepareProfilePic(url: Authentication.user.photoURL, withLove: Donation.userHasDonated)
        heartIconButton.addTarget(self, action: #selector(showDonationController), for: .touchUpInside)
        
        backIcon = IconButton(image: Icon.cm.arrowBack)
        backIcon.addTarget(self, action: #selector(back), for: .touchUpInside)
        backIcon.tintColor = self.tintColor
        
        searchBar.rightViews = [heartIconButton, savedMealsButton]
        searchBar.leftViews = [backIcon, searchIcon]
    }
    
    func setBackButtonIsHidden(_ hidden: Bool) {
        backIcon.isHidden = hidden
        searchBar.leftViews = hidden ? [searchIcon] : [backIcon, searchIcon]
    }
    
    @objc func showDonationController() {
        let donationController = DonationController.fromStoryboard()
        donationController.modalPresentationStyle = .overCurrentContext
        present(donationController, animated: true)
    }
    
    @objc func toggleSearchBar() {
        if searchBarController?.searchBar.textField.isFirstResponder ?? false {
            searchBarController?.searchBar.endEditing(true)
        } else {
            searchBarController?.searchBar.textField.becomeFirstResponder()
        }
    }
    
    @objc func showSavedMealsController() {
        let savedMealsController = SavedMealsController.fromStoryboard()
        savedMealsController.modalPresentationStyle = .overCurrentContext
        present(savedMealsController, animated: true)
    }
    
    @objc func back() {
        navigationController?.popViewController(animated: true)
    }
    
}
