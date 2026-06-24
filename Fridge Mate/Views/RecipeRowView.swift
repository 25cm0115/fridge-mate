//
//  RecipeRowView.swift
//  Fridge Mate
//
//  Created by SURINA.
//

import SwiftUI

struct RecipeRowView: View {
    
    let recipe: Recipe
    @ObservedObject var viewModel: AppViewModel
    
    var missingIngredients: [String] {
        viewModel.missingIngredients(for: recipe)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppTheme.lightGreen)
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: "fork.knife")
                        .font(.title2)
                        .foregroundStyle(AppTheme.green)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(recipe.name)
                        .font(.headline)
                    
                    HStack(spacing: 10) {
                        Label("約\(recipe.calories)kcal", systemImage: "flame")
                        Label(recipe.cookingTime, systemImage: "clock")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            if missingIngredients.isEmpty {
                Text("今ある食材だけで作れます")
                    .font(.caption)
                    .bold()
                    .foregroundStyle(AppTheme.green)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(AppTheme.lightGreen)
                    .cornerRadius(20)
            } else {
                Text("買い足す食材：\(missingIngredients.joined(separator: "、"))")
                    .font(.caption)
                    .bold()
                    .foregroundStyle(AppTheme.orange)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(AppTheme.orange.opacity(0.15))
                    .cornerRadius(20)
            }
        }
        .padding()
        .background(AppTheme.card)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
        .padding(.vertical, 4)
    }
}
