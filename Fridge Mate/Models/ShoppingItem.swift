//
//  ShoppingItem.swift
//  Fridge Mate
//
//  Created by cmStudent on 2026/05/19.
//

import Foundation

struct ShoppingItem: Identifiable {
    let id = UUID()
    var name: String
    var isChecked: Bool = false
}
