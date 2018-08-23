//
//  RatingController.swift
//  mensa-tu-dresden
//
//  Created by Philipp Matthes on 11.08.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import Material
import Firebase
import FirebaseStorage
import FirebaseAnalytics
import FirebaseDatabase

class RatingController: UIViewController {
    
    @IBOutlet weak var starButton1: IconButton!
    @IBOutlet weak var starButton2: IconButton!
    @IBOutlet weak var starButton3: IconButton!
    @IBOutlet weak var starButton4: IconButton!
    @IBOutlet weak var starButton5: IconButton!
    @IBOutlet weak var textView: TextView!
    
    var rating: Int?
    var meal: Meal!
    var userSelectedRating = false
    
    @available(iOS 11.0, *) lazy var classificationService: ClassificationService? = { return nil }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.colorFor(string: meal.mensa)
        
        let child = MensaDatabase.ratingsReference(meal: meal).child(Authentication.user.uid)
        self.prepareStars()
        self.prepareTextField()
        self.prepareNavigationBar()
        child.observeSingleEvent(of: DataEventType.value) {
            snapshot in
            guard let value = snapshot.value else {return}
            let dict = value as AnyObject
            guard let rating = Rating(value: dict) else {return}
            DispatchQueue.main.async {
                self.textView.text = rating.comment
                self.setStarRating(rating.stars)
            }
        }
    }
    
    func prepareStars() {
        for button in [starButton1, starButton2, starButton3, starButton4, starButton5] {
            button?.tintColor = Colors.backgroundColor
        }
    }
    
    func prepareTextField() {
        textView.font = RobotoFont.regular(with: 20.0)
        textView.textColor = .white
        textView.delegate = self
    }
    
    func prepareNavigationBar() {        
        let sendButton = IconButton(image: Icon.cm.share)
        sendButton.addTarget(self, action: #selector(sendRating), for: .touchUpInside)
        navigationItem.rightViews = [sendButton]
        navigationController?.navigationBar.tintColor = Colors.colorFor(string: meal.mensa)
    }
    
    @objc func showDonationController() {
        let donationController = DonationController.fromStoryboard()
        donationController.modalPresentationStyle = .overCurrentContext
        present(donationController, animated: true)
    }
    
    static func fromStoryboard() -> RatingController {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        return storyBoard.instantiateViewController(withIdentifier: "RatingController") as! RatingController
    }
    
    func setStarRating(_ rating: Int) {
        let buttons = [starButton1, starButton2, starButton3, starButton4, starButton5]
        for button in buttons {
            button?.tintColor = Colors.backgroundColor
        }
        for i in 0..<rating {
            buttons[i]?.tintColor = .white
        }
        self.rating = rating
    }
    
    @IBAction func starButtonTouched(_ sender: IconButton) {
        userSelectedRating = true
        switch sender {
        case starButton1:
            setStarRating(1)
        case starButton2:
            setStarRating(2)
        case starButton3:
            setStarRating(3)
        case starButton4:
            setStarRating(4)
        case starButton5:
            setStarRating(5)
        default:
            break
        }
    }
    
    @objc func sendRating() {
        if let rating = self.rating, let text = textView.text, text != "" {
            let userName = Authentication.user.displayName ?? "Anonymer Nutzer"
            let postableRating = Rating(stars: rating, comment: text, userName: userName)
            postableRating.publish(aboutMeal: meal)
            navigationController?.popViewController(animated: true)
        } else {
            var alert: UIAlertController
            if rating == nil {
                alert = UIAlertController(title: "Bitte bewerte dein Essen noch.", message: "Das hilft anderen Nutzern dabei, sich zu entscheiden.", preferredStyle: .alert)
            } else {
                alert = UIAlertController(title: "Bitte schreib noch etwas über dein Essen.", message: "Das hilft anderen Nutzern dabei, sich zu entscheiden.", preferredStyle: .alert)
            }
            alert.addAction(UIAlertAction(title: "Alles klar", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
}

extension RatingController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if #available(iOS 11.0, *) {
            if classificationService == nil {
                self.classificationService = ClassificationService()
            }
            guard let text = textView.text else {return}
            classificationService?.predictStars(from: text) {
                prediction in
                if !self.userSelectedRating {
                    self.setStarRating(prediction)
                }
            }
        } else {
            return
        }
    }
}
