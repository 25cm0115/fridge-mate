//
//  ShoppingListView.swift
//  Fridge Mate
//
//  Created by SURINA.
//

import SwiftUI

struct ShoppingListView: View {
    
    @ObservedObject var viewModel: AppViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                if viewModel.shoppingItems.isEmpty {
                    emptyView
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("買うもの")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(viewModel.shoppingItems) { item in
                                HStack(spacing: 14) {
                                    Button {
                                        viewModel.toggleShoppingItem(item)
                                    } label: {
                                        Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                                            .font(.title2)
                                            .foregroundStyle(item.isChecked ? AppTheme.green : .gray)
                                    }
                                    .buttonStyle(.plain)
                                    
                                    Text(item.name)
                                        .font(.headline)
                                        .strikethrough(item.isChecked)
                                        .foregroundStyle(item.isChecked ? .secondary : .primary)
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(AppTheme.card)
                                .cornerRadius(18)
                                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top)
                    }
                }
            }
            .navigationTitle("買い物リスト")
            .toolbar {
                if !viewModel.shoppingItems.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("削除") {
                            viewModel.removeAllShoppingItems()
                        }
                        .foregroundStyle(.red)
                    }
                }
            }
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "cart")
                .font(.system(size: 54))
                .foregroundStyle(AppTheme.green)
            
            Text("買い物リストはまだありません")
                .font(.headline)
            
            Text("レシピ詳細から足りない食材を追加できます")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
