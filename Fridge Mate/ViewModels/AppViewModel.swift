//
//  AppViewModel.swift
//  Fridge Mate
//
//  Created by SURINA.
//  Updated: Gemini AIレシピ提案機能を追加
//

import Foundation
import SwiftUI
import Combine

class AppViewModel: ObservableObject {
    
    // MARK: - 食材・買い物リスト（既存）
    
    @Published var ingredients: [Ingredient] = [
        Ingredient(name: "豆腐", amount: "1丁", daysLeft: 1, category: .other),
        Ingredient(name: "卵", amount: "3個", daysLeft: 5, category: .egg),
        Ingredient(name: "青菜", amount: "少し", daysLeft: 2, category: .vegetable),
        Ingredient(name: "トマト", amount: "2個", daysLeft: 4, category: .vegetable)
    ]
    
    @Published var shoppingItems: [ShoppingItem] = []
    
    // MARK: - AI提案（新規追加）
    
    @Published var aiRecipes: [Recipe] = []      // AIが提案したレシピ
    @Published var isLoadingAI: Bool = false      // ローディング中フラグ
    @Published var aiError: String? = nil         // エラーメッセージ
    
    private let geminiService = GeminiService()   // Gemini APIサービス
    
    // MARK: - 固定レシピ（既存）
    
    let recipes: [Recipe] = [
        Recipe(
            name: "豆腐と卵のスープ",
            requiredIngredients: ["豆腐", "卵", "青菜"],
            calories: 250,
            cookingTime: "約10分",
            steps: [
                "豆腐を食べやすい大きさに切ります。",
                "鍋に水を入れて温めます。",
                "豆腐と青菜を入れます。",
                "溶き卵を入れて、味を整えます。"
            ],
            reason: "豆腐の消費期限が近い場合におすすめです。"
        ),
        Recipe(
            name: "トマト卵炒め",
            requiredIngredients: ["トマト", "卵", "ねぎ"],
            calories: 320,
            cookingTime: "約15分",
            steps: [
                "トマトを一口サイズに切ります。",
                "卵を溶いて、先に軽く炒めます。",
                "トマトを入れて炒めます。",
                "最後にねぎを入れて完成です。"
            ],
            reason: "少ない食材で作りやすく、主菜としても使えます。"
        ),
        Recipe(
            name: "野菜スープ",
            requiredIngredients: ["青菜", "にんじん", "きのこ"],
            calories: 180,
            cookingTime: "約12分",
            steps: [
                "野菜を食べやすい大きさに切ります。",
                "鍋に水を入れて温めます。",
                "野菜を入れて煮込みます。",
                "塩やコンソメで味を整えます。"
            ],
            reason: "少し残った野菜をまとめて使いたい時におすすめです。"
        )
    ]
    
    // MARK: - AI提案メソッド（新規追加）
    
    /// Gemini APIを呼び出して、今ある食材でのレシピ提案を取得する
    func fetchAIRecipes() {
        // 食材が1つもない場合は何もしない
        guard !ingredients.isEmpty else {
            aiError = "食材を追加してからAI提案を使ってください"
            return
        }
        
        isLoadingAI = true
        aiError = nil
        aiRecipes = []
        
        Task {
            do {
                let recipes = try await geminiService.suggestRecipes(ingredients: ingredients)
                await MainActor.run {
                    self.aiRecipes = recipes
                    self.isLoadingAI = false
                }
            } catch {
                await MainActor.run {
                    self.aiError = error.localizedDescription
                    self.isLoadingAI = false
                }
            }
        }
    }
    
    // MARK: - 既存メソッド（変更なし）
    
    var nearExpirationIngredients: [Ingredient] {
        ingredients.filter { $0.daysLeft <= 2 }
    }
    
    var currentIngredientNames: [String] {
        ingredients.map { $0.name }
    }
    
    func addIngredient(name: String, amount: String, daysLeft: Int, category: IngredientCategory) {
        let newIngredient = Ingredient(
            name: name,
            amount: amount,
            daysLeft: daysLeft,
            category: category
        )
        ingredients.append(newIngredient)
    }
    
    func deleteIngredient(at offsets: IndexSet) {
        ingredients.remove(atOffsets: offsets)
    }
    
    func deleteIngredient(id: UUID) {
        ingredients.removeAll { $0.id == id }
    }
    
    func missingIngredients(for recipe: Recipe) -> [String] {
        recipe.requiredIngredients.filter {
            !currentIngredientNames.contains($0)
        }
    }
    
    func recipesUsingCurrentIngredientsOnly() -> [Recipe] {
        recipes.filter { recipe in
            recipe.requiredIngredients.allSatisfy {
                currentIngredientNames.contains($0)
            }
        }
    }
    
    func recipesWithBuyingMoreIngredients() -> [Recipe] {
        recipes.filter { recipe in
            let matchedCount = recipe.requiredIngredients.filter {
                currentIngredientNames.contains($0)
            }.count
            
            return matchedCount >= 1
        }
    }
    
    func addMissingIngredientsToShoppingList(for recipe: Recipe) {
        let missing = missingIngredients(for: recipe)
        
        for name in missing {
            if !shoppingItems.contains(where: { $0.name == name }) {
                shoppingItems.append(ShoppingItem(name: name))
            }
        }
    }
    
    func toggleShoppingItem(_ item: ShoppingItem) {
        guard let index = shoppingItems.firstIndex(where: { $0.id == item.id }) else {
            return
        }
        shoppingItems[index].isChecked.toggle()
    }
    
    func deleteShoppingItem(at offsets: IndexSet) {
        shoppingItems.remove(atOffsets: offsets)
    }
    
    func removeAllShoppingItems() {
        shoppingItems.removeAll()
    }
    
    func expirationColor(days: Int) -> Color {
        if days <= 1 {
            return .red
        } else if days <= 2 {
            return .orange
        } else {
            return .secondary
        }
    }
}

