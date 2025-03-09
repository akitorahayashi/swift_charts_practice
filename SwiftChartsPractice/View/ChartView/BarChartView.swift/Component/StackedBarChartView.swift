//
//  StackedBarChartView.swift
//  SwiftChartsPractice
//
//  Created by 林明虎 on 2025/03/09.
//

import SwiftUI
import Charts

struct StackedBarChartView: View {
    let data: [StackedBarData]
    @State private var selectedItem: StackedBarData?
    @State private var isAnimating: Bool = false
    @State private var showValue1: Bool = true
    @State private var showValue2: Bool = true
    @State private var tooltipPosition: CGPoint = .zero
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("積み上げ棒グラフ")
                    .font(.title2)
                
                Text("トグルで各値の表示/非表示を切り替え可能。タップで詳細情報と合計値を表示")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                HStack {
                    Toggle(isOn: $showValue1) {
                        HStack {
                            Circle()
                                .fill(.purple)
                                .frame(width: 12, height: 12)
                            Text("値1")
                                .font(.caption)
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .purple))
                    
                    Toggle(isOn: $showValue2) {
                        HStack {
                            Circle()
                                .fill(.orange)
                                .frame(width: 12, height: 12)
                            Text("値2")
                                .font(.caption)
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .orange))
                }
                .padding(.horizontal)
                
                ZStack(alignment: .topLeading) {
                    Chart(data) { item in
                        if showValue1 {
                            BarMark(
                                x: .value("Category", item.category),
                                y: .value("Value", isAnimating ? item.value1 : 0),
                                stacking: .standard
                            )
                            .foregroundStyle(.purple.gradient)
                            .clipShape(Capsule()) // 棒の形をカプセルに
                        }
                        
                        if showValue2 {
                            BarMark(
                                x: .value("Category", item.category),
                                y: .value("Value", isAnimating ? item.value2 : 0),
                                stacking: .standard
                            )
                            .foregroundStyle(.orange.gradient)
                            .clipShape(Capsule()) // 形を統一
                        }
                    }
                    .chartLegend(.hidden)
                    .chartYScale(domain: 0...35)
                    .frame(height: 200)
                    .padding()
                    .chartXAxis {
                        AxisMarks { value in
                            AxisValueLabel()
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading, values: .automatic(desiredCount: 5)) { value in
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [5, 5]))
                            AxisValueLabel()
                        }
                    }
                    .chartPlotStyle { plot in
                        plot.background(.ultraThinMaterial) // 背景をガラス効果に
                            .cornerRadius(10)
                    }
                    .chartOverlay { proxy in
                        GeometryReader { geometry in
                            Color.clear
                                .contentShape(Rectangle())
                                .onTapGesture { location in
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        if let category = proxy.value(atX: location.x, as: String.self) {
                                            if let tappedItem = data.first(where: { $0.category == category }) {
                                                // 同じアイテムをタップした場合は非表示に
                                                if selectedItem?.category == tappedItem.category {
                                                    selectedItem = nil
                                                } else {
                                                    // タップした位置を保存
                                                    tooltipPosition = location
                                                    selectedItem = tappedItem
                                                }
                                            } else {
                                                selectedItem = nil
                                            }
                                        } else {
                                            selectedItem = nil
                                        }
                                    }
                                }
                        }
                    }
                    
                    // ツールチップスタイルの情報表示
                    if let selected = selectedItem {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(selected.category)
                                .font(.headline)
                                .padding(.bottom, 2)
                            
                            if showValue1 {
                                HStack {
                                    Circle()
                                        .fill(.purple)
                                        .frame(width: 8, height: 8)
                                    Text("値1: \(Int(selected.value1))")
                                        .font(.caption)
                                }
                            }
                            
                            if showValue2 {
                                HStack {
                                    Circle()
                                        .fill(.orange)
                                        .frame(width: 8, height: 8)
                                    Text("値2: \(Int(selected.value2))")
                                        .font(.caption)
                                }
                            }
                            
                            Divider()
                                .padding(.vertical, 2)
                            
                            Text("合計: \(Int(selected.value1 + selected.value2))")
                                .font(.caption.bold())
                        }
                        .padding(8)
                        .frame(width: 120) // 幅を固定
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                        )
                        .position(
                            x: min(max(tooltipPosition.x, 70), geometry.size.width - 70),
                            y: max(tooltipPosition.y - 60, 50)
                        )
                        .transition(.scale(scale: 0.8).combined(with: .opacity))
                        .zIndex(1)
                    }
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                    isAnimating = true
                }
            }
        }
    }
    
    // 後方互換性のためのイニシャライザ
    init(data: [StackedBarData]) {
        self.data = data
    }
}
