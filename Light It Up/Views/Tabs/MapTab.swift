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
    @State private var showHistorySheet: Bool = false
    
    @Environment(\.colorScheme) var colorScheme
    
    private var baseBackgroundColor: Color {
        colorScheme == .light ? Color(red: 0.95, green: 0.95, blue: 0.97) : Color.black
    }
    
    private var floatingContainerColor: Color {
        colorScheme == .light ? Color.white.opacity(0.85) : Color.black.opacity(0.75)
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
                // The Map takes up the FULL frame behind overlay controls
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
                .ignoresSafeArea(edges: .bottom)
                
                // Floating Segmented Filter Control at the top
                VStack {
                    Picker("Filter Game", selection: $selectedFilter) {
                        ForEach(GameMapFilter.allCases) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(floatingContainerColor)
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                    )
                    .padding()
                    
                    Spacer()
                }
                
                // Floating circular "Show History List" button in the bottom right corner
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showHistorySheet = true
                        }) {
                            Image(systemName: "list.bullet.clipboard.fill")
                                .font(.title2)
                                .foregroundColor(colorScheme == .light ? .white : .black)
                                .frame(width: 56, height: 56)
                                .background(Color.accentColor)
                                .clipShape(Circle())
                                .shadow(color: Color.accentColor.opacity(0.4), radius: 6, x: 0, y: 3)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 90) // raised to stay clear of the tabbar overlay
                    }
                }
                
                // Overlay message when history is completely empty
                if mappedSessions.isEmpty {
                    Color.black.opacity(0.6).ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        Image(systemName: "map.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.accentColor)
                        
                        Text("No Game Locations Yet")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        
                        Text("Enable location permissions and complete games to see pins on the map!")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .padding()
                }
            }
            .navigationTitle("Location History")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                sessions = GameSessionStore.loadSessions()
                LocationService.shared.startUpdating()
            }
            .onDisappear {
                LocationService.shared.stopUpdating()
            }
            // Present sheet drawer list with presentation detents (drawer slide-up tray)
            .sheet(isPresented: $showHistorySheet) {
                VStack(spacing: 0) {
                    // Drawer Header
                    Capsule()
                        .fill(Color.gray.opacity(0.4))
                        .frame(width: 36, height: 5)
                        .padding(.top, 8)
                        .padding(.bottom, 12)
                    
                    Text("GAME LOCATIONS HISTORY")
                        .font(.system(size: 11, weight: .bold).monospaced())
                        .foregroundColor(.secondary)
                        .padding(.bottom, 8)
                    
                    if filteredSessions.isEmpty {
                        Spacer()
                        Text("No records found for this game filter.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    } else {
                        List(filteredSessions) { session in
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.8)) {
                                    position = .camera(MapCamera(
                                        centerCoordinate: CLLocationCoordinate2D(
                                            latitude: session.latitude!,
                                            longitude: session.longitude!
                                        ),
                                        distance: 6000
                                    ))
                                }
                                showHistorySheet = false // Collapse map drawer to view the full screen map
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
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden) // Custom capsule is shown
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
