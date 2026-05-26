//
//  RecipeView.swift
//  Fridge Mate
//
//  Created by cmStudent on 2026/05/19.
//

import SwiftUI

struct RecipeView: View {
    
    @ObservedObject var viewModel: AppViewModel
    @State private var selectedMode: RecipeMode = .useCurrentIngredients
    
    enum RecipeMode: String, CaseIterable, Identifiable {
        case useCurrentIngredients = "今ある食材だけ"
        case buyMoreIngredients = "少し買い足す"
        
        var id: String { rawValue }
    }
    
    var suggestedRecipes: [Recipe] {
        switch selectedMode {
        case .useCurrentIngredients:
            return viewModel.recipesUsingCurrentIngredientsOnly()
        case .buyMoreIngredients:
            return viewModel.recipesWithBuyingMoreIngredients()
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Picker("モード", selection: $selectedMode) {
                        ForEach(RecipeMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    if suggestedRecipes.isEmpty {
                        NotEnoughIngredientsView()
                    } else {
                        ScrollView {
                            VStack(spacing: 14) {
                                ForEach(suggestedRecipes) { recipe in
                                    NavigationLink {
                                        RecipeDetailView(
                                            recipe: recipe,
                                            viewModel: viewModel
                                        )
                                    } label: {
                                        RecipeRowView(
                                            recipe: recipe,
                                            viewModel: viewModel
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom)
                        }
                    }
                }
            }
            .navigationTitle("レシピ提案")
        }
    }
}
