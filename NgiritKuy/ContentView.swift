//
//  ContentView.swift
//  NgiritKuy2
//
//  Created by Ivan Setiawan on 14/05/25.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Explore GOP", systemImage: "list.clipboard.fill") {
                ExploreGOPView()
            }
            
            Tab("Nearby", systemImage: "location.fill") {
                FindNearbyView()
            }
            
        }
        .accentColor(.orange)
        .backgroundStyle(.clear)
    }
}

#Preview {
    ContentView()
}
