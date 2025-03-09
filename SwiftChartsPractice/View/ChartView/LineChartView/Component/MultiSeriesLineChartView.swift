//
//  MultiSeriesLineChartView.swift
//  SwiftChartsPractice
//
//  Created by 林明虎 on 2025/03/09.
//

import SwiftUI
import Charts

struct MultiSeriesLineChartView: View {
    let data: [MultiLineChartPoint]
    @State private var selectedPoint: MultiLineChartPoint?
    @State private var isAnimating: Bool = false
    @State private var tooltipPosition: CGPoint = .zero
    @State private var selectedSeries: Set<String> = ["A", "B", "C"]
    @State private var animationProgress: CGFloat = 0
    
    // 日付フォーマッター
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter
    }()
    
    // 利用可能なすべてのシリーズを取得
    private var availableSeries: [String] {
        Array(Set(data.map { $0.series })).sorted()
    }
    
    // 選択されたシリーズのデータのみをフィルタリング
    private var filteredData: [MultiLineChartPoint] {
        data.filter { selectedSeries.contains($0.series) }
    }
    
    // シリーズごとの色
    private func colorForSeries(_ series: String) -> Color {
        switch series {
        case "A": return .blue
        case "B": return .green
        case "C": return .orange
        default: return .gray
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                // シリーズ選択コントロール
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(availableSeries, id: \.self) { series in
                            Button(action: {
                                if selectedSeries.contains(series) {
                                    if selectedSeries.count > 1 {
                                        selectedSeries.remove(series)
                                    }
                                } else {
                                    selectedSeries.insert(series)
                                }
                            }) {
                                HStack {
                                    Circle()
                                        .fill(colorForSeries(series))
                                        .frame(width: 10, height: 10)
                                    Text("シリーズ \(series)")
                                        .font(.caption)
                                    if selectedSeries.contains(series) {
                                        Image(systemName: "checkmark")
                                            .font(.caption)
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedSeries.contains(series) ? 
                                            colorForSeries(series).opacity(0.2) : 
                                            Color.gray.opacity(0.1))
                                .foregroundColor(selectedSeries.contains(series) ? 
                                                colorForSeries(series) : .primary)
                                .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                ZStack(alignment: .topLeading) {
                    Chart(filteredData) { item in
                        LineMark(
                            x: .value("日付", item.date),
                            y: .value("値", item.value)
                        )
                        .foregroundStyle(by: .value("シリーズ", "シリーズ \(item.series)"))
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        .opacity(isAnimating ? 1 : 0)
                        .symbol {
                            Circle()
                                .fill(colorForSeries(item.series))
                                .frame(width: 8, height: 8)
                                .opacity((selectedPoint?.series == item.series && 
                                        selectedPoint?.date == item.date) ? 1.0 : 0.0)
                        }
                        .symbolSize(100)
                    }
                    .chartForegroundStyleScale([
                        "シリーズ A": colorForSeries("A"),
                        "シリーズ B": colorForSeries("B"),
                        "シリーズ C": colorForSeries("C")
                    ])
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
                    .chartLegend(.hidden)
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
                                        
                                        // 最も近い日付のデータポイントを見つける
                                        let pointsOnDate = filteredData.filter {
                                            Calendar.current.isDate($0.date, inSameDayAs: date)
                                        }
                                        
                                        if !pointsOnDate.isEmpty {
                                            // 同じ日付のポイントが既に選択されている場合は選択解除
                                            if let current = selectedPoint, 
                                               pointsOnDate.contains(where: { Calendar.current.isDate($0.date, inSameDayAs: current.date) }) {
                                                selectedPoint = nil
                                            } else {
                                                // 最初のポイントを選択
                                                selectedPoint = pointsOnDate.first
                                                
                                                // ツールチップの位置を計算
                                                if let point = pointsOnDate.first,
                                                   let pointX = proxy.position(forX: point.date) {
                                                    tooltipPosition = CGPoint(x: pointX, y: 50)
                                                }
                                            }
                                        } else {
                                            selectedPoint = nil
                                        }
                                    }
                                }
                        }
                    }
                    
                    // ツールチップ
                    if let selected = selectedPoint, 
                       let pointsOnDate = filteredData.filter({ Calendar.current.isDate($0.date, inSameDayAs: selected.date) }).sorted(by: { $0.series < $1.series }) as [MultiLineChartPoint]?, 
                       !pointsOnDate.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(dateFormatter.string(from: selected.date))
                                .font(.headline)
                                .padding(.bottom, 2)
                            
                            ForEach(pointsOnDate, id: \.id) { point in
                                HStack {
                                    Circle()
                                        .fill(colorForSeries(point.series))
                                        .frame(width: 8, height: 8)
                                    Text("シリーズ \(point.series): \(Int(point.value))")
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
                            x: min(max(tooltipPosition.x, 80), geometry.size.width - 80),
                            y: tooltipPosition.y + 50
                        )
                        .transition(.scale(scale: 0.8).combined(with: .opacity))
                        .zIndex(1)
                    }
                }
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