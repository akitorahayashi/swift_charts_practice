//
//  MarkType.swift.swift
//  SwiftChartsPractice
//
//  Created by 林明虎 on 2025/03/09.
//

import SwiftUI

enum MarkType: String, CaseIterable, Identifiable {
    case bar = "BarMark"
    case line = "LineMark"
//    case point = "PointMark"
//    case area = "AreaMark"
//    case rectangle = "RectangleMark"
//    case rule = "RuleMark"
//    case tick = "TickMark"
//    case polygon = "PolygonMark"

    var id: Self { self }
    
    /// 各 `MarkType` に対応する `View`
    @ViewBuilder
    var view: some View {
        switch self {
        case .bar: BarChartView()
        case .line: LineChartView()
//        case .point: ScatterChartView()
//        case .area: AreaChartView()
//        case .rectangle: RectangleChartView()
//        case .rule: RuleChartView()
//        case .tick: TickChartView()
//        case .polygon: PolygonChartView()
        }
    }
}
