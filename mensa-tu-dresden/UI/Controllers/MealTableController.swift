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
import MapKit

class MealTableController: UIViewController, UITableViewDataSource, UITableViewDelegate, DonationDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: TableView!
    
    @IBOutlet weak var button: FlatButton!
    @IBOutlet weak var buttonHeight: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    var heart: IconButton!
    
    var meals = [Meal]()
    var filteredMeals = [Meal]()
    var search: String?
    var mensa: Mensa!
    
    var annotation: MKAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareFlyOverMapView()
        prepareSearchBar()
        prepareTableView()
        prepareNavigationBar()
        Meal.thisWeek(forMensa: mensa) {
            meals in
            self.meals = meals
            self.filteredMeals = meals
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    static func fromStoryboard(mensa: Mensa) -> SearchBarController {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let mealController = storyBoard.instantiateViewController(withIdentifier: "MealTableController") as! MealTableController
        mealController.mensa = mensa
        let searchController = SearchBarController(rootViewController: mealController)
        searchController.searchBar.placeholder = "Suchen"
        return searchController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMeals.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NiceTableViewCell.identifier) as? NiceTableViewCell else {return UITableViewCell()}
        let meal = filteredMeals[indexPath.row]
        cell.textLabel?.text = meal.name
        cell.detailTextLabel?.text = meal.dateOrDescription
        cell.backgroundColor = Colors.colorFor(string: meal.mensa)
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
            annotation in
            self.annotation = annotation
            self.mapView.addAnnotation(annotation)
            self.mapView.showAnnotations([annotation], animated: true)
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
    
    func prepareSearchBar() {
        guard let searchBar = searchBarController?.searchBar else {return}
        searchBar.delegate = self
        
        searchBar.placeholder = "Suchen"
        
        let icon = IconButton(image: Icon.cm.search)
        icon.addTarget(self, action: #selector(toggleSearchBar), for: .touchUpInside)
        icon.tintColor = Colors.colorFor(string: mensa.name)
        
        heart = IconButton(image: Icon.favorite)
        heart.addTarget(self, action: #selector(showDonationController), for: .touchUpInside)
        heart.tintColor = Colors.loveButtonColor
        
        let backicon = IconButton(image: Icon.cm.arrowBack)
        backicon.addTarget(self, action: #selector(back), for: .touchUpInside)
        backicon.tintColor = Colors.colorFor(string: mensa.name)
        
        searchBar.rightViews = [icon, heart]
        searchBar.leftViews = [backicon]
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
    
    func prepareTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NiceTableViewCell.self, forCellReuseIdentifier: NiceTableViewCell.identifier)
    }
    
    @objc func back() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func toggleSearchBar() {
        if searchBarController?.searchBar.textField.isFirstResponder ?? false {
            searchBarController?.searchBar.endEditing(true)
        } else {
            searchBarController?.searchBar.textField.becomeFirstResponder()
        }
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
