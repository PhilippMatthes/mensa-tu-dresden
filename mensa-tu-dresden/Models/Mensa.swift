//
//  Mensa.swift
//  mensa-tu-dresden
//
//  Created by Philipp Matthes on 15.08.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage
import FirebaseAnalytics
import FirebaseDatabase
import Material
import MapKit
import Alamofire
import Kanna

struct Mensa {
    let internalUrl: String
    let name: String
    let location: String
    
    var detailsUrl: String {
        get {
            return "https://www.studentenwerk-dresden.de/mensen/details-\(internalUrl).html"
        }
    }
    
    var mealsUrl: String {
        get {
            return "https://www.studentenwerk-dresden.de/mensen/speiseplan/\(internalUrl).html"
        }
    }
    
    func annotation(completion: @escaping (MKAnnotation, String) -> ()) {
        location() {
            location, address in
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            annotation.title = self.name
            annotation.subtitle = address
            completion(annotation, address)
        }
    }
    
    func location(completion: @escaping (CLLocation, String) -> ()) {
        Alamofire.request(detailsUrl).response {
            response in
            guard
                let data = response.data,
                let html = String(data: data, encoding: .utf8),
                let kannaHtml = try? Kanna.HTML(html: html, encoding: .utf8)
            else {return}
            let address = kannaHtml.xpath("//*[@id='mensadetailslinks']/text()")
                .map{$0.text}
                .compactMap{$0}
                .filter{$0 != "\n"}
                .joined(separator: " ")
            print(address)
            CLGeocoder().geocodeAddressString(address) {
                placemarks, error in
                guard
                    let location = placemarks?.first?.location
                else {return}
                completion(location, address)
            }
        }
    }
    
    static func all(completion: @escaping ([Mensa]) ->()) {
        Alamofire.request("https://www.studentenwerk-dresden.de/mensen/mensen_cafeterien.html").response {
            response in
            guard
                let data = response.data,
                let html = String(data: data, encoding: .utf8),
                let kannaHtml = try? Kanna.HTML(html: html, encoding: .utf8)
            else {return}
            let mensasHtml = kannaHtml.xpath("//*[@id='spalterechtsnebenmenue']/table/tbody/tr")
            var mensas = [Mensa]()
            for html in mensasHtml {
                guard
                    let mensaName = html.xpath("./td[@class='text']").first?.text,
                    let mensaDetailUrl = html.xpath("./td/a[@title='Infos']").first?["href"],
                    let mensaDetailLocation = html.xpath("./td[2]").first?.text
                else {return}
                let mensaInternal = mensaDetailUrl
                    .replacingOccurrences(of: "details-", with: "")
                    .replacingOccurrences(of: ".html", with: "")
                mensas.append(Mensa(internalUrl: mensaInternal, name: mensaName, location: mensaDetailLocation))
            }
            completion(mensas)
        }
    }
}
