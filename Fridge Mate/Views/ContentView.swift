//
//  ContentView.swift
//  Fridge Mate
//
//  Created by SURINA.
//
import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel = AppViewModel()
    
    var body: some View {
        TabView {
            FridgeView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "refrigerator")
                    Text("冷蔵庫")
                }
            
            RecipeView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "fork.knife")
                    Text("レシピ")
                }
            
            ShoppingListView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "cart")
                    Text("買い物")
                }
        }
        .tint(AppTheme.green)
    }
}

#Preview {
    ContentView()
}
