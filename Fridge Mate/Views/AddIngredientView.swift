//
//  AddIngredientView.swift
//  Fridge Mate
//
//  Created by SURINA.
//

import SwiftUI

struct AddIngredientView: View {
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: AppViewModel
    
    @State private var name = ""
    @State private var amount = ""
    @State private var daysLeft = 3
    @State private var selectedCategory: IngredientCategory = .vegetable
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        headerView
                        
                        inputCard
                        
                        categoryCard
                        
                        expirationCard
                        
                        saveButton
                    }
                    .padding()
                }
            }
            .navigationTitle("食材を追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                    .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("新しい食材を登録")
                .font(.title2)
                .bold()
            
            Text("食材名・数量・分類・消費期限を入力してください")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    private var inputCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("食材情報")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("食材名")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                TextField("例：豆腐", text: $name)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(Color.gray.opacity(0.08))
                    .cornerRadius(14)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("数量")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                TextField("例：1丁、3個、少し", text: $amount)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(Color.gray.opacity(0.08))
                    .cornerRadius(14)
            }
        }
        .padding()
        .background(AppTheme.card)
        .cornerRadius(22)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var categoryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("分類")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 90), spacing: 10)
            ], spacing: 10) {
                ForEach(IngredientCategory.allCases) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        Text(category.rawValue)
                            .font(.caption)
                            .bold()
                            .foregroundStyle(selectedCategory == category ? .white : AppTheme.green)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(selectedCategory == category ? AppTheme.green : AppTheme.lightGreen)
                            .cornerRadius(20)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
        .background(AppTheme.card)
        .cornerRadius(22)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var expirationCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("消費期限")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("あと\(daysLeft)日")
                        .font(.title3)
                        .bold()
                        .foregroundStyle(expirationDisplayColor)
                    
                    Text(expirationMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Stepper("", value: $daysLeft, in: 0...30)
                    .labelsHidden()
            }
        }
        .padding()
        .background(AppTheme.card)
        .cornerRadius(22)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var saveButton: some View {
        Button {
            viewModel.addIngredient(
                name: name,
                amount: amount,
                daysLeft: daysLeft,
                category: selectedCategory
            )
            dismiss()
        } label: {
            Text("保存する")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundStyle(.white)
                .background(isSaveDisabled ? Color.gray.opacity(0.5) : AppTheme.green)
                .cornerRadius(18)
        }
        .disabled(isSaveDisabled)
        .buttonStyle(.plain)
    }
    
    private var isSaveDisabled: Bool {
        name.isEmpty || amount.isEmpty
    }
    
    private var expirationDisplayColor: Color {
        if daysLeft <= 1 {
            return .red
        } else if daysLeft <= 2 {
            return AppTheme.orange
        } else {
            return AppTheme.green
        }
    }
    
    private var expirationMessage: String {
        if daysLeft <= 1 {
            return "早めに使うことをおすすめします"
        } else if daysLeft <= 2 {
            return "消費期限が近い食材です"
        } else {
            return "まだ余裕があります"
        }
    }
}
