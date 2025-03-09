//
//  HorizontalBarChartView.swift
//  SwiftChartsPractice
//
//  Created by 林明虎 on 2025/03/09.
//

import SwiftUI
import Charts

struct HorizontalBarChartView: View {
    let data: [SimpleBarData]
    @State private var selectedItem: SimpleBarData?
    @State private var isAnimating: Bool = false
    @State private var sortOrder: SortOrder = .none
    @State private var showValues: Bool = true
    @State private var gradientStyle: GradientStyle = .blueGreen
    
    // ソート順に基づいてデータをソート
    private var sortedData: [SimpleBarData] {
        switch sortOrder {
        case .none:
            return data
        case .ascending:
            return data.sorted { $0.value < $1.value }
        case .descending:
            return data.sorted { $0.value > $1.value }
        case .alphabetical:
            return data.sorted { $0.category < $1.category }
        }
    }
    
    // 選択されたグラデーションスタイル
    private var currentGradient: LinearGradient {
        switch gradientStyle {
        case .blueGreen:
            return LinearGradient(
                colors: [.blue, .green],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .purpleOrange:
            return LinearGradient(
                colors: [.purple, .orange],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .redYellow:
            return LinearGradient(
                colors: [.red, .yellow],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("横向き棒グラフ")
                    .font(.title2)
                Text("複数のソート方法とカラーテーマを選択可能。値の表示/非表示を切り替えられます")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // コントロールパネル
                HStack {
                    Menu {
                        Button("ソートなし") { sortOrder = .none }
                        Button("昇順") { sortOrder = .ascending }
                        Button("降順") { sortOrder = .descending }
                        Button("アルファベット順") { sortOrder = .alphabetical }
                    } label: {
                        Label(
                            sortOrder == .none ? "ソートなし" : 
                            sortOrder == .ascending ? "昇順" : 
                            sortOrder == .descending ? "降順" : "アルファベット順",
                            systemImage: "arrow.up.arrow.down"
                        )
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    Menu {
                        Button("青緑") { gradientStyle = .blueGreen }
                        Button("紫オレンジ") { gradientStyle = .purpleOrange }
                        Button("赤黄") { gradientStyle = .redYellow }
                    } label: {
                        Label("カラー", systemImage: "paintpalette")
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.secondary.opacity(0.2))
                            .cornerRadius(8)
                    }
                    
                    Toggle(isOn: $showValues) {
                        Text("値を表示")
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    .fixedSize()
                }
                .padding(.horizontal)
                
                Chart(sortedData) { item in
                    BarMark(
                        x: .value("Value", isAnimating ? item.value : 0),
                        y: .value("Category", item.category)
                    )
                    .foregroundStyle(currentGradient)
                    .opacity(selectedItem == nil || selectedItem == item ? 1.0 : 0.5)
                    .annotation(position: .trailing) {
                        if showValues {
                            Text("\(Int(item.value))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .chartXScale(domain: 0...25)
                .frame(height: 200)
                .padding()
                .chartXAxis {
                    AxisMarks(position: .bottom, values: .automatic(desiredCount: 5)) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [5, 5]))
                        AxisValueLabel()
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel()
                            .font(.system(size: 12, weight: .bold))
                    }
                }
                .chartOverlay { proxy in
                    GeometryReader { geometry in
                        Rectangle()
                            .fill(Color.clear)
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        let location = value.location
                                        if let category = proxy.value(atY: location.y, as: String.self) {
                                            selectedItem = sortedData.first(where: { $0.category == category })
                                        }
                                    }
                                    .onEnded { _ in
                                        selectedItem = nil
                                    }
                            )
                    }
                }
                
                if let selected = selectedItem {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("カテゴリー: \(selected.category)")
                                .font(.headline)
                            Text("値: \(Int(selected.value))")
                            
                            // 最大値に対する割合を計算
                            if let maxValue = sortedData.map({ $0.value }).max() {
                                Text("最大値の \(Int(selected.value * 100 / maxValue))%")
                                    .font(.caption)
                            }
                        }
                        
                        Spacer()
                        
                        // 値を視覚的に表現
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.secondary.opacity(0.2))
                                .frame(width: 100, height: 16)
                            
                            if let maxValue = sortedData.map({ $0.value }).max(), maxValue > 0 {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(currentGradient)
                                    .frame(width: 100 * CGFloat(selected.value / maxValue), height: 16)
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.secondary.opacity(0.1))
                    )
                    .padding(.horizontal)
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
    }
    
    // ソート順の列挙型
    enum SortOrder {
        case none, ascending, descending, alphabetical
    }
    
    // グラデーションスタイルの列挙型
    enum GradientStyle {
        case blueGreen, purpleOrange, redYellow
    }
    
    init(data: [SimpleBarData]) {
        self.data = data
    }
}
