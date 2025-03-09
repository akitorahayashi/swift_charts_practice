//
//  StepLineChartView.swift
//  SwiftChartsPractice
//
//  Created by 林明虎 on 2025/03/09.
//

import SwiftUI
import Charts

struct StepLineChartView: View {
    let data: [LineChartPoint]
    @State private var selectedPoint: LineChartPoint?
    @State private var isAnimating: Bool = false
    @State private var tooltipPosition: CGPoint = .zero
    @State private var showArea: Bool = true
    @State private var showPoints: Bool = true
    
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
                    Toggle(isOn: $showArea) {
                        Text("エリア表示")
                            .font(.caption)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .green))
                    
                    Spacer()
                    
                    Toggle(isOn: $showPoints) {
                        Text("ポイント表示")
                            .font(.caption)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                }
                .padding(.horizontal)
                
                ZStack(alignment: .topLeading) {
                    Chart(data) { item in
                        if showArea {
                            // エリア表示
                            AreaMark(
                                x: .value("日付", item.date),
                                y: .value("値", isAnimating ? item.value : 0)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.green.opacity(0.7), .green.opacity(0.1)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .interpolationMethod(.stepCenter)
                        }
                        
                        // ステップ線
                        LineMark(
                            x: .value("日付", item.date),
                            y: .value("値", isAnimating ? item.value : 0)
                        )
                        .lineStyle(StrokeStyle(lineWidth: 3))
                        .foregroundStyle(.green)
                        .interpolationMethod(.stepCenter)
                        
                        if showPoints {
                            // ポイント
                            PointMark(
                                x: .value("日付", item.date),
                                y: .value("値", isAnimating ? item.value : 0)
                            )
                            .foregroundStyle(selectedPoint == item ? .red : .green)
                            .symbolSize(selectedPoint == item ? 150 : 100)
                        }
                    }
                    .chartYScale(domain: 0...35)
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
                                    .fill(.green)
                                    .frame(width: 8, height: 8)
                                Text("値: \(Int(selected.value))")
                                    .font(.caption)
                            }
                            
                            // 前後の変化を表示
                            if let index = data.firstIndex(where: { $0.id == selected.id }) {
                                if index > 0 {
                                    let previousValue = data[index - 1].value
                                    let change = selected.value - previousValue
                                    
                                    Divider()
                                        .padding(.vertical, 2)
                                    
                                    HStack {
                                        Image(systemName: change >= 0 ? "arrow.up" : "arrow.down")
                                            .font(.caption)
                                            .foregroundColor(change >= 0 ? .green : .red)
                                        
                                        Text("変化: \(change >= 0 ? "+" : "")\(Int(change))")
                                            .font(.caption)
                                            .foregroundColor(change >= 0 ? .green : .red)
                                    }
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
                        Rectangle()
                            .fill(.green)
                            .frame(width: 20, height: 2)
                        Text("ステップ線")
                            .font(.caption)
                    }
                    
                    if showPoints {
                        HStack {
                            Circle()
                                .fill(.green)
                                .frame(width: 6, height: 6)
                            Text("データポイント")
                                .font(.caption)
                        }
                    }
                    
                    if showArea {
                        HStack {
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [.green.opacity(0.7), .green.opacity(0.1)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 12, height: 12)
                            Text("エリア")
                                .font(.caption)
                        }
                    }
                }
                .padding(.top, 8)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                        isAnimating = true
                    }
                }
            }
        }
    }
} 
