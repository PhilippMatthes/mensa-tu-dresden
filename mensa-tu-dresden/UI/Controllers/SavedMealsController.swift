//
//  SavedMealsController.swift
//  mensa-tu-dresden
//
//  Created by Philipp Matthes on 21.08.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import Material

class SavedMealsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var closeButton: IconButton!
    @IBOutlet weak var tableView: TableView!
    
    static func fromStoryboard() -> SavedMealsController {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: "SavedMealsController") as! SavedMealsController
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(NiceTableViewCell.self, forCellReuseIdentifier: NiceTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = closeButton.frame.height / 2
        tableView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        
        let blurEffect = UIBlurEffect(style: .light)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        view.layout(blurredEffectView).top().bottom().left().right()
        blurredEffectView.isUserInteractionEnabled = false
        blurredEffectView.layer.zPosition = -1
        
        closeButton.setImage(Icon.close, for: .normal)
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        closeButton.layer.masksToBounds = true
        closeButton.layer.cornerRadius = closeButton.frame.height / 2
    }
    
    @objc func close() {
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Meal.trackedMeals?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {return}
        Meal.trackedMeals?.remove(at: indexPath.row)
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NiceTableViewCell.identifier) as? NiceTableViewCell else {return UITableViewCell()}
        let meal = Meal.trackedMeals![indexPath.row]
        cell.textLabel?.text = meal.name
        cell.detailTextLabel?.text = "Stichwörter: \((meal.tokens ?? ["keine"]).joined(separator: ", "))"
        cell.backgroundColor = Colors.colorFor(string: meal.mensa)
        return cell
    }
    
}
