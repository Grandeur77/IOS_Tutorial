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
        .tint(.accentColor)
        .onAppear {
            // Request location permissions immediately on launch
            LocationService.shared.requestPermission()
        }
    }
}

#Preview {
    ContentView()
}
