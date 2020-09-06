//
//  NetworkingService.swift
//  MobileCocktail
//
//  Created by Владислав on 9/5/20.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation


struct Result: Decodable {
    var drinks: [Category]
}

struct Category: Decodable {
    var strCategory: String
    var selectCat: Bool?
}

struct AllDrinks: Codable {
    let drinks: [Drink]
    var nameCategory: String?
}

struct Drink: Codable {
    let strDrink: String
    let strDrinkThumb: String
    let idDrink: String
}
