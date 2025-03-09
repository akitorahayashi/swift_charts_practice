//
//  RangeLineChartView.swift
//  SwiftChartsPractice
//
//  Created by 林明虎 on 2025/03/09.
//

import SwiftUI
import Charts

struct RangeLineChartView: View {
    let data: [RangeLineChartPoint]
    @State private var selectedPoint: RangeLineChartPoint?
    @State private var isAnimating: Bool = false
    @State private var tooltipPosition: CGPoint = .zero
    @State private var showRange: Bool = true
    @State private var animationProgress: CGFloat = 0
    
    // 日付フォーマッター
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter
    }()
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                // コントロールパネル
                HStack {
                    Toggle(isOn: $showRange) {
                        Text("範囲を表示")
                            .font(.caption)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                }
                .padding(.horizontal)
                
                ZStack(alignment: .topLeading) {
                    Chart(data) { item in
                        // メインの線
                        LineMark(
                            x: .value("日付", item.date),
                            y: .value("値", item.value)
                        )
                        .lineStyle(StrokeStyle(lineWidth: 3))
                        .foregroundStyle(.blue)
                        .opacity(isAnimating ? 1 : 0)
                        .symbol {
                            Circle()
                                .fill(.blue)
                                .frame(width: 8, height: 8)
                                .opacity(selectedPoint == item ? 1.0 : 0.0)
                        }
                        .symbolSize(100)
                        
                        if showRange {
                            // 範囲を表示
                            AreaMark(
                                x: .value("日付", item.date),
                                yStart: .value("最小値", item.minValue),
                                yEnd: .value("最大値", item.maxValue)
                            )
                            .foregroundStyle(.blue.opacity(0.2))
                            .interpolationMethod(.catmullRom)
                            .opacity(isAnimating ? 1 : 0)
                        }
                    }
                    .chartYScale(domain: 0...40)
                    .chartXAxis {
                        AxisMarks(values: .automatic(desiredCount: 7)) { value in
                            if let date = value.as(Date.self) {
                                AxisValueLabel {
                                    Text(dateFormatter.string(from: date))
                                        .font(.caption)
                                }
                            }
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [5, 5]))
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading, values: .automatic(desiredCount: 5)) { value in
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [5, 5]))
                            AxisValueLabel()
                        }
                    }
                    .frame(height: 250)
                    .padding()
                    .chartOverlay { proxy in
                        GeometryReader { chartGeometry in
                            Color.clear
                                .contentShape(Rectangle())
                                .onTapGesture { location in
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        let xPosition = location.x
                                        
                                        // X軸の日付を取得
                                        guard let date = proxy.value(atX: xPosition, as: Date.self) else {
                                            selectedPoint = nil
                                            return
                                        }
                                        
                                        // 最も近いデータポイントを見つける
                                        let closestPoint = data.min(by: {
                                            abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date))
                                        })
                                        
                                        if let point = closestPoint {
                                            // 同じポイントをタップした場合は選択解除
                                            if selectedPoint == point {
                                                selectedPoint = nil
                                            } else {
                                                selectedPoint = point
                                                
                                                // ツールチップの位置を計算
                                                if let pointX = proxy.position(forX: point.date) {
                                                    if let pointY = proxy.position(forY: point.value) {
                                                        tooltipPosition = CGPoint(x: pointX, y: pointY)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                        }
                    }
                    
                    // ツールチップ
                    if let selected = selectedPoint {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(dateFormatter.string(from: selected.date))
                                .font(.headline)
                                .padding(.bottom, 2)
                            
                            HStack {
                                Circle()
                                    .fill(.blue)
                                    .frame(width: 8, height: 8)
                                Text("値: \(Int(selected.value))")
                                    .font(.caption)
                            }
                            
                            if showRange {
                                Divider()
                                    .padding(.vertical, 2)
                                
                                HStack {
                                    Rectangle()
                                        .fill(.blue.opacity(0.2))
                                        .frame(width: 8, height: 8)
                                    Text("範囲: \(Int(selected.minValue)) - \(Int(selected.maxValue))")
                                        .font(.caption)
                                }
                            }
                        }
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                        )
                        .position(
                            x: min(max(tooltipPosition.x, 70), geometry.size.width - 70),
                            y: max(tooltipPosition.y - 50, 50)
                        )
                        .transition(.scale(scale: 0.8).combined(with: .opacity))
                        .zIndex(1)
                    }
                }
                
                // 凡例
                HStack(spacing: 20) {
                    HStack {
                        Circle()
                            .fill(.blue)
                            .frame(width: 6, height: 6)
                        Text("実際の値")
                            .font(.caption)
                    }
                    
                    if showRange {
                        HStack {
                            Rectangle()
                                .fill(.blue.opacity(0.2))
                                .frame(width: 12, height: 6)
                            Text("変動範囲")
                                .font(.caption)
                        }
                    }
                }
                .padding(.top, 8)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.linear(duration: 1.0)) {
                        isAnimating = true
                        animationProgress = 1.0
                    }
                }
            }
        }
    }
} 