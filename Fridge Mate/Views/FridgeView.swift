//
//  FridgeView.swift
//  Fridge Mate
//
//  Created by cmStudent on 2026/05/19.
//

import SwiftUI

struct FridgeView: View {
    
    @ObservedObject var viewModel: AppViewModel
    @State private var showAddSheet = false
    @State private var selectedCategory: IngredientCategory?
    
    var filteredIngredients: [Ingredient] {
        if let selectedCategory {
            return viewModel.ingredients.filter { $0.category == selectedCategory }
        } else {
            return viewModel.ingredients
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        headerView
                        
                        scanButton
                        
                        categoryFilterSection
                        
                        if !viewModel.nearExpirationIngredients.isEmpty {
                            nearExpirationSection
                        }
                        
                        allIngredientsSection
                    }
                    .padding()
                }
            }
            .navigationTitle("冷蔵庫")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(8)
                            .background(AppTheme.green)
                            .clipShape(Circle())
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddIngredientView(viewModel: viewModel)
            }
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("今日の冷蔵庫")
                .font(.title2)
                .bold()
            
            Text("消費期限が近い食材を優先して使いましょう")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    private var scanButton: some View {
        Button {
            // 今後カメラ機能を追加する予定
        } label: {
            HStack {
                Image(systemName: "camera.fill")
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("冷蔵庫をスキャン")
                        .font(.headline)
                    
                    Text("AIで食材を自動認識する予定")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(AppTheme.card)
            .cornerRadius(18)
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
    
    private var categoryFilterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("分類")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    categoryFilterButton(title: "すべて", category: nil)
                    
                    ForEach(IngredientCategory.allCases) { category in
                        categoryFilterButton(
                            title: category.rawValue,
                            category: category
                        )
                    }
                }
            }
        }
    }
    
    private func categoryFilterButton(title: String, category: IngredientCategory?) -> some View {
        let isSelected = selectedCategory == category
        
        return Button {
            selectedCategory = category
        } label: {
            Text(title)
                .font(.caption)
                .bold()
                .foregroundStyle(isSelected ? .white : AppTheme.green)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? AppTheme.green : AppTheme.card)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
    
    private var nearExpirationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("消費期限が近い食材")
                .font(.headline)
            
            ForEach(viewModel.nearExpirationIngredients) { ingredient in
                HStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(AppTheme.orange)
                        .font(.title3)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(ingredient.name)
                            .font(.headline)
                        
                        Text("\(ingredient.amount) ・ \(ingredient.category.rawValue)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("あと\(ingredient.daysLeft)日")
                        .font(.caption)
                        .bold()
                        .foregroundStyle(AppTheme.orange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppTheme.orange.opacity(0.15))
                        .cornerRadius(20)
                }
                .padding()
                .background(AppTheme.card)
                .cornerRadius(18)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
            }
        }
    }
    
    private var allIngredientsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("すべての食材")
                    .font(.headline)
                
                Spacer()
                
                Text("\(filteredIngredients.count)件")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if filteredIngredients.isEmpty {
                emptyIngredientView
            } else {
                VStack(spacing: 12) {
                    ForEach(filteredIngredients) { ingredient in
                        ingredientCard(ingredient)
                    }
                }
            }
        }
    }
    
    private var emptyIngredientView: some View {
        VStack(spacing: 10) {
            Image(systemName: "tray")
                .font(.system(size: 34))
                .foregroundStyle(.secondary)
            
            Text("この分類の食材はありません")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppTheme.card)
        .cornerRadius(18)
    }
    
    private func ingredientCard(_ ingredient: Ingredient) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(AppTheme.lightGreen)
                    .frame(width: 52, height: 52)
                
                Image(systemName: categoryIcon(for: ingredient.category))
                    .foregroundStyle(AppTheme.green)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(ingredient.name)
                        .font(.headline)
                    
                    Text(ingredient.category.rawValue)
                        .font(.caption2)
                        .bold()
                        .foregroundStyle(AppTheme.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppTheme.lightGreen)
                        .cornerRadius(12)
                }
                
                Text(ingredient.amount)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                Text("あと\(ingredient.daysLeft)日")
                    .font(.caption)
                    .foregroundStyle(viewModel.expirationColor(days: ingredient.daysLeft))
                
                Button {
                    viewModel.deleteIngredient(id: ingredient.id)
                } label: {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(8)
                        .background(Color.red.opacity(0.10))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(AppTheme.card)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private func categoryIcon(for category: IngredientCategory) -> String {
        switch category {
        case .vegetable:
            return "leaf.fill"
        case .meat:
            return "fork.knife"
        case .seafood:
            return "fish.fill"
        case .egg:
            return "circle.grid.2x2.fill"
        case .staple:
            return "takeoutbag.and.cup.and.straw.fill"
        case .seasoning:
            return "drop.fill"
        case .other:
            return "shippingbox.fill"
        }
    }
}
