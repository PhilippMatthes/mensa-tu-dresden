//
//  MensaController.swift
//  mensa-tu-dresden
//
//  Created by Philipp Matthes on 15.08.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import Material

class MensaController: TableViewController {
    
    var mensas = [Mensa]()
    var filteredMensas = [Mensa]()
    
    var search: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.activityIndicatorView.startAnimating()
        tableView.register(NiceTableViewCell.self, forCellReuseIdentifier: NiceTableViewCell.identifier)
        
        searchBarController?.searchBar.delegate = self
        
        Mensa.all() {
            mensas in
            self.tableView.activityIndicatorView.stopAnimating()
            self.mensas = mensas
            self.filterMensas()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        (searchBarController as? AppSearchBarController)?.setBackButtonIsHidden(true)
    }
    
    @objc func logout() {
        if Authentication.loginType == .anonymous {
            navigationController?.popToRootViewController(animated: true)
        } else {
            Authentication.signOut()
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
        let mensa = filteredMensas[indexPath.row]
        let controller = MealTableController.fromStoryboard(mensa: mensa)
        navigationController?.pushViewController(controller, animated: true)
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
                filteredMensas = mensas.sorted {$0.name < $1.name}
            } else {
                filteredMensas = mensas.filter {$0.name.lowercased().range(of: search) != nil || $0.location.lowercased().range(of: search) != nil}
            }
        } else {
            filteredMensas = mensas.sorted {$0.name < $1.name}
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
