//
//  MensaController.swift
//  mensa-tu-dresden
//
//  Created by Philipp Matthes on 15.08.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import Material

class MensaController: TableViewController, DonationDelegate {
    
    var mensas = [Mensa]()
    var filteredMensas = [Mensa]()
    
    var heart: IconButton!
    
    var search: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareSearchBar()
        
        tableView.register(NiceTableViewCell.self, forCellReuseIdentifier: NiceTableViewCell.identifier)
        
        searchBarController?.searchBar.delegate = self
        
        Mensa.all() {
            mensas in
            self.mensas = mensas
            self.filterMensas()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NiceTableViewCell.identifier) as? NiceTableViewCell else {return UITableViewCell()}
        let mensa = filteredMensas[indexPath.row]
        cell.textLabel?.text = mensa.name
        cell.detailTextLabel?.text = mensa.location
        cell.backgroundColor = Colors.colorFor(string: mensa.name)
        cell.pulseColor = .white
        if let search = self.search {
            cell.highlight(search: search)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMensas.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mensa = mensas[indexPath.row]
        let controller = MealTableController.fromStoryboard(mensa: mensa)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func prepareSearchBar() {
        guard let searchBar = searchBarController?.searchBar else {return}
        searchBar.delegate = self
        
        let icon = IconButton(image: Icon.cm.search)
        icon.addTarget(self, action: #selector(toggleSearchBar), for: .touchUpInside)
        icon.tintColor = Colors.backgroundColor
        
        heart = IconButton(image: Icon.favorite)
        heart.addTarget(self, action: #selector(showDonationController), for: .touchUpInside)
        heart.tintColor = Colors.loveButtonColor
        
        searchBar.leftViews = [icon]
        searchBar.rightViews = [heart]
    }
    
    @objc func showDonationController() {
        let donationController = DonationController.fromStoryboard()
        donationController.modalPresentationStyle = .overCurrentContext
        donationController.delegate = self
        present(donationController, animated: true)
    }
    
    func didDonate() {
        heart.tintColor = Colors.loveButtonColor
    }
    
    @objc func toggleSearchBar() {
        if searchBarController?.searchBar.textField.isFirstResponder ?? false {
            searchBarController?.searchBar.endEditing(true)
        } else {
            searchBarController?.searchBar.textField.becomeFirstResponder()
        }
    }
}

extension MensaController: SearchBarDelegate {
    func searchBar(searchBar: SearchBar, didChange textField: UITextField, with text: String?) {
        guard let text = text?.lowercased() else {return}
        self.search = text
        filterMensas()
    }
    
    func filterMensas() {
        if let search = self.search {
            if search == "" {
                filteredMensas = mensas
            } else {
                filteredMensas = mensas.filter {$0.name.lowercased().range(of: search) != nil || $0.location.lowercased().range(of: search) != nil}
            }
        } else {
            filteredMensas = mensas
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func searchBar(searchBar: SearchBar, didClear textField: UITextField, with text: String?) {
        self.search = nil
        filterMensas()
    }
}
