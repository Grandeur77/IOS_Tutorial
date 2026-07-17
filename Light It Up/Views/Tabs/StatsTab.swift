import SwiftUI

struct StatsTab: View {
    @StateObject private var viewModel = StatsVM()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 28) {
                        
                        // High-Level Summary Cards (Horizontal scroll)
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
                        
                        // Personal Bests Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("PERSONAL BESTS")
                                .font(.system(size: 12, weight: .bold).monospaced())
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
                                
                                // Displays the best score
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

// Personal Best List Row
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
