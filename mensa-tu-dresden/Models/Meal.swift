//
//  Models.swift
//  mensa-tu-dresden
//
//  Created by Philipp Matthes on 10.08.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage
import FirebaseAnalytics
import FirebaseDatabase
import Material
import Alamofire
import Kanna


struct Meal: Codable, Equatable {
    let name: String
    let mensa: String
    var link: String?
    var dateOrDescription: String?
    var tokens: [String]?
    
    private enum CodingKeys: String, CodingKey {
        case name
        case mensa
        case tokens
    }
    
    static func == (rhs: Meal, lhs: Meal) -> Bool {
        return rhs.mensa == lhs.mensa && rhs.name == lhs.name
    }
    
    private static var trackedMealsCached: [Meal]?
    static var trackedMeals: [Meal]? {
        get {
            if let cached = trackedMealsCached {
                return cached
            }
            guard let data = UserDefaults.standard.object(forKey: "trackedMeals") as? Data else {return nil}
            trackedMealsCached = try? JSONDecoder().decode([Meal].self, from: data)
            return trackedMealsCached
        }
        set {
            trackedMealsCached = newValue
            guard
                let newValue = newValue,
                let data = try? JSONEncoder().encode(newValue)
            else {return}
            UserDefaults.standard.set(data, forKey: "trackedMeals")
        }
    }
    
    func isTracked() -> Bool {
        guard let meals = Meal.trackedMeals else {return false}
        return meals.contains(self)
    }
    
    mutating func track(forTokens tokens: [Token]) {
        self.tokens = tokens.map {$0.text}
        Meal.trackedMeals = (Meal.trackedMeals ?? [Meal]()) + [self]
    }
    
    func untrack() {
        guard let meals = Meal.trackedMeals else {return}
        Meal.trackedMeals = meals.filter {$0 != self}
    }
    
    struct Similarity {
        let meal: Meal
        let score: Double
    }
    
    func highestSimilarityToOneOfStoredMeals() -> Similarity? {
        guard let meals = Meal.trackedMeals else {return nil}
        let filteredMeals = meals.filter{$0.tokens != nil}
        let words = self.name.components(separatedBy: CharacterSet.alphanumerics.inverted).filter {!$0.isEmpty}
        guard
            words.count != 0,
            filteredMeals.count != 0,
            let count = Double(exactly: words.count)
        else {return nil}
        let partialScore = 1.0 / count
        var maxScore = 0.0
        var maxMeal: Meal!
        for meal in filteredMeals {
            var score = 0.0
            for token in meal.tokens! {
                if words.contains(token) {
                    score += partialScore
                }
            }
            if score >= maxScore {
                maxScore = score
                maxMeal = meal
            }
        }
        return Similarity(meal: maxMeal, score: maxScore)
    }
    
    init?(name: String?, mensa: String?, link: String? = nil, dateOrDescription: String? = nil) {
        guard
            let name = name,
            let mensa = mensa
            else {return nil}
        self.name = name
        self.mensa = mensa
        self.link = link
        self.dateOrDescription = dateOrDescription
    }
    
    func computedURLString() -> String? {
        guard
            let link = self.link,
            link != ""
            else {return nil}
        return "https://www.studentenwerk-dresden.de/mensen/speiseplan/\(link)"
    }
    
    static func thisWeek(forMensa mensa: Mensa? = nil, completion: @escaping ([Meal]) -> ()) {
        Alamofire.request(mensa?.mealsUrl ?? "https://www.studentenwerk-dresden.de/mensen/speiseplan/").response {
            response in
            guard
                let data = response.data,
                let html = String(data: data, encoding: .utf8),
                let kannaHtml = try? Kanna.HTML(html: html, encoding: .utf8),
                let title = kannaHtml.xpath("//*[@id='spalterechtsnebenmenue']/h1/a").first?.text
            else {return}
            let mensasHtml = kannaHtml.xpath("//*[@id='spalterechtsnebenmenue']/table")
            var meals = [Meal]()
            if let mensa = mensa, !title.starts(with: "Speiseplan \(mensa.name)") {
                completion(meals)
                return
            }
            for html in mensasHtml {
                guard let dateOrDescription = html.xpath("./thead/tr/th[@class='text']").first?.text else {continue}
                let mensaMeals = html.xpath("./tbody/tr/td[@class='text']/a").map{
                    Meal(name: $0.content, mensa: mensa?.name ?? dateOrDescription, link: $0["href"], dateOrDescription: dateOrDescription)
                }.compactMap{$0}
                meals.append(contentsOf: mensaMeals)
            }
            completion(meals)
        }
    }
}
