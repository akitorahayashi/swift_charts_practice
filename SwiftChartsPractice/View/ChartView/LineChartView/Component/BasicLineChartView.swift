//
//  BasicLineChartView.swift
//  SwiftChartsPractice
//
//  Created by 林明虎 on 2025/03/09.
//

import SwiftUI
import Charts

struct BasicLineChartView: View {
    let data: [LineChartPoint]
    @State private var selectedPoint: LineChartPoint?
    @State private var isAnimating: Bool = false
    @State private var animationProgress: CGFloat = 0
    @State private var tooltipPosition: CGPoint = .zero
    @State private var showSymbols: Bool = true
    @State private var lineStyle: LineStyle = .smooth
    
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
                    Toggle(isOn: $showSymbols) {
                        Text("ポイント表示")
                            .font(.caption)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    
                    Spacer()
                    
                    Picker("線のスタイル", selection: $lineStyle) {
                        Text("滑らか").tag(LineStyle.smooth)
                        Text("直線").tag(LineStyle.straight)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 150)
                }
                .padding(.horizontal)
                
                ZStack(alignment: .topLeading) {
                    Chart(data) { item in
                        LineMark(
                            x: .value("日付", item.date),
                            y: .value("値", item.value)
                        )
                        .lineStyle(StrokeStyle(lineWidth: 3))
                        .foregroundStyle(Gradient(colors: [.blue.opacity(0.5), .blue]))
                        .interpolationMethod(lineStyle == .smooth ? .catmullRom : .linear)
                        .opacity(isAnimating ? 1 : 0)
                        
                        if showSymbols {
                            PointMark(
                                x: .value("日付", item.date),
                                y: .value("値", item.value)
                            )
                            .foregroundStyle(selectedPoint == item ? .red : .blue)
                            .symbolSize(selectedPoint == item ? 150 : 100)
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
                                        let yPosition = location.y
                                        
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
                        }
                        .padding(8)
                        .frame(width: 100)
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
                
                // 凡例
                HStack(spacing: 20) {
                    HStack {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.blue)
                            .frame(width: 20, height: 2)
                        Text("値")
                            .font(.caption)
                    }
                    
                    if showSymbols {
                        HStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 6, height: 6)
                            Text("データポイント")
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
    
    // 線のスタイル
    enum LineStyle {
        case smooth, straight
    }
} 