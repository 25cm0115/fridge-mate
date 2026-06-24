//
//  GeminiService.swift
//  Fridge Mate
//
//  Gemini APIを使って、冷蔵庫の食材からレシピを提案するサービス
//

import Foundation

struct GeminiService {
    
    // ★ここにGemini APIキー
    private let apiKey = "AQ.Ab8RN6K4ZQlNopa80rHAj0gmv5VUzoJkNj2lrXZ6qsJEdXsYvQ"
    
    // 使用するモデル（gemini-2.5-flashは無料枠あり）
    private let model = "gemini-2.5-flash"
    
    // MARK: - Gemini APIのレスポンス用構造体
    
    private struct GeminiResponse: Decodable {
        let candidates: [Candidate]
        
        struct Candidate: Decodable {
            let content: Content
            
            struct Content: Decodable {
                let parts: [Part]
                
                struct Part: Decodable {
                    let text: String
                }
            }
        }
    }
    
    // MARK: - レシピ提案メイン関数
    
    /// 食材リストをGeminiに送り、レシピ提案を取得する
    func suggestRecipes(ingredients: [Ingredient]) async throws -> [Recipe] {
        
        // 食材名を「、」でつなぐ（例：「卵、豆腐、トマト」）
        let ingredientList = ingredients.map { $0.name }.joined(separator: "、")
        
        // AIへの指示文（プロンプト）
        let prompt = """
        冷蔵庫に以下の食材があります：\(ingredientList)
        
        これらの食材を活用した料理を3品提案してください。
        消費期限が近い食材を優先的に使う提案があればなお良いです。
        
        以下のJSON形式のみで返答してください（説明文や```は不要です）：
        [
          {
            "name": "料理名",
            "requiredIngredients": ["食材1", "食材2"],
            "calories": 300,
            "cookingTime": "約15分",
            "steps": ["手順1", "手順2", "手順3"],
            "reason": "この料理をおすすめする理由"
          }
        ]
        """
        
        // リクエストのURLを作成
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent?key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            throw GeminiError.invalidURL
        }
        
        // リクエストボディを組み立てる
        let requestBody: [String: Any] = [
            "contents": [
                ["parts": [["text": prompt]]]
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        // APIを呼び出す
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // ステータスコードを確認
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            if let httpResponse = response as? HTTPURLResponse {
                print("❌ コード: \(httpResponse.statusCode)")
                if let body = String(data: data, encoding: .utf8) {
                    print("❌ 内容: \(body)")
                }
            }
            throw GeminiError.apiError
        }
        // レスポンスをパース
        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
        
        guard let text = geminiResponse.candidates.first?.content.parts.first?.text else {
            throw GeminiError.emptyResponse
        }
        
        // AIのテキスト返答をRecipe配列に変換して返す
        return try parseRecipes(from: text)
    }
    
    // MARK: - JSONパース
    
    /// AIが返したJSONテキストをRecipe配列に変換する
    private func parseRecipes(from text: String) throws -> [Recipe] {
        
        // AIが余分な文字（```json など）を返すことがあるので除去する
        let cleanText = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let jsonData = cleanText.data(using: .utf8) else {
            throw GeminiError.parseError
        }
        
        // AIレスポンス用の一時的な構造体
        struct AIRecipeJSON: Decodable {
            let name: String
            let requiredIngredients: [String]
            let calories: Int
            let cookingTime: String
            let steps: [String]
            let reason: String
        }
        
        let aiRecipes = try JSONDecoder().decode([AIRecipeJSON].self, from: jsonData)
        
        // アプリで使うRecipe型に変換して返す
        return aiRecipes.map { ai in
            Recipe(
                name: ai.name,
                requiredIngredients: ai.requiredIngredients,
                calories: ai.calories,
                cookingTime: ai.cookingTime,
                steps: ai.steps,
                reason: ai.reason
            )
        }
    }
    
    // MARK: - エラー定義
    
    enum GeminiError: LocalizedError {
        case invalidURL
        case apiError
        case emptyResponse
        case parseError
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:     return "URLが無効です"
            case .apiError:       return "APIエラーが発生しました。APIキーを確認してください"
            case .emptyResponse:  return "AIからの返答が空でした"
            case .parseError:     return "レシピの解析に失敗しました"
            }
        }
    }
}
