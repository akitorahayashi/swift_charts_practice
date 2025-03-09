//
//  LineChartData.swift
//  SwiftChartsPractice
//
//  Created by 林明虎 on 2025/03/09.
//

import SwiftUI

struct LineChartData {
    // 基本的な折れ線グラフのデータ
    static let basicData: [LineChartPoint] = [
        LineChartPoint(day: 1, month: 3, value: 10),
        LineChartPoint(day: 5, month: 3, value: 25),
        LineChartPoint(day: 10, month: 3, value: 15),
        LineChartPoint(day: 15, month: 3, value: 30),
        LineChartPoint(day: 20, month: 3, value: 18),
        LineChartPoint(day: 25, month: 3, value: 22),
        LineChartPoint(day: 30, month: 3, value: 35)
    ]
    
    // 複数系列の折れ線グラフのデータ
    static let multiSeriesData: [MultiLineChartPoint] = [
        // シリーズA
        MultiLineChartPoint(day: 1, month: 3, series: "A", value: 10),
        MultiLineChartPoint(day: 5, month: 3, series: "A", value: 15),
        MultiLineChartPoint(day: 10, month: 3, series: "A", value: 12),
        MultiLineChartPoint(day: 15, month: 3, series: "A", value: 18),
        MultiLineChartPoint(day: 20, month: 3, series: "A", value: 16),
        MultiLineChartPoint(day: 25, month: 3, series: "A", value: 20),
        MultiLineChartPoint(day: 30, month: 3, series: "A", value: 22),
        
        // シリーズB
        MultiLineChartPoint(day: 1, month: 3, series: "B", value: 15),
        MultiLineChartPoint(day: 5, month: 3, series: "B", value: 22),
        MultiLineChartPoint(day: 10, month: 3, series: "B", value: 18),
        MultiLineChartPoint(day: 15, month: 3, series: "B", value: 25),
        MultiLineChartPoint(day: 20, month: 3, series: "B", value: 20),
        MultiLineChartPoint(day: 25, month: 3, series: "B", value: 28),
        MultiLineChartPoint(day: 30, month: 3, series: "B", value: 30),
        
        // シリーズC
        MultiLineChartPoint(day: 1, month: 3, series: "C", value: 5),
        MultiLineChartPoint(day: 5, month: 3, series: "C", value: 8),
        MultiLineChartPoint(day: 10, month: 3, series: "C", value: 10),
        MultiLineChartPoint(day: 15, month: 3, series: "C", value: 12),
        MultiLineChartPoint(day: 20, month: 3, series: "C", value: 15),
        MultiLineChartPoint(day: 25, month: 3, series: "C", value: 14),
        MultiLineChartPoint(day: 30, month: 3, series: "C", value: 18)
    ]
    
    // 範囲付き折れ線グラフのデータ
    static let rangeData: [RangeLineChartPoint] = [
        RangeLineChartPoint(day: 1, month: 3, value: 15, minValue: 10, maxValue: 20),
        RangeLineChartPoint(day: 5, month: 3, value: 22, minValue: 18, maxValue: 26),
        RangeLineChartPoint(day: 10, month: 3, value: 18, minValue: 14, maxValue: 22),
        RangeLineChartPoint(day: 15, month: 3, value: 25, minValue: 20, maxValue: 30),
        RangeLineChartPoint(day: 20, month: 3, value: 20, minValue: 16, maxValue: 24),
        RangeLineChartPoint(day: 25, month: 3, value: 28, minValue: 24, maxValue: 32),
        RangeLineChartPoint(day: 30, month: 3, value: 30, minValue: 25, maxValue: 35)
    ]
    
    // ステップ折れ線グラフのデータ
    static let stepData: [LineChartPoint] = [
        LineChartPoint(day: 1, month: 3, value: 10),
        LineChartPoint(day: 5, month: 3, value: 15),
        LineChartPoint(day: 10, month: 3, value: 15),
        LineChartPoint(day: 15, month: 3, value: 20),
        LineChartPoint(day: 20, month: 3, value: 25),
        LineChartPoint(day: 25, month: 3, value: 25),
        LineChartPoint(day: 30, month: 3, value: 30)
    ]
} 