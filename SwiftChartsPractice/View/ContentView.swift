//
//  ContentView.swift
//  SwiftChartsPractice
//
//  Created by 林明虎 on 2025/03/09.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedMark: MarkType = .bar
    @State private var showDrawer = false

    var body: some View {
        ZStack(alignment: .leading) {
            
            NavigationView {
                VStack {
                    Spacer()
                    
                    selectedMark.view
                    
                    Spacer()
                }
                .navigationTitle("Swift Charts")
                .navigationBarItems(leading: Button(action: {
                    withAnimation {
                        showDrawer.toggle()
                    }
                }) {
                    Image(systemName: "line.horizontal.3")
                        .imageScale(.large)
                })
            }

            // マスク (Drawer が開いたときのみ表示)
            if showDrawer {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            showDrawer = false
                        }
                    }
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: showDrawer)
            }

            // Drawer (左端に配置)
            DrawerMenu(selectedMark: $selectedMark, showDrawer: $showDrawer)
                .frame(width: 250)
                .background(Color(.systemBackground))
                .offset(x: showDrawer ? 0 : -250)
                .animation(.easeInOut(duration: 0.3), value: showDrawer)
        }
    }
}
