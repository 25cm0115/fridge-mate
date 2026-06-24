//
//  Ingredient.swift.swift
//  Fridge Mate
//
//  Created by SURINA.
//

import Foundation

enum IngredientCategory: String, CaseIterable, Identifiable {
    case vegetable = "野菜"
    case meat = "肉"
    case seafood = "魚介"
    case egg = "卵・乳製品"
    case staple = "主食"
    case seasoning = "調味料"
    case other = "その他"
    
    var id: String { rawValue }
}

struct Ingredient: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var amount: String
    var daysLeft: Int
    var category: IngredientCategory = .other
}
