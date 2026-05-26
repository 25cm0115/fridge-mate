//
//  Recipe.swift
//  Fridge Mate
//
//  Created by cmStudent on 2026/05/19.
//

import Foundation

struct Recipe: Identifiable {
    let id = UUID()
    var name: String
    var requiredIngredients: [String]
    var calories: Int
    var cookingTime: String
    var steps: [String]
    var reason: String
}
