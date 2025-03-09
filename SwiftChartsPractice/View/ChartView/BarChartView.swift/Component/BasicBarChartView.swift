//
//  BasicBarChartView.swift
//  SwiftChartsPractice
//
//  Created by 林明虎 on 2025/03/09.
//

import SwiftUI
import Charts

struct BasicBarChartView: View {
    let data: [SimpleBarData]
    @State private var selectedItem: SimpleBarData?
    @State private var isAnimating: Bool = false
    @State private var tooltipPosition: CGPoint = .zero
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("基本")
                    .font(.title2)
                
                Text("タップして詳細を表示。各カテゴリごとに色分けされた棒グラフで、値のラベルも表示")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                ZStack(alignment: .topLeading) {
                    Chart(data) { item in
                        BarMark(
                            x: .value("Category", item.category),
                            y: .value("Value", isAnimating ? item.value : 0),
                            width: 20 // 棒の間隔を狭く
                        )
                        .foregroundStyle(by: .value("Category", item.category))
                        .annotation(position: .top) {
                            Text("\(Int(item.value))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .chartForegroundStyleScale([
                        "A": .blue, 
                        "B": .green, 
                        "C": .orange
                    ])
                    .chartYScale(domain: 0...30)
                    .frame(height: 200)
                    .padding()
                    .chartYAxis {
                        AxisMarks(position: .leading, values: .automatic(desiredCount: 5)) { value in
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [5, 5]))
                            AxisValueLabel() {
                                if let intValue = value.as(Int.self) {
                                    Text("\(intValue)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .chartXAxis {
                        AxisMarks(position: .bottom) { value in
                            AxisValueLabel()
                            AxisGridLine()
                        }
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
                            
                            HStack {
                                Circle()
                                    .fill(selected.category == "A" ? .blue : 
                                          selected.category == "B" ? .green : .orange)
                                    .frame(width: 8, height: 8)
                                Text("値: \(Int(selected.value))")
                                    .font(.caption)
                            }
                        }
                        .padding(8)
                        .frame(width: 100) // 幅を固定
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                        )
                        .position(
                            x: min(max(tooltipPosition.x, 60), geometry.size.width - 60),
                            y: max(tooltipPosition.y - 50, 50)
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
    
    init(data: [SimpleBarData]) {
        self.data = data
    }
}
