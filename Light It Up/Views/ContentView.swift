import SwiftUI

struct ContentView: View {
    @AppStorage("IsUserLoggedIn") private var isUserLoggedIn = false
    @State private var isGuestMode = false
    
    // Theme
    @AppStorage("AppTheme") private var appTheme: AppTheme = .dark
    
    var body: some View {
        ZStack {
            if isUserLoggedIn || isGuestMode {
                // Main dashboard tab bar
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
                    
                    SettingsTab(isGuestMode: $isGuestMode) // Pass guest binding to handle Log Out
                        .tabItem {
                            Label("Settings", systemImage: "gear")
                        }
                }
                .tint(.accentColor)
                .onAppear {
                    // Request location permissions immediately on launch
                    LocationService.shared.requestPermission()
                }
            } else {
                // show the Login / Sign Up portal
                LoginView(isGuestMode: $isGuestMode)
                    .transition(.opacity)
            }
        }
        // Apply the color scheme preference globally to the entire view hierarchy
        .preferredColorScheme(appTheme.colorScheme)
    }
}

#Preview {
    ContentView()
}
