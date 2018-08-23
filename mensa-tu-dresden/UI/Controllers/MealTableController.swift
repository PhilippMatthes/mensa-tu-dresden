//
//  MealTableController.swift
//  mensa-tu-dresden
//
//  Created by Philipp Matthes on 10.08.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import Material
import FlyoverKit
import FirebaseAuth
import MapKit

class MealTableController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: TableView!
    
    @IBOutlet weak var button: FlatButton!
    @IBOutlet weak var buttonHeight: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    
    var meals = [Meal]()
    var filteredMeals = [Meal]()
    var search: String?
    var mensa: Mensa!
    
    private var requestHasCompleted = false
    private var hasMeals: Bool {
        return filteredMeals.count != 0
    }
    
    var annotation: MKAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareFlyOverMapView()
        prepareTableView()
        prepareNavigationBar()
        
        searchBarController?.searchBar.delegate = self
        
        Meal.thisWeek(forMensa: mensa) {
            meals in
            self.requestHasCompleted = true
            self.meals = meals
            self.filteredMeals = meals
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    static func fromStoryboard(mensa: Mensa) -> AppSearchBarController {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let mealController = storyBoard.instantiateViewController(withIdentifier: "MealTableController") as! MealTableController
        mealController.mensa = mensa
        let searchController = AppSearchBarController(rootViewController: mealController, tintColor: Colors.colorFor(string: mensa.name))
        return searchController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        (searchBarController as? AppSearchBarController)?.setBackButtonIsHidden(false)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hasMeals ? filteredMeals.count : 1
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NiceTableViewCell.identifier) as? NiceTableViewCell else {return UITableViewCell()}
        
        if !requestHasCompleted {
            cell.textLabel?.text = "Lade Angebote..."
            cell.detailTextLabel?.text = "Es könnten trotzdem Angebote verfügbar sein. Bitte informieren Sie sich auf der Website des Studentenwerks!"
        } else if !hasMeals {
            cell.textLabel?.text = "Kein Angebot gefunden."
            cell.detailTextLabel?.text = "Es könnten trotzdem Angebote verfügbar sein. Bitte informieren Sie sich auf der Website des Studentenwerks!"
        } else {
            let meal = filteredMeals[indexPath.row]
            cell.textLabel?.text = meal.name
            cell.detailTextLabel?.text = meal.dateOrDescription
        }
        cell.backgroundColor = Colors.colorFor(string: mensa.name)
        cell.pulseColor = .white

        if let search = self.search {
            cell.highlight(search: search)
        }
        return cell
    }
    
    func prepareFlyOverMapView() {
        
        button.titleColor = Colors.colorFor(string: mensa.name)
        button.titleLabel?.font = RobotoFont.bold(with: 15.0)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(mapViewTouched))
        mapView.addGestureRecognizer(tapRecognizer)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(mapViewLongPressed(sender:)))
        mapView.addGestureRecognizer(longPressRecognizer)
        
        mensa.annotation() {
            annotation, address in
            self.annotation = annotation
            self.mapView.addAnnotation(annotation)
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
            self.mapView.showsCompass = false
            
            if #available(iOS 10.0, *) {
                let camera = FlyoverCamera(mapView: self.mapView, configuration: FlyoverCamera.Configuration(duration: 4.0, altitude: 300, pitch: 45.0, headingStep: 20.0))
                camera.start(flyover: annotation.coordinate)
            }
            self.heightConstraint.constant = Screen.height * 0.3
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
            if Connection.connectedToWifi() {
                self.mapView.mapType = .hybridFlyover
                self.mapView.showsBuildings = true
            } else {
                self.mapView.mapType = .standard
                self.mapView.showsBuildings = false
            }
        }
    }
    
    func prepareNavigationBar() {
        navigationItem.titleLabel.text = "Essensangebot"
    }
    
    func prepareTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NiceTableViewCell.self, forCellReuseIdentifier: NiceTableViewCell.identifier)
    }
    
    @objc func mapViewLongPressed(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            self.heightConstraint.constant = annotation == nil ? 0 : Screen.height * 0.6
            self.button.isHidden = false
            self.buttonHeight.constant = 50
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard hasMeals else {return}
        let meal = filteredMeals[indexPath.row]
        let mealDetailController = MealDetailController.fromStoryboard(meal: meal)
        let fabMenuController = AppFABMenuController(rootViewController: mealDetailController)
        let chipBarController = AppChipBarController(rootViewController: fabMenuController)
        chipBarController.meal = meal
        fabMenuController.meal = meal
        navigationController?.pushViewController(chipBarController, animated: true)
    }
    
    @IBAction func showInMaps(_ sender: Any) {
        guard let annotation = annotation else {return}
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: annotation.coordinate, addressDictionary: nil))
        mapItem.name = mensa.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
}

extension MealTableController: SearchBarDelegate {
    func searchBar(searchBar: SearchBar, didChange textField: UITextField, with text: String?) {
        guard let text = text?.lowercased() else {return}
        self.search = text
        if text == "" {
            filteredMeals = meals
        } else {
            filteredMeals = meals.filter {$0.name.lowercased().range(of: text) != nil || $0.dateOrDescription?.lowercased().range(of: text) != nil}
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

extension MealTableController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.heightConstraint.constant = annotation == nil ? 0 : Screen.height * 0.2
        self.button.isHidden = true
        self.buttonHeight.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func mapViewTouched() {
        self.heightConstraint.constant = annotation == nil ? 0 : Screen.height * 0.3
        self.button.isHidden = true
        self.buttonHeight.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    
}
