//
//  RecipeDetailView.swift
//  Fridge Mate
//
//  Created by SURINA.
//

import SwiftUI

struct RecipeDetailView: View {
    
    let recipe: Recipe
    @ObservedObject var viewModel: AppViewModel
    
    var missingIngredients: [String] {
        viewModel.missingIngredients(for: recipe)
    }
    
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    headerCard
                    
                    ingredientsCard
                    
                    if !missingIngredients.isEmpty {
                        addShoppingListButton
                    }
                    
                    stepsCard
                    
                    reasonCard
                }
                .padding()
            }
        }
        .navigationTitle("料理詳細")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                ZStack {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(AppTheme.lightGreen)
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "fork.knife.circle.fill")
                        .font(.system(size: 42))
                        .foregroundStyle(AppTheme.green)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(recipe.name)
                        .font(.title2)
                        .bold()
                    
                    Text("冷蔵庫の食材からおすすめ")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            HStack(spacing: 12) {
                infoChip(
                    icon: "flame.fill",
                    title: "カロリー",
                    value: "約\(recipe.calories)kcal"
                )
                
                infoChip(
                    icon: "clock.fill",
                    title: "時間",
                    value: recipe.cookingTime
                )
            }
        }
        .padding()
        .background(AppTheme.card)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 5)
    }
    
    private func infoChip(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(AppTheme.green)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                Text(value)
                    .font(.caption)
                    .bold()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(AppTheme.lightGreen)
        .cornerRadius(16)
    }
    
    private var ingredientsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("使用する食材")
                .font(.headline)
            
            ForEach(recipe.requiredIngredients, id: \.self) { ingredient in
                HStack {
                    Text(ingredient)
                        .font(.subheadline)
                    
                    Spacer()
                    
                    if viewModel.currentIngredientNames.contains(ingredient) {
                        statusBadge(
                            text: "家にある",
                            color: AppTheme.green
                        )
                    } else {
                        statusBadge(
                            text: "買い足す",
                            color: AppTheme.orange
                        )
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(AppTheme.card)
        .cornerRadius(22)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private func statusBadge(text: String, color: Color) -> some View {
        Text(text)
            .font(.caption)
            .bold()
            .foregroundStyle(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(0.15))
            .cornerRadius(20)
    }
    
    private var addShoppingListButton: some View {
        Button {
            viewModel.addMissingIngredientsToShoppingList(for: recipe)
        } label: {
            HStack {
                Image(systemName: "cart.badge.plus")
                Text("足りない食材を買い物リストに追加")
                    .bold()
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
            }
            .padding()
            .foregroundStyle(.white)
            .background(AppTheme.green)
            .cornerRadius(18)
            .shadow(color: AppTheme.green.opacity(0.25), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
    
    private var stepsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("作り方")
                .font(.headline)
            
            ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(index + 1)")
                        .font(.caption)
                        .bold()
                        .foregroundStyle(.white)
                        .frame(width: 26, height: 26)
                        .background(AppTheme.green)
                        .clipShape(Circle())
                    
                    Text(step)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                }
            }
        }
        .padding()
        .background(AppTheme.card)
        .cornerRadius(22)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var reasonCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(AppTheme.orange)
                
                Text("おすすめ理由")
                    .font(.headline)
            }
            
            Text(recipe.reason)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineSpacing(4)
        }
        .padding()
        .background(AppTheme.card)
        .cornerRadius(22)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}
