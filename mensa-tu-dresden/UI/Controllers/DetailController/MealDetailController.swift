//
//  MealDetailController.swift
//  mensa-tu-dresden
//
//  Created by Philipp Matthes on 10.08.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import Material
import Alamofire
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class MealDetailController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var upperLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tableView: TableView!
    
    var meal: Meal!
    var ratings = [Rating]()
    var mealDetails: MealDetails?
    
    var ref: DatabaseReference!
    
    static func fromStoryboard(meal: Meal) -> MealDetailController {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let mealController = storyBoard.instantiateViewController(withIdentifier: "MealDetailController") as! MealDetailController
        mealController.meal = meal
        return mealController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(rgb: 0x34495e)
        prepareObserver()
        prepareLabels()
        prepareImage()
        prepareTableView()
        
        guard let link = meal.computedURLString() else {return}
        MealDetails.all(link: link) {
            details in
            self.mealDetails = details
            self.load(details)
            self.downloadImage(url: details.imageSrc)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ratings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RatingCell.identifier) as? RatingCell else {return UITableViewCell()}
        let rating = ratings[indexPath.row]
        cell.prepareFor(rating: rating)
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func load(_ details: MealDetails) {
        DispatchQueue.main.async{
            self.upperLabel.text = "\(details.description)"
        }
    }
    
    func prepareTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = Colors.colorFor(string: meal.mensa)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        heightConstraint.constant = -80
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        heightConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func prepareObserver() {
        ref = MensaDatabase.ratingsReference(meal: meal)
        ref.observe(DataEventType.value) {
            (snapshot) in
            guard
                let dict = snapshot.value as? [String : AnyObject]
            else {return}
            self.ratings = Array(
                dict.map{
                    Rating(value: $0.value, votesReference: self.ref.child($0.key))
                }.compactMap{$0}.sorted{
                    $0.voteCount > $1.voteCount
                }
            )
            DispatchQueue.main.async{
                self.tableView.reloadData()
            }
        }
    }
    
    func prepareLabels() {
        upperLabel.font = RobotoFont.medium(with: 15)
        upperLabel.isUserInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTouched))
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(imageLongPressed(sender:)))
        upperLabel.addGestureRecognizer(tapRecognizer)
        upperLabel.addGestureRecognizer(longPressRecognizer)
    }
    
    func prepareImage() {
        
        let min = CGFloat(-20)
        let max = CGFloat(20)
        
        let yMotion = UIInterpolatingMotionEffect(keyPath: "layer.transform.translation.y", type: .tiltAlongVerticalAxis)
        yMotion.minimumRelativeValue = min
        yMotion.maximumRelativeValue = max
        
        let motionEffectGroup = UIMotionEffectGroup()
        motionEffectGroup.motionEffects = [yMotion]
        
        imageView.addMotionEffect(motionEffectGroup)
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = UIColor(rgb: 0x34495e)
        imageView.isOpaque = true
        imageView.alpha = 0.0
    }
    
    @objc func imageTouched() {
        heightConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func imageLongPressed(sender: UILongPressGestureRecognizer) {
        if (sender.state == .ended) {
            heightConstraint.constant = 0
            UIView.animate(withDuration: 0.3) {
                if let details = self.mealDetails {
                    self.upperLabel.text = "\(details.description)"
                }
                self.imageView.alpha = 0.5
                self.view.layoutIfNeeded()
            }
        } else if (sender.state == .began) {
            heightConstraint.constant = 100
            UIView.animate(withDuration: 0.3) {
                if let details = self.mealDetails {
                    self.upperLabel.text = "\(details.description)\n\(details.prices ?? "Keine Preisangabe")"
                }
                self.imageView.alpha = 0.7
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func nameBar() {
        navigationItem.titleLabel.text = meal.name
        navigationItem.detailLabel.text = meal.mensa
    }
    
    func downloadImage(url: String?) {
        if let url = url, !url.contains("noimage.png") {
            Alamofire.request(url).response {
                response in
                guard let data = response.data else {return}
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.5) {
                        self.imageView.alpha = 0.5
                    }
                    self.imageView.image = UIImage(data: data)
                }
            }
        } else {
            let image = UIImage(named: "mensa-tu-dresden")
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5) {
                    self.imageView.alpha = 0.5
                }
                self.imageView.image = image
            }
        }
    }
    
}
