import SwiftUI
import MapKit

enum GameMapFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case lightItUp = "Light It Up"
    case quizRush = "Quiz Rush"
    case tapFrenzy = "Tap Frenzy"
    
    var id: String { self.rawValue }
}

struct MapTab: View {
    @State private var sessions: [GameSession] = []
    @State private var selectedFilter: GameMapFilter = .all
    @State private var position: MapCameraPosition = .automatic
    
    @Environment(\.colorScheme) var colorScheme
    
    private var baseBackgroundColor: Color {
        colorScheme == .light ? Color(red: 0.95, green: 0.95, blue: 0.97) : Color.black
    }
    
    private var cardBackgroundColor: Color {
        colorScheme == .light ? Color(UIColor.secondarySystemGroupedBackground) : Color.white.opacity(0.03)
    }
    
    // Filters sessions that have location coordinates
    var mappedSessions: [GameSession] {
        sessions.filter { $0.latitude != nil && $0.longitude != nil }
    }
    
    // Filters based on the selected game filter picker
    var filteredSessions: [GameSession] {
        switch selectedFilter {
        case .all:
            return mappedSessions
        case .lightItUp:
            return mappedSessions.filter { $0.mode.rawValue.contains("Light It Up") }
        case .quizRush:
            return mappedSessions.filter { $0.mode == .quizRush }
        case .tapFrenzy:
            return mappedSessions.filter { $0.mode.rawValue.contains("Tap Frenzy") }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                baseBackgroundColor.ignoresSafeArea()
                
                if mappedSessions.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "map.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.accentColor)
                        
                        Text("No Game Locations Yet")
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                        
                        Text("Enable location permissions and complete games to see pins on the map!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                } else {
                    VStack(spacing: 0) {
                        // Game selection filter picker at the top
                        Picker("Filter Game", selection: $selectedFilter) {
                            ForEach(GameMapFilter.allCases) { filter in
                                Text(filter.rawValue).tag(filter)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding()
                        
                        // Map view showing pins
                        Map(position: $position) {
                            ForEach(filteredSessions) { session in
                                Marker(
                                    "\(session.mode.rawValue): \(session.score) pts",
                                    coordinate: CLLocationCoordinate2D(
                                        latitude: session.latitude!,
                                        longitude: session.longitude!
                                    )
                                )
                                .tint(colorForGameMode(session.mode))
                            }
                        }
                        .mapStyle(.standard(elevation: .realistic))
                        .frame(height: 300)
                        
                        // Interactive list of sessions
                        List(filteredSessions) { session in
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.8)) {
                                    position = .camera(MapCamera(
                                        centerCoordinate: CLLocationCoordinate2D(
                                            latitude: session.latitude!,
                                            longitude: session.longitude!
                                        ),
                                        distance: 8000
                                    ))
                                }
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(colorForGameMode(session.mode))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(session.mode.rawValue)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        Text(String(format: "Score: %d • Lat: %.3f, Lon: %.3f", session.score, session.latitude!, session.longitude!))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text(formatDate(session.timestamp))
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .listStyle(.plain)
                    }
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
    
    // Assign specific theme colors per game mode
    private func colorForGameMode(_ mode: GameMode) -> Color {
        let raw = mode.rawValue
        if raw.contains("Light It Up") {
            return .yellow
        } else if raw.contains("Quiz Rush") {
            return .cyan
        } else if raw.contains("Tap Frenzy") {
            return .orange
        }
        return .blue
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    MapTab()
}
