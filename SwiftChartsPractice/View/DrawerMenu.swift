//
//  DrawerMenu.swift
//  SwiftChartsPractice
//
//  Created by 林明虎 on 2025/03/09.
//

import SwiftUI

struct DrawerMenu: View {
    @Binding var selectedMark: MarkType
    @Binding var showDrawer: Bool
    
    var body: some View {
        List(MarkType.allCases) { mark in
            Button(action: {
                selectedMark = mark
                withAnimation {
                    showDrawer = false
                }
            }) {
                Text(mark.rawValue)
                    .font(.headline)
            }
        }
        .frame(maxWidth: 250)
        .background(Color(.systemBackground))
    }
}
