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


struct MealDetails {
    let title: String
    let imageSrc: String?
    let description: String
    let prices: String?
    
    static func all(link: String, completion: @escaping (MealDetails) -> ()) {
        Alamofire.request(link).response {
            response in
            guard
                let data = response.data,
                let html = String(data: data, encoding: .utf8),
                let kannaHtml = try? Kanna.HTML(html: html, encoding: .utf8),
                let title = kannaHtml.xpath("//*[@id='speiseplandetails']/h1").first?.text,
                let description = kannaHtml.xpath("//*[@id='speiseplanessentext']").first?.text
            else {return}
            let prices = kannaHtml.xpath("//*[@id='preise']").first?.text
            let src = kannaHtml.xpath("//*[@id='essenfoto']/img").first?["src"] ?? kannaHtml.xpath("//*[@id='essenbild']/img").first?["src"]
            let computedSrc = src != nil ? "https:\(src!)" : nil
            completion(MealDetails(title: title, imageSrc: computedSrc, description: description, prices: prices))
        }
    }
}
