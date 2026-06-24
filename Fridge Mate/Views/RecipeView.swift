//
//  RecipeView.swift
//  Fridge Mate
//
//  Created by SURINA.
//  Updated: AI提案タブを追加
//

import SwiftUI

struct RecipeView: View {
    
    @ObservedObject var viewModel: AppViewModel
    @State private var selectedMode: RecipeMode = .useCurrentIngredients
    
    enum RecipeMode: String, CaseIterable, Identifiable {
        case useCurrentIngredients = "今ある食材"
        case buyMoreIngredients    = "買い足す"
        case aiSuggestion          = "AI提案"
        
        var id: String { rawValue }
    }
    
    // 表示するレシピ（AI提案以外のモード用）
    var suggestedRecipes: [Recipe] {
        switch selectedMode {
        case .useCurrentIngredients:
            return viewModel.recipesUsingCurrentIngredientsOnly()
        case .buyMoreIngredients:
            return viewModel.recipesWithBuyingMoreIngredients()
        case .aiSuggestion:
            return viewModel.aiRecipes
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // モード切替タブ
                    Picker("モード", selection: $selectedMode) {
                        ForEach(RecipeMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    // AI提案タブに切り替えた時、まだ何もなければ自動でリクエスト
                    .onChange(of: selectedMode) { _, newMode in
                        if newMode == .aiSuggestion && viewModel.aiRecipes.isEmpty && !viewModel.isLoadingAI {
                            viewModel.fetchAIRecipes()
                        }
                    }
                    
                    // コンテンツ切替
                    if selectedMode == .aiSuggestion {
                        aiSuggestionContent
                    } else {
                        fixedRecipeContent
                    }
                }
            }
            .navigationTitle("レシピ提案")
        }
    }
    
    // MARK: - AI提案コンテンツ
    
    @ViewBuilder
    private var aiSuggestionContent: some View {
        if viewModel.isLoadingAI {
            // ローディング中
            VStack(spacing: 16) {
                Spacer()
                ProgressView()
                    .scaleEffect(1.5)
                Text("AIがレシピを考えています…")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            
        } else if let error = viewModel.aiError {
            // エラー表示
            VStack(spacing: 20) {
                Spacer()
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.orange)
                Text(error)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Button("もう一度試す") {
                    viewModel.fetchAIRecipes()
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.green)
                Spacer()
            }
            
        } else if viewModel.aiRecipes.isEmpty {
            // 未取得状態（初回）
            VStack(spacing: 20) {
                Spacer()
                Image(systemName: "sparkles")
                    .font(.system(size: 48))
                    .foregroundStyle(AppTheme.green)
                Text("AIが今ある食材に合わせた\nオリジナルレシピを提案します")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Button("AI提案を見る") {
                    viewModel.fetchAIRecipes()
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.green)
                Spacer()
            }
            
        } else {
            // AI提案レシピ一覧 + 再取得ボタン
            ScrollView {
                VStack(spacing: 14) {
                    // AI提案バナー
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .foregroundStyle(AppTheme.green)
                        Text("AIがあなたの食材からレシピを提案しました")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button("再取得") {
                            viewModel.fetchAIRecipes()
                        }
                        .font(.caption)
                        .foregroundStyle(AppTheme.green)
                    }
                    .padding(.horizontal)
                    .padding(.top, 4)
                    
                    // レシピ一覧
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
    
    // MARK: - 固定レシピコンテンツ（既存）
    
    @ViewBuilder
    private var fixedRecipeContent: some View {
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

