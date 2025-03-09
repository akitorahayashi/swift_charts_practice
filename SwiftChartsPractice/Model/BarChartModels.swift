//
//  BarChartModels.swift
//  SwiftChartsPractice
//
//  Created by 林明虎 on 2025/03/09.
//

import Foundation

// 基本的な棒グラフのデータモデル
struct SimpleBarData: Identifiable, Hashable {
    let id = UUID()
    let category: String
    let value: Double
}

// 積み上げ棒グラフのデータモデル
struct StackedBarData: Identifiable, Hashable {
    let id = UUID()
    let category: String
    let value1: Double
    let value2: Double
}

// グループ化棒グラフのデータモデル
struct GroupedBarData: Identifiable, Hashable {
    let id = UUID()
    let category: String
    let group: String
    let value: Double
} 