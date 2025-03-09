//
//  GroupedBarChartView.swift
//  SwiftChartsPractice
//
//  Created by 林明虎 on 2025/03/09.
//

import SwiftUI
import Charts

struct GroupedBarChartView: View {
    let data: [GroupedBarData]
    @State private var selectedItem: GroupedBarData?
    @State private var isAnimating: Bool = false
    @State private var sortOrder: SortOrder = .none
    @State private var selectedGroups: Set<String> = ["X", "Y"]
    @State private var showTotals: Bool = true
    
    // 利用可能なすべてのグループを取得
    private var availableGroups: [String] {
        Array(Set(data.map { $0.group })).sorted()
    }
    
    // 選択されたグループのデータのみをフィルタリング
    private var filteredData: [GroupedBarData] {
        data.filter { selectedGroups.contains($0.group) }
    }
    
    // ソート順に基づいてデータをソート
    private var sortedData: [GroupedBarData] {
        switch sortOrder {
        case .none:
            return filteredData
        case .ascending:
            return filteredData.sorted { $0.value < $1.value }
        case .descending:
            return filteredData.sorted { $0.value > $1.value }
        }
    }
    
    // カテゴリごとの合計値を計算
    private var categoryTotals: [String: Double] {
        var totals: [String: Double] = [:]
        for item in filteredData {
            totals[item.category, default: 0] += item.value
        }
        return totals
    }
    
    var body: some View {
        VStack {
            Text("グループ化棒グラフ")
                .font(.title2)
            Text("グループのフィルタリングとソートが可能。各カテゴリの合計値を自動計算して表示")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // グループフィルタリングコントロール
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(availableGroups, id: \.self) { group in
                        Button(action: {
                            if selectedGroups.contains(group) {
                                if selectedGroups.count > 1 {
                                    selectedGroups.remove(group)
                                }
                            } else {
                                selectedGroups.insert(group)
                            }
                        }) {
                            HStack {
                                Text(group)
                                if selectedGroups.contains(group) {
                                    Image(systemName: "checkmark")
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedGroups.contains(group) ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(selectedGroups.contains(group) ? .white : .primary)
                            .cornerRadius(20)
                        }
                    }
                    
                    Divider()
                        .frame(height: 20)
                    
                    // ソートコントロール
                    Menu {
                        Button("ソートなし") { sortOrder = .none }
                        Button("昇順") { sortOrder = .ascending }
                        Button("降順") { sortOrder = .descending }
                    } label: {
                        Label(
                            sortOrder == .none ? "ソートなし" : 
                            sortOrder == .ascending ? "昇順" : "降順",
                            systemImage: sortOrder == .none ? "arrow.up.arrow.down" :
                                        sortOrder == .ascending ? "arrow.up" : "arrow.down"
                        )
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(20)
                    }
                    
                    Toggle(isOn: $showTotals) {
                        Text("合計を表示")
                            .font(.caption)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    .fixedSize()
                }
                .padding(.horizontal)
            }
            
            ZStack(alignment: .top) {
                Chart(sortedData) { item in
                    BarMark(
                        x: .value("Category", item.category),
                        y: .value("Value", isAnimating ? item.value : 0)
                    )
                    .foregroundStyle(by: .value("Group", item.group))
                    .position(by: .value("Group", item.group))
                    .shadow(radius: 2, x: 2, y: 2)
                    .opacity(selectedItem == nil || selectedItem?.category == item.category ? 1.0 : 0.5)
                    .annotation(position: .top, alignment: .center) {
                        if selectedItem?.category == item.category && selectedItem?.group == item.group {
                            Text("\(Int(item.value))")
                                .font(.caption)
                                .padding(4)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(4)
                        }
                    }
                }
                .chartForegroundStyleScale(range: [.blue, .green, .orange, .purple, .red])
                .chartYScale(domain: 0...30)
                .frame(height: 300)
                .padding()
                .chartXAxis {
                    AxisMarks(preset: .aligned) { value in
                        if let category = value.as(String.self) {
                            AxisValueLabel {
                                Text(category)
                                    .rotationEffect(.degrees(90))
                                    .offset(y: 10)
                            }
                            AxisGridLine()
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .trailing, values: .automatic(desiredCount: 5)) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [5, 5]))
                        AxisValueLabel()
                    }
                }
                .chartLegend(position: .bottom)
                .chartOverlay { proxy in
                    GeometryReader { geometry in
                        Rectangle()
                            .fill(Color.clear)
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        let location = value.location
                                        if let category = proxy.value(atX: location.x, as: String.self),
                                           let group = proxy.value(atY: location.y, as: String.self) {
                                            selectedItem = sortedData.first(where: { 
                                                $0.category == category && $0.group == group 
                                            })
                                        }
                                    }
                                    .onEnded { _ in
                                        selectedItem = nil
                                    }
                            )
                    }
                }
                
                // カテゴリの合計値を表示（チャートの上部に配置）
                if showTotals {
                    HStack(spacing: 0) {
                        ForEach(Array(categoryTotals.keys.sorted()), id: \.self) { category in
                            if let total = categoryTotals[category] {
                                VStack {
                                    Text("\(Int(total))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 2)
                                        .background(Color.secondary.opacity(0.1))
                                        .cornerRadius(4)
                                    
                                    Text("合計")
                                        .font(.system(size: 8))
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .padding(.horizontal, 40) // チャートの左右のパディングに合わせる
                    .padding(.top, 10)
                    .zIndex(1)
                }
            }
            
            if let selected = selectedItem {
                VStack(alignment: .leading) {
                    Text("詳細情報")
                        .font(.headline)
                    
                    HStack {
                        Text("カテゴリー: \(selected.category)")
                        Spacer()
                        Text("グループ: \(selected.group)")
                    }
                    
                    Text("値: \(Int(selected.value))")
                    
                    if let total = categoryTotals[selected.category] {
                        Text("カテゴリー合計の \(Int(selected.value * 100 / total))%")
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
        .padding()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                    isAnimating = true
                }
            }
        }
    }
    
    // ソート順の列挙型
    enum SortOrder {
        case none, ascending, descending
    }
    
    // 後方互換性のためのイニシャライザ
    init(data: [GroupedBarData]) {
        self.data = data
    }
    
    init(tupleData: [(String, String, Double)]) {
        self.data = tupleData.map { GroupedBarData(category: $0.0, group: $0.1, value: $0.2) }
    }
}
