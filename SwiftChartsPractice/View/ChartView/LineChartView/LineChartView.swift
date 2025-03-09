//
//  LineChartView.swift
//  SwiftChartsPractice
//
//  Created by 林明虎 on 2025/03/09.
//

import SwiftUI

struct LineChartView: View {
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
            
            // 選択されたチャートの説明
            Text(selectedChartType.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)
                .padding(.bottom)
                .multilineTextAlignment(.center)
            
            Divider()
            
            // 選択されたチャートを表示
            ScrollView {
                VStack(spacing: 20) {
                    switch selectedChartType {
                    case .basic:
                        BasicLineChartView(data: LineChartData.basicData)
                    case .multiSeries:
                        MultiSeriesLineChartView(data: LineChartData.multiSeriesData)
                    case .range:
                        RangeLineChartView(data: LineChartData.rangeData)
                    case .step:
                        StepLineChartView(data: LineChartData.stepData)
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("LineMark - 折れ線グラフ")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // チャートタイプの列挙型
    enum ChartType: String, CaseIterable {
        case basic, multiSeries, range, step
        
        var title: String {
            switch self {
            case .basic: return "基本"
            case .multiSeries: return "複数系列"
            case .range: return "範囲付き"
            case .step: return "ステップ"
            }
        }
        
        var description: String {
            switch self {
            case .basic:
                return "基本的な折れ線グラフ。データポイントをタップして詳細を表示できます。"
            case .multiSeries:
                return "複数系列の折れ線グラフ。異なるデータセットを比較できます。"
            case .range:
                return "範囲付き折れ線グラフ。データの変動範囲を表示します。"
            case .step:
                return "ステップ折れ線グラフ。値の変化を階段状に表示します。"
            }
        }
    }
} 