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
    @State private var selectedChartMode: GameModeCategory = .tapFrenzy
    @State private var selectedLeaderboardMode: GameModeCategory = .tapFrenzy

    func colorForGameName(_ name: String) -> Color {
        switch name {
        case "Light It Up": return .accentColor
        case "Quiz Rush": return .purple
        case "Tap Frenzy": return .yellow
        default: return .gray
        }
    }
    
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
                        
                        // Trend Bar Chart Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("SCORE TREND (LAST 10 GAMES)")
                                .font(.system(size: 11, weight: .bold).monospaced())
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                          
                            HStack(spacing: 8) {
                                ForEach(GameModeCategory.allCases) { category in
                                    Button(action: {
                                        selectedChartMode = category
                                    }) {
                                        Text(category.rawValue)
                                            .font(.caption.bold())
                                            .foregroundColor(selectedChartMode == category ? .black : .white)
                                            .padding(.vertical, 8)
                                            .frame(maxWidth: .infinity)
                                            .background(selectedChartMode == category ? Color.accentColor : Color.white.opacity(0.06))
                                            .cornerRadius(8)
                                    }
                                }
                            }
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
                                .chartXAxis {
                                    AxisMarks(values: .automatic) { _ in
                                        AxisValueLabel()
                                            .foregroundStyle(Color.white.opacity(0.8))
                                    }
                                }
                                .chartYAxis {
                                    AxisMarks(values: .automatic) { _ in
                                        AxisGridLine()
                                            .foregroundStyle(Color.white.opacity(0.1))
                                        AxisValueLabel()
                                            .foregroundStyle(Color.white.opacity(0.8))
                                    }
                                }
                                .frame(height: 180)
                                .padding()
                                .background(Color.white.opacity(0.03))
                                .cornerRadius(14)
                                .padding(.horizontal)
                            }
                        }
                        
                        // 3. Donut Chart Section
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
                                VStack(spacing: 12) {
                                    Chart(viewModel.gameDistribution) { item in
                                        SectorMark(
                                            angle: .value("Games Played", item.count),
                                            innerRadius: .ratio(0.6),
                                            angularInset: 2.0
                                        )
                                        .foregroundStyle(colorForGameName(item.name))
                                        .cornerRadius(6)
                                    }
                                    .chartLegend(.hidden)
                                    .frame(height: 160)
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        ForEach(viewModel.gameDistribution) { item in
                                            HStack(spacing: 8) {
                                                Circle()
                                                    .fill(colorForGameName(item.name))
                                                    .frame(width: 8, height: 8)
                                                
                                                Text(item.name)
                                                    .font(.caption.bold())
                                                    .foregroundColor(.white)
                                                
                                                Spacer()
                                                
                                                let percent = Double(item.count) / Double(viewModel.totalGamesPlayed) * 100
                                                Text(String(format: "%.0f%% (%d games)", percent, item.count))
                                                    .font(.caption.monospacedDigit())
                                                    .foregroundColor(.yellow)
                                            }
                                            .padding(.horizontal, 8)
                                        }
                                    }
                                    .padding(.top, 4)
                                }
                                .padding()
                                .background(Color.white.opacity(0.03))
                                .cornerRadius(14)
                                .padding(.horizontal)
                            }
                        }
                        
                        // Dynamic Leaderboard Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("LEADERBOARD STANDINGS")
                                .font(.system(size: 11, weight: .bold).monospaced())
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                            
                            // Game buttons segment selector
                            HStack(spacing: 8) {
                                ForEach(GameModeCategory.allCases) { category in
                                    Button(action: {
                                        withAnimation {
                                            selectedLeaderboardMode = category
                                        }
                                    }) {
                                        Text(category.rawValue)
                                            .font(.caption.bold())
                                            .foregroundColor(selectedLeaderboardMode == category ? .black : .white)
                                            .padding(.vertical, 8)
                                            .frame(maxWidth: .infinity)
                                            .background(selectedLeaderboardMode == category ? Color.accentColor : Color.white.opacity(0.06))
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            let leaderboardData = viewModel.leaderboard(for: selectedLeaderboardMode)
                            
                            if leaderboardData.isEmpty {
                                VStack {
                                    Text("No leaderboard records yet")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .frame(height: 150)
                                .frame(maxWidth: .infinity)
                                .background(Color.white.opacity(0.03))
                                .cornerRadius(14)
                                .padding(.horizontal)
                            } else {
                                VStack(spacing: 10) {
                                    ForEach(Array(leaderboardData.enumerated()), id: \.element.id) { index, entry in
                                        LeaderboardRow(rank: index + 1, entry: entry)
                                    }
                                }
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
                    .padding(.top, 24)
                    .padding(.bottom, 110)
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

// Leaderboard Row Component
struct LeaderboardRow: View {
    let rank: Int
    let entry: LeaderboardEntry
    
    var body: some View {
        HStack(spacing: 16) {
            // Rank Badge
            ZStack {
                if rank <= 3 {
                    Image(systemName: "crown.fill")
                        .font(.title3)
                        .foregroundColor(rankColor)
                } else {
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 28, height: 28)
                    Text("\(rank)")
                        .font(.caption.bold())
                        .foregroundColor(.gray)
                }
            }
            .frame(width: 32, height: 32)
            
            Text(entry.username)
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
            
            Text("\(entry.score) pts")
                .font(.system(.body, design: .monospaced).bold())
                .foregroundColor(rank <= 3 ? .yellow : .white.opacity(0.8))
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(rank <= 3 ? Color.yellow.opacity(0.08) : Color.white.opacity(0.04))
                .cornerRadius(8)
        }
        .padding()
        .background(Color.white.opacity(0.03))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return .yellow // Gold
        case 2: return .gray.opacity(0.8)
        case 3: return .orange.opacity(0.8)
        default: return .clear
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
