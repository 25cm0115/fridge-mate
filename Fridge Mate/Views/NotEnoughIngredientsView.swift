//
//  NotEnoughIngredientsView.swift
//  Fridge Mate
//
//  Created by SURINA.
//

import SwiftUI

struct NotEnoughIngredientsView: View {
    
    var body: some View {
        VStack(spacing: 20) {
            
            Spacer()
            
            ZStack {
                Circle()
                    .fill(AppTheme.lightGreen)
                    .frame(width: 96, height: 96)
                
                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(AppTheme.green)
            }
            
            VStack(spacing: 8) {
                Text("今の食材だけでは")
                    .font(.title3)
                    .bold()
                
                Text("一食分の料理を作るのが難しいです")
                    .font(.title3)
                    .bold()
            }
            .multilineTextAlignment(.center)
            
            Text("少しだけ買い足すか、副菜・保存方法として活用するのがおすすめです。")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 14) {
                suggestionRow(
                    icon: "cart.badge.plus",
                    title: "少しだけ食材を買い足す",
                    subtitle: "主食やたんぱく質を追加して一食にする"
                )
                
                suggestionRow(
                    icon: "takeoutbag.and.cup.and.straw",
                    title: "副菜として使う",
                    subtitle: "小さなおかずやスープの具にする"
                )
                
                suggestionRow(
                    icon: "snowflake",
                    title: "冷凍保存する",
                    subtitle: "次回の料理で使えるように保存する"
                )
            }
            .padding()
            .background(AppTheme.card)
            .cornerRadius(22)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    private func suggestionRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppTheme.lightGreen)
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .foregroundStyle(AppTheme.green)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .bold()
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
