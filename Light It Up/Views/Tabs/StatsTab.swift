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
    
    @Environment(\.colorScheme) var colorScheme
    
    private var baseBackgroundColor: Color {
        colorScheme == .light ? Color(red: 0.95, green: 0.95, blue: 0.97) : Color.black
    }
    
    private var cardBackgroundColor: Color {
        colorScheme == .light ? Color(UIColor.secondarySystemGroupedBackground) : Color.white.opacity(0.03)
    }
    
    private var cardBorderColor: Color {
        colorScheme == .light ? Color.black.opacity(0.06) : Color.white.opacity(0.05)
    }
    
    private var headerTextColor: Color {
        colorScheme == .light ? Color.orange : Color.yellow
    }
    
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
                baseBackgroundColor.ignoresSafeArea()
                
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
                        
                        // Score Trend Bar Chart
                        VStack(alignment: .leading, spacing: 16) {
                            Text("SCORE TREND (LAST 10 GAMES)")
                                .font(.system(size: 11, weight: .bold).monospaced())
                                .foregroundColor(headerTextColor)
                                .padding(.horizontal)
                            
                            HStack(spacing: 8) {
                                ForEach(GameModeCategory.allCases) { category in
                                    Button(action: {
                                        selectedChartMode = category
                                    }) {
                                        Text(category.rawValue)
                                            .font(.caption.bold())
                                            .foregroundColor(selectedChartMode == category ? (colorScheme == .light ? .white : .black) : (colorScheme == .light ? .primary : .white))
                                            .padding(.vertical, 8)
                                            .frame(maxWidth: .infinity)
                                            .background(selectedChartMode == category ? Color.accentColor : (colorScheme == .light ? Color.black.opacity(0.05) : Color.white.opacity(0.06)))
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            if filteredSessions.isEmpty {
                                VStack {
                                    Text("No sessions played yet in this mode")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .frame(height: 180)
                                .frame(maxWidth: .infinity)
                                .background(cardBackgroundColor)
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .strokeBorder(cardBorderColor, lineWidth: 1)
                                )
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
                                            .foregroundStyle(Color.primary.opacity(0.8))
                                    }
                                }
                                .chartYAxis {
                                    AxisMarks(values: .automatic) { _ in
                                        AxisGridLine()
                                            .foregroundStyle(colorScheme == .light ? Color.black.opacity(0.1) : Color.white.opacity(0.1))
                                        AxisValueLabel()
                                            .foregroundStyle(Color.primary.opacity(0.8))
                                    }
                                }
                                .frame(height: 180)
                                .padding()
                                .background(cardBackgroundColor)
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .strokeBorder(cardBorderColor, lineWidth: 1)
                                )
                                .padding(.horizontal)
                            }
                        }
                        
                        // Donut Distribution Chart Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("GAME PLAY POPULARITY (DISTRIBUTION)")
                                .font(.system(size: 11, weight: .bold).monospaced())
                                .foregroundColor(headerTextColor)
                                .padding(.horizontal)
                            
                            if viewModel.gameDistribution.isEmpty {
                                VStack {
                                    Text("Play a game to see distribution stats")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .frame(height: 180)
                                .frame(maxWidth: .infinity)
                                .background(cardBackgroundColor)
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .strokeBorder(cardBorderColor, lineWidth: 1)
                                )
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
                                                    .foregroundColor(.primary)
                                                
                                                Spacer()
                                                
                                                let percent = Double(item.count) / Double(viewModel.totalGamesPlayed) * 100
                                                Text(String(format: "%.0f%% (%d games)", percent, item.count))
                                                    .font(.caption.monospacedDigit())
                                                    .foregroundColor(headerTextColor)
                                            }
                                            .padding(.horizontal, 8)
                                        }
                                    }
                                    .padding(.top, 4)
                                }
                                .padding()
                                .background(cardBackgroundColor)
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .strokeBorder(cardBorderColor, lineWidth: 1)
                                )
                                .padding(.horizontal)
                            }
                        }
                        
                        // Leaderboard standings
                        VStack(alignment: .leading, spacing: 16) {
                            Text("LEADERBOARD STANDINGS")
                                .font(.system(size: 11, weight: .bold).monospaced())
                                .foregroundColor(headerTextColor)
                                .padding(.horizontal)
                            
                            HStack(spacing: 8) {
                                ForEach(GameModeCategory.allCases) { category in
                                    Button(action: {
                                        withAnimation {
                                            selectedLeaderboardMode = category
                                        }
                                    }) {
                                        Text(category.rawValue)
                                            .font(.caption.bold())
                                            .foregroundColor(selectedLeaderboardMode == category ? (colorScheme == .light ? .white : .black) : (colorScheme == .light ? .primary : .white))
                                            .padding(.vertical, 8)
                                            .frame(maxWidth: .infinity)
                                            .background(selectedLeaderboardMode == category ? Color.accentColor : (colorScheme == .light ? Color.black.opacity(0.05) : Color.white.opacity(0.06)))
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
                                        .foregroundColor(.secondary)
                                }
                                .frame(height: 150)
                                .frame(maxWidth: .infinity)
                                .background(cardBackgroundColor)
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .strokeBorder(cardBorderColor, lineWidth: 1)
                                )
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
                        
                        // Personal Bests
                        VStack(alignment: .leading, spacing: 16) {
                            Text("PERSONAL BESTS")
                                .font(.system(size: 11, weight: .bold).monospaced())
                                .foregroundColor(headerTextColor)
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
    
    @Environment(\.colorScheme) var colorScheme
    
    private var rowBackgroundColor: Color {
        colorScheme == .light ? Color(UIColor.secondarySystemGroupedBackground) : Color.white.opacity(0.03)
    }
    
    private var rowBorderColor: Color {
        colorScheme == .light ? Color.black.opacity(0.06) : Color.white.opacity(0.05)
    }
    
    private var highlightColor: Color {
        colorScheme == .light ? Color.orange : Color.yellow
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return colorScheme == .light ? .orange : .yellow
        case 2: return .gray.opacity(0.8)
        case 3: return .orange.opacity(0.8)
        default: return colorScheme == .light ? Color.black.opacity(0.05) : Color.white.opacity(0.05)
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                if rank <= 3 {
                    Image(systemName: "crown.fill")
                        .font(.title3)
                        .foregroundColor(rankColor)
                } else {
                    Circle()
                        .fill(colorScheme == .light ? Color.black.opacity(0.05) : Color.white.opacity(0.08))
                        .frame(width: 28, height: 28)
                    Text("\(rank)")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 32, height: 32)
            
            Text(entry.username)
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text("\(entry.score) pts")
                .font(.system(.body, design: .monospaced).bold())
                .foregroundColor(rank <= 3 ? highlightColor : (colorScheme == .light ? .primary.opacity(0.8) : .white.opacity(0.8)))
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(rank <= 3 ? highlightColor.opacity(0.08) : (colorScheme == .light ? Color.black.opacity(0.04) : Color.white.opacity(0.04)))
                .cornerRadius(8)
        }
        .padding()
        .background(rowBackgroundColor)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(
                    LinearGradient(
                        colors: [rankColor.opacity(0.4), rowBorderColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

// Summary Card Component
struct StatSummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    @Environment(\.colorScheme) var colorScheme
    
    private var cardBackgroundColor: Color {
        colorScheme == .light ? Color(UIColor.secondarySystemGroupedBackground) : Color.white.opacity(0.03)
    }
    
    private var cardBorderColor: Color {
        colorScheme == .light ? Color.black.opacity(0.06) : Color.white.opacity(0.05)
    }
    
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
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(cardBackgroundColor)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    LinearGradient(
                        colors: [color.opacity(0.4), cardBorderColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

// Personal Best Row Component
struct PersonalBestRow: View {
    let title: String
    let score: Int
    let icon: String
    let color: Color
    
    @Environment(\.colorScheme) var colorScheme
    
    private var rowBackgroundColor: Color {
        colorScheme == .light ? Color(UIColor.secondarySystemGroupedBackground) : Color.white.opacity(0.03)
    }
    
    private var rowBorderColor: Color {
        colorScheme == .light ? Color.black.opacity(0.06) : Color.white.opacity(0.05)
    }
    
    private var highlightColor: Color {
        colorScheme == .light ? Color.orange : Color.yellow
    }
    
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
                .foregroundColor(.primary)
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: "crown.fill")
                    .font(.caption2)
                    .foregroundColor(highlightColor)
                Text("\(score)")
                    .font(.system(.body, design: .monospaced).bold())
                    .foregroundColor(highlightColor)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(highlightColor.opacity(0.08))
            .cornerRadius(8)
        }
        .padding()
        .background(rowBackgroundColor)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(
                    LinearGradient(
                        colors: [color.opacity(0.3), rowBorderColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}
