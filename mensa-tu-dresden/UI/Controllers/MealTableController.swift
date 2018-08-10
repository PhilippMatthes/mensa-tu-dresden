//
//  MealTableController.swift
//  mensa-tu-dresden
//
//  Created by Philipp Matthes on 10.08.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import Material

class MealTableController: TableViewController {
    
    var meals = [Meal]()
    var filteredMeals = [Meal]()
    var search: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareNavigationBar()
        prepareSearchBar()
        tableView.register(NiceTableViewCell.self, forCellReuseIdentifier: NiceTableViewCell.identifier)
        API.todaysMeals() {
            meals in
            guard let meals = meals else {return}
            self.meals = meals
            self.filteredMeals = meals
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMeals.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NiceTableViewCell.identifier) as? NiceTableViewCell else {return UITableViewCell()}
        let meal = filteredMeals[indexPath.row]
        cell.textLabel?.text = meal.name
        cell.detailTextLabel?.text = meal.mensa
        cell.backgroundColor = Colors.colorFor(string: meal.mensa)
        if let search = self.search {
            cell.highlight(search: search)
        }
        return cell
    }
    
    func prepareNavigationBar() {
        navigationItem.titleLabel.text = "Essensangebot"
    }
    
    func prepareSearchBar() {
        guard let searchBar = searchBarController?.searchBar else {return}
        searchBar.delegate = self
        
        let icon = IconButton(image: Icon.cm.search)
        icon.addTarget(self, action: #selector(toggleSearchBar), for: .touchUpInside)
        searchBar.leftViews = [icon]
    }
    
    @objc func toggleSearchBar() {
        if searchBarController?.searchBar.textField.isFirstResponder ?? false {
            searchBarController?.searchBar.endEditing(true)
        } else {
            searchBarController?.searchBar.textField.becomeFirstResponder()
        }
    }
    
}

extension MealTableController: SearchBarDelegate {
    func searchBar(searchBar: SearchBar, didChange textField: UITextField, with text: String?) {
        guard let text = text?.lowercased() else {return}
        self.search = text
        if text == "" {
            filteredMeals = meals
        } else {
            filteredMeals = meals.filter {$0.name.lowercased().range(of: text) != nil || $0.mensa.lowercased().range(of: text) != nil}
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func searchBar(searchBar: SearchBar, didClear textField: UITextField, with text: String?) {
        filteredMeals = meals
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
