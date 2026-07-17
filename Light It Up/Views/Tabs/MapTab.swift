import SwiftUI
import MapKit

struct MapTab: View {
    @State private var sessions: [GameSession] = []
    
    // Filters raw history to map only sessions
    var mappedSessions: [GameSession] {
        sessions.filter { $0.latitude != nil && $0.longitude != nil }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if mappedSessions.isEmpty {
                    // instructions to get pins mapped
                    VStack(spacing: 16) {
                        Image(systemName: "map.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.accentColor)
                        
                        Text("No Game Locations Yet")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        
                        Text("Enable location permissions and complete games to see pins on the map!")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                } else {
                    // Native Map showing Pin Markers of sessions
                    Map {
                        ForEach(mappedSessions) { session in
                            Marker(
                                "\(session.mode.rawValue): \(session.score) pts",
                                coordinate: CLLocationCoordinate2D(
                                    latitude: session.latitude!,
                                    longitude: session.longitude!
                                )
                            )
                            .tint(Color.accentColor)
                        }
                    }
                    .mapStyle(.standard(elevation: .realistic))
                }
            }
            .navigationTitle("Location History")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Reload history and start GPS updates
                sessions = GameSessionStore.loadSessions()
                LocationService.shared.startUpdating()
            }
            .onDisappear {
                // Stop GPS updates on exit to save battery
                LocationService.shared.stopUpdating()
            }
        }
    }
}

#Preview {
    MapTab()
}
