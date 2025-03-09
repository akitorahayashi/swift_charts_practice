//
//  BarChartView.swift
//  SwiftChartsPractice
//
//  Created by 林明虎 on 2025/03/09.
//

import SwiftUI

struct BarChartView: View {
    @State private var selectedChartType: ChartType = .basic
    
    var body: some View {
        VStack(spacing: 0) {
            // チャートタイプセレクター
            Picker("チャートタイプ", selection: $selectedChartType) {
                ForEach(ChartType.allCases, id: \.self) { type in
                    Text(type.title).tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            Divider()
            
            // 選択されたチャートを表示
            ScrollView {
                VStack(spacing: 20) {
                    switch selectedChartType {
                    case .basic:
                        BasicBarChartView(data: BarChartData.simpleData)
                    case .stacked:
                        StackedBarChartView(data: BarChartData.stackedData)
                    case .grouped:
                        GroupedBarChartView(data: BarChartData.groupedData)
                    case .horizontal:
                        HorizontalBarChartView(data: BarChartData.simpleData)
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("BarMark - 棒グラフ")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // チャートタイプの列挙型
    enum ChartType: String, CaseIterable {
        case basic, stacked, grouped, horizontal
        
        var title: String {
            switch self {
            case .basic: return "基本"
            case .stacked: return "積み上げ"
            case .grouped: return "グループ"
            case .horizontal: return "横向き"
            }
        }
    }
}
