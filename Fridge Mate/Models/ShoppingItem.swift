//
//  ShoppingItem.swift
//  Fridge Mate
//
//  Created by SURINA.
//

import Foundation

struct ShoppingItem: Identifiable {
    let id = UUID()
    var name: String
    var isChecked: Bool = false
}
