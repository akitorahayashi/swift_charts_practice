//
//  BarChartData.swift
//  SwiftChartsPractice
//
//  Created by 林明虎 on 2025/03/09.
//

import SwiftUI

struct BarChartData {
    // 基本的な棒グラフのデータ
    static let simpleData: [SimpleBarData] = [
        SimpleBarData(category: "A", value: 10),
        SimpleBarData(category: "B", value: 20),
        SimpleBarData(category: "C", value: 15)
    ]
    
    // 積み上げ棒グラフのデータ
    static let stackedData: [StackedBarData] = [
        StackedBarData(category: "A", value1: 10, value2: 5),
        StackedBarData(category: "B", value1: 20, value2: 8),
        StackedBarData(category: "C", value1: 15, value2: 12)
    ]
    
    // グループ化棒グラフのデータ
    static let groupedData: [GroupedBarData] = [
        GroupedBarData(category: "A", group: "X", value: 10),
        GroupedBarData(category: "A", group: "Y", value: 15),
        GroupedBarData(category: "B", group: "X", value: 20),
        GroupedBarData(category: "B", group: "Y", value: 25),
        GroupedBarData(category: "C", group: "X", value: 15),
        GroupedBarData(category: "C", group: "Y", value: 18)
    ]
    
    // 後方互換性のためのタプル変換メソッド（必要に応じて）
    static var simpleDataAsTuples: [(String, Double)] {
        simpleData.map { ($0.category, $0.value) }
    }
    
    static var stackedDataAsTuples: [(String, Double, Double)] {
        stackedData.map { ($0.category, $0.value1, $0.value2) }
    }
    
    static var groupedDataAsTuples: [(String, String, Double)] {
        groupedData.map { ($0.category, $0.group, $0.value) }
    }
}
