//
//  LineChartModels.swift
//  SwiftChartsPractice
//
//  Created by 林明虎 on 2025/03/09.
//

import Foundation

// 基本的な折れ線グラフのデータモデル
struct LineChartPoint: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let value: Double
    
    init(day: Int, month: Int, value: Double) {
        var dateComponents = DateComponents()
        dateComponents.day = day
        dateComponents.month = month
        dateComponents.year = 2025
        self.date = Calendar.current.date(from: dateComponents) ?? Date()
        self.value = value
    }
}

// 複数系列の折れ線グラフのデータモデル
struct MultiLineChartPoint: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let series: String
    let value: Double
    
    init(day: Int, month: Int, series: String, value: Double) {
        var dateComponents = DateComponents()
        dateComponents.day = day
        dateComponents.month = month
        dateComponents.year = 2025
        self.date = Calendar.current.date(from: dateComponents) ?? Date()
        self.series = series
        self.value = value
    }
}

// 範囲付き折れ線グラフのデータモデル
struct RangeLineChartPoint: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let value: Double
    let minValue: Double
    let maxValue: Double
    
    init(day: Int, month: Int, value: Double, minValue: Double, maxValue: Double) {
        var dateComponents = DateComponents()
        dateComponents.day = day
        dateComponents.month = month
        dateComponents.year = 2025
        self.date = Calendar.current.date(from: dateComponents) ?? Date()
        self.value = value
        self.minValue = minValue
        self.maxValue = maxValue
    }
} 