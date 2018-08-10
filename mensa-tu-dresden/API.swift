//
//  MensaBase.swift
//  mensa-tu-dresden
//
//  Created by Philipp Matthes on 10.08.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import Alamofire
import Kanna

class API {
    
    static func todaysMeals(completion: @escaping ([Meal]?) -> ()) {
        Alamofire.request("https://www.studentenwerk-dresden.de/mensen/speiseplan/").response {
            response in
            guard
                let data = response.data,
                let html = String(data: data, encoding: .utf8),
                let kannaHtml = try? Kanna.HTML(html: html, encoding: .utf8)
            else {return}
            let mensasHtml = kannaHtml.xpath("//*[@id='spalterechtsnebenmenue']/table")
            var meals = [Meal]()
            for html in mensasHtml {
                guard let mensaName = html.xpath("./thead/tr/th[@class='text']").first?.text else {continue}
                let mealNames = html.xpath("./tbody/tr/td[@class='text']/a").map{$0.content}.compactMap{$0}
                let mensaMeals = mealNames.map {Meal(name: $0, mensa: mensaName)}
                meals.append(contentsOf: mensaMeals)
            }
            completion(meals)
        }
    }
    
}
