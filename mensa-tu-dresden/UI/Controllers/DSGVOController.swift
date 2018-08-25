//
//  DSGVOController.swift
//  mensa-tu-dresden
//
//  Created by Philipp Matthes on 25.08.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import Material


class DSGVOController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    var tableView: TableView!
    var acceptButton: FlatButton!
    var titleLabel: UILabel!
    
    private var conditions = [
        "● Zur Identifikation deines Geräts wird diesem ein einzigartiger Schlüssel zugeordnet und auf Servern gespeichert.",
        "● Alle Bewertungen und Kommentare, die du über diese App veröffentlichst, werden auf Servern gespeichert und können Dritten zur Verfügung gestellt werden.",
        "● Alle \"Up-\" oder \"Downvotes\", die du gibst, werden auf Servern gespeichert und können Dritten zur Verfügung gestellt werden.",
        "Datenschutzvereinbarung: https://philippmatth.es/data/"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        prepareTitleLabel()
        prepareTableView()
        prepareAcceptButton()
    }
    
    private func prepareTitleLabel() {
        titleLabel = UILabel()
        titleLabel.text = "Das passiert mit deinen Daten, wenn du diese App nutzt:"
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .black
        titleLabel.font = RobotoFont.regular(with: 20)
        titleLabel.textAlignment = .center
        view.layout(titleLabel).top(42).left(12).right(12)
    }
    
    private func prepareTableView() {
        tableView = TableView()
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "TableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        view.layout(tableView).top(100).bottom(42).left().right()
    }
    
    private func prepareAcceptButton() {
        acceptButton = FlatButton(title: "Ich habe alle Punkte und die Datenschutzvereinbarung gelesen und akzeptiere.", titleColor: .white)
        acceptButton.titleLabel?.numberOfLines = 0
        acceptButton.addTarget(self, action: #selector(accept), for: .touchUpInside)
        acceptButton.backgroundColor = Colors.redColor
        acceptButton.titleLabel?.font = RobotoFont.regular(with: 15)
        view.layout(acceptButton).bottom(12).left(12).right(12).height(84)
    }
    
    @objc func accept() {
        present(LoginController.fromStoryboard(), animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as? TableViewCell else {return UITableViewCell()}
        
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.font = RobotoFont.regular(with: 15)
        cell.textLabel?.attributedText = conditions[indexPath.row].generateAttributedString(with: "https://philippmatth.es/data/", backgroundColor: Color.grey.lighten2)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conditions.count
    }
    
}
