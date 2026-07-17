import SwiftUI
import Charts

enum GameModeCategory: String, CaseIterable, Identifiable {
    case tapFrenzy = "Tap Frenzy"
    case lightItUp = "Light It Up"
    case quizRush = "Quiz Rush"
    
    var id: String { self.rawValue }
}

// Main Stats Tab View
struct StatsTab: View {
    @StateObject private var viewModel = StatsVM()
    @State private var selectedChartMode: GameModeCategory = .tapFrenzy // Selected chart mode
    
    // Raw session history based on the selected picker category
    var filteredSessions: [GameSession] {
        viewModel.sessions.filter { session in
            switch selectedChartMode {
            case .tapFrenzy:
                return session.mode.rawValue.contains("Tap Frenzy")
            case .lightItUp:
                return session.mode == .lightItUp
            case .quizRush:
                return session.mode == .quizRush
            }
        }
    }
    
    var body: some View {
            NavigationStack {
                ZStack {
                    Color.black.ignoresSafeArea()
                    
                    ScrollView {
                        VStack(spacing: 28) {
                            
                            // High-Level Summary Cards
                            HStack(spacing: 16) {
                                StatSummaryCard(
                                    title: "Total Games",
                                    value: "\(viewModel.totalGamesPlayed)",
                                    icon: "gamecontroller.fill",
                                    color: .accentColor
                                )
                                
                                StatSummaryCard(
                                    title: "Avg Score",
                                    value: String(format: "%.1f", viewModel.averageScore),
                                    icon: "chart.bar.fill",
                                    color: .yellow
                                )
                            }
                            .padding(.horizontal)
                            
                            // Bar Chart Section (session improvements)
                            VStack(alignment: .leading, spacing: 16) {
                                Text("SCORE TREND (LAST 10 GAMES)")
                                    .font(.system(size: 11, weight: .bold).monospaced())
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                                
                                Picker("Game Mode", selection: $selectedChartMode) {
                                    ForEach(GameModeCategory.allCases) { category in
                                        Text(category.rawValue).tag(category)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .padding(.horizontal)
                                
                                if filteredSessions.isEmpty {
                                    VStack {
                                        Text("No sessions played yet in this mode")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .frame(height: 180)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.white.opacity(0.03))
                                    .cornerRadius(14)
                                    .padding(.horizontal)
                                } else {
                                    Chart {
                                        ForEach(Array(filteredSessions.suffix(10).enumerated()), id: \.offset) { index, session in
                                            BarMark(
                                                x: .value("Game", "G\(index + 1)"),
                                                y: .value("Score", session.score)
                                            )
                                            .foregroundStyle(Color.accentColor.gradient)
                                            .cornerRadius(4)
                                        }
                                    }
                                    .frame(height: 180)
                                    .padding()
                                    .background(Color.white.opacity(0.03))
                                    .cornerRadius(14)
                                    .padding(.horizontal)
                                }
                            }
                            
                            // Donut Chart Section (game play distribution)
                            VStack(alignment: .leading, spacing: 16) {
                                Text("GAME PLAY POPULARITY (DISTRIBUTION)")
                                    .font(.system(size: 11, weight: .bold).monospaced())
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                                
                                if viewModel.gameDistribution.isEmpty {
                                    VStack {
                                        Text("Play a game to see distribution stats")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .frame(height: 180)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.white.opacity(0.03))
                                    .cornerRadius(14)
                                    .padding(.horizontal)
                                } else {
                                    Chart(viewModel.gameDistribution) { item in
                                
                                        SectorMark(
                                            angle: .value("Games Played", item.count),
                                            innerRadius: .ratio(0.6),
                                            angularInset: 2.0
                                        )
                                        .foregroundStyle(by: .value("Game", item.name))
                                        .cornerRadius(6)
                                    }
                                    .frame(height: 180)
                                    .padding()
                                    .background(Color.white.opacity(0.03))
                                    .cornerRadius(14)
                                    .padding(.horizontal)
                                }
                            }
                            
                            // Personal Bests Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("PERSONAL BESTS")
                                    .font(.system(size: 11, weight: .bold).monospaced())
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                                
                                VStack(spacing: 12) {
                                    PersonalBestRow(
                                        title: "Light It Up",
                                        score: viewModel.personalBest(for: .lightItUp),
                                        icon: "lightbulb.fill",
                                        color: .accentColor
                                    )
                                    
                                    PersonalBestRow(
                                        title: "Quiz Rush",
                                        score: viewModel.personalBest(for: .quizRush),
                                        icon: "questionmark.circle.fill",
                                        color: .accentColor
                                    )
                                    
                                    PersonalBestRow(
                                        title: "Tap Frenzy",
                                        score: max(
                                            viewModel.personalBest(for: .tapFrenzyDefault),
                                            viewModel.personalBest(for: .tapFrenzyCombo),
                                            viewModel.personalBest(for: .tapFrenzyTrap),
                                            viewModel.personalBest(for: .tapFrenzyMoving),
                                            viewModel.personalBest(for: .tapFrenzyShrinking),
                                            viewModel.personalBest(for: .tapFrenzyBurst)
                                        ),
                                        icon: "hand.tap.fill",
                                        color: .accentColor
                                    )
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top)
                        .padding(.bottom, 20)
                    }
                }
                .navigationTitle("Arcade Stats")
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    viewModel.refresh()
                }
            }
        }
    }

// Summary Card Component
struct StatSummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.subheadline)
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.04))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}

// Personal Best Row Component
struct PersonalBestRow: View {
    let title: String
    let score: Int
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.12))
                .cornerRadius(10)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: "crown.fill")
                    .font(.caption2)
                    .foregroundColor(.yellow)
                Text("\(score)")
                    .font(.system(.body, design: .monospaced).bold())
                    .foregroundColor(.yellow)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(Color.yellow.opacity(0.08))
            .cornerRadius(8)
        }
        .padding()
        .background(Color.white.opacity(0.04))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}
