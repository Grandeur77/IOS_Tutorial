import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeTab()
                .tabItem {
                    Label("Home", systemImage: "gamecontroller")
                }
            
            StatsTab()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar")
                }
            
            MapTab()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
            
            SettingsTab()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        // Tint color applies a unified theme to the active tab item
        .tint(.accentColor)
    }
}

#Preview {
    ContentView()
}
