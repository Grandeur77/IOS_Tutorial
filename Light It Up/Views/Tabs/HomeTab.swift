import SwiftUI
import Combine

struct DailyChallenge: Identifiable {
    let id = UUID()
    let game: GameType
    let title: String
    let description: String
    let targetScore: Int
    let currentScore: Int
    let imageName: String
    let iconName: String
    
    var isCompleted: Bool {
        currentScore >= targetScore
    }
    
    var progressFraction: Double {
        guard targetScore > 0 else { return 0.0 }
        return min(Double(currentScore) / Double(targetScore), 1.0)
    }
}

struct HomeTab: View {
    @State private var selection: GameType? = nil
    @State private var activeIndex: Int = 0
    @StateObject private var statsVM = StatsVM()
    
    private let timer = Timer.publish(every: 4.0, on: .main, in: .common).autoconnect()
    
    @Environment(\.colorScheme) var colorScheme
    
    private var baseBackgroundColor: Color {
        colorScheme == .light ? Color(red: 0.95, green: 0.95, blue: 0.97) : Color.black
    }
    
    private var titleColor: Color {
        colorScheme == .light ? Color.orange : Color.yellow
    }
    
    // Read high scores for all Tap Frenzy sub-modes
    @AppStorage("TapFrenzyHighScore_Default") private var tfDefaultScore: Int = 0
    @AppStorage("TapFrenzyHighScore_Combo System") private var tfComboScore: Int = 0
    @AppStorage("TapFrenzyHighScore_Trap Colour") private var tfTrapScore: Int = 0
    @AppStorage("TapFrenzyHighScore_Moving Target") private var tfMovingScore: Int = 0
    @AppStorage("TapFrenzyHighScore_Shrinking Button") private var tfShrinkingScore: Int = 0
    @AppStorage("AppStorageKeyForTapFrenzyHighScore_Bonus Burst") private var tfBurstScore: Int = 0
    
    // Calculates highest score across Tap Frenzy
    var highestTapFrenzyScore: Int {
        max(tfDefaultScore, tfComboScore, tfTrapScore, tfMovingScore, tfShrinkingScore, tfBurstScore)
    }
    
    // Read high scores for other modes
    @AppStorage("LightItUpHighScore") private var lightItUpScore: Int = 0
    @AppStorage("QuizRushHighScore") private var quizRushScore: Int = 0
    
    private var dailyChallenges: [DailyChallenge] {
        [
            DailyChallenge(
                game: .tapFrenzy,
                title: "Tap Frenzy Blitz",
                description: "Score 150 points in Tap Frenzy!",
                targetScore: 150,
                currentScore: highestTapFrenzyScore,
                imageName: "tap_frenzy_carousel",
                iconName: "hand.tap.fill"
            ),
            DailyChallenge(
                game: .lightItUp,
                title: "Light It Up Focus",
                description: "Reach 80 points in Light It Up!",
                targetScore: 80,
                currentScore: lightItUpScore,
                imageName: "light_it_up_carousel",
                iconName: "lightbulb.fill"
            ),
            DailyChallenge(
                game: .quizRush,
                title: "Quiz Rush Scholar",
                description: "Score 50 points in Quiz Rush!",
                targetScore: 50,
                currentScore: quizRushScore,
                imageName: "quiz_rush_carousel",
                iconName: "questionmark.circle.fill"
            )
        ]
    }
    
    private func gameDisplayName(for game: GameType) -> String {
        switch game {
        case .tapFrenzy: return "Tap Frenzy"
        case .lightItUp: return "Light It Up"
        case .quizRush: return "Quiz Rush"
        }
    }
    
    private func themeColor(for game: GameType) -> Color {
        switch game {
        case .tapFrenzy:
            return .orange
        case .lightItUp:
            return colorScheme == .light ? Color(red: 0.85, green: 0.65, blue: 0.0) : .yellow
        case .quizRush:
            return colorScheme == .light ? .blue : .cyan
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                baseBackgroundColor.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        
                        // Top Header Title Section
                        VStack(spacing: 8) {
                            Text("GAME ARCADIA")
                                .font(.system(size: 30, weight: .black, design: .monospaced))
                                .tracking(8)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.yellow, Color.blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                            
                            HStack(spacing: 6) {
                                Rectangle()
                                    .fill(LinearGradient(colors: [.yellow, .clear], startPoint: .trailing, endPoint: .leading))
                                    .frame(height: 1)
                                
                                Text("Mind Games")
                                    .font(.system(size: 9, weight: .black, design: .monospaced))
                                    .foregroundColor(colorScheme == .light ? .secondary : .gray)
                                    .tracking(4)
                                    .multilineTextAlignment(.center)
                                
                                Rectangle()
                                    .fill(LinearGradient(colors: [.yellow, .clear], startPoint: .leading, endPoint: .trailing))
                                    .frame(height: 1)
                            }
                            .frame(maxWidth: 240)
                        }
                        .padding(.top, 20)
                        
                        // TabView Carousel (Clean card artwork + Top-Right High Score badge)
                        TabView(selection: $activeIndex) {
                            ForEach(0..<dailyChallenges.count, id: \.self) { index in
                                let challenge = dailyChallenges[index]
                                ChallengeCard(challenge: challenge) {
                                    selection = challenge.game
                                }
                                .tag(index)
                                .padding(.horizontal, 20)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                        .frame(height: 240)
                        .onReceive(timer) { _ in
                            withAnimation(.easeInOut(duration: 0.6)) {
                                activeIndex = (activeIndex + 1) % dailyChallenges.count
                            }
                        }
                        
                        // Quick Select Buttons
                        VStack(alignment: .leading, spacing: 12) {
                            Text("QUICK SELECT")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(colorScheme == .light ? .secondary : .gray)
                                .tracking(3)
                                .padding(.horizontal, 24)
                            
                            HStack(spacing: 14) {
                                ForEach(0..<dailyChallenges.count, id: \.self) { index in
                                    let challenge = dailyChallenges[index]
                                    Button(action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                            activeIndex = index
                                        }
                                        // Tiny delay to allow carousel translation transition to start
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                            selection = challenge.game
                                        }
                                    }) {
                                        VStack(spacing: 8) {
                                            Image(systemName: challenge.iconName)
                                                .font(.system(size: 20, weight: .bold))
                                                .foregroundColor(themeColor(for: challenge.game))
                                                .frame(width: 46, height: 46)
                                                .background(
                                                    Circle()
                                                        .fill(themeColor(for: challenge.game).opacity(0.1))
                                                )
                                                .overlay(
                                                    Circle()
                                                        .strokeBorder(
                                                            themeColor(for: challenge.game).opacity(activeIndex == index ? 0.8 : 0.2),
                                                            lineWidth: activeIndex == index ? 2 : 1
                                                        )
                                                )
                                                .shadow(color: themeColor(for: challenge.game).opacity(activeIndex == index ? 0.3 : 0), radius: 4)
                                            
                                            Text(gameDisplayName(for: challenge.game))
                                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                                .foregroundColor(.primary)
                                                .lineLimit(1)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(colorScheme == .light ? Color(UIColor.secondarySystemGroupedBackground) : Color.white.opacity(0.03))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .strokeBorder(
                                                    activeIndex == index
                                                    ? themeColor(for: challenge.game).opacity(0.4)
                                                    : (colorScheme == .light ? Color.black.opacity(0.05) : Color.white.opacity(0.06)),
                                                    lineWidth: activeIndex == index ? 1.5 : 1
                                                )
                                        )
                                        .scaleEffect(activeIndex == index ? 1.03 : 1.0)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Arcade Stats Quick Look Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("YOUR ARCADE SUMMARY")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(colorScheme == .light ? .secondary : .gray)
                                .tracking(3)
                                .padding(.horizontal, 24)
                            
                            HStack(spacing: 12) {
                                StatMiniBox(
                                    title: "Played",
                                    value: "\(statsVM.totalGamesPlayed)",
                                    iconName: "gamecontroller.fill",
                                    color: .accentColor
                                )
                                
                                StatMiniBox(
                                    title: "Avg Score",
                                    value: String(format: "%.0f", statsVM.averageScore),
                                    iconName: "chart.bar.fill",
                                    color: .yellow
                                )
                                
                                StatMiniBox(
                                    title: "Total Peak",
                                    value: "\(highestTapFrenzyScore + lightItUpScore + quizRushScore)",
                                    iconName: "crown.fill",
                                    color: .orange
                                )
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        Spacer(minLength: 24)
                    }
                }
            }
            .onAppear {
                statsVM.refresh()
            }
            .navigationDestination(isPresented: Binding(get: { selection == .tapFrenzy }, set: { if !$0 { selection = nil } })) {
                TapFrenzyView()
            }
            .navigationDestination(isPresented: Binding(get: { selection == .lightItUp }, set: { if !$0 { selection = nil } })) {
                LightItUpView()
            }
            .navigationDestination(isPresented: Binding(get: { selection == .quizRush }, set: { if !$0 { selection = nil } })) {
                QuizRushView()
            }
        }
    }
    
    private func gameTypeFromIndex(_ index: Int) -> GameType {
        switch index {
        case 0: return .tapFrenzy
        case 1: return .lightItUp
        default: return .quizRush
        }
    }
}

// Beautiful Clean Carousel Card Component
struct ChallengeCard: View {
    let challenge: DailyChallenge
    let action: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottom) {
                // High-contrast, minimal generated image matching dark yellow & blue theme
                Image(challenge.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
                
                // Dark gradient overlay to make text highly readable at the bottom
                LinearGradient(
                    gradient: Gradient(colors: [
                        .clear,
                        .black.opacity(0.4),
                        .black.opacity(0.85)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // Content Stack spanning full card
                VStack(alignment: .leading, spacing: 0) {
                    // Top row: Badges
                    HStack {
                        // "DAILY CHALLENGE" glassmorphic tag
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.orange)
                            Text("DAILY CHALLENGE")
                                .font(.system(size: 9, weight: .black, design: .monospaced))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.3))
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color.orange.opacity(0.4), lineWidth: 1)
                        )
                        
                        Spacer()
                        
                        // Progress / Completion badge
                        HStack(spacing: 4) {
                            if challenge.isCompleted {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.green)
                                Text("COMPLETED")
                                    .font(.system(size: 9, weight: .black, design: .monospaced))
                                    .foregroundColor(.green)
                            } else {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(.yellow)
                                Text("\(challenge.currentScore)/\(challenge.targetScore)")
                                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(challenge.isCompleted ? Color.green.opacity(0.2) : Color.black.opacity(0.6))
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(challenge.isCompleted ? Color.green.opacity(0.4) : Color.white.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .padding(.top, 14)
                    .padding(.horizontal, 14)
                    
                    Spacer()
                    
                    // Info overlay (Title, Description, Progress Bar)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(challenge.title.uppercased())
                            .font(.system(size: 18, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                        
                        Text(challenge.description)
                            .font(.system(size: 11, weight: .semibold, design: .default))
                            .foregroundColor(.white.opacity(0.85))
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                        
                        // Sleek Progress Bar
                        VStack(spacing: 4) {
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(Color.white.opacity(0.25))
                                    
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: challenge.isCompleted ? [Color.green, Color.green.opacity(0.7)] : [Color.orange, Color.yellow]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: geo.size.width * CGFloat(challenge.progressFraction))
                                }
                            }
                            .frame(height: 6)
                            
                            HStack {
                                Spacer()
                                Text("\(Int(challenge.progressFraction * 100))%")
                                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
            .frame(height: 200)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        LinearGradient(
                            colors: [.yellow.opacity(0.4), .blue.opacity(0.4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(CarouselButtonStyle())
    }
}

struct CarouselButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// Stats Small Quick-look box
struct StatMiniBox: View {
    let title: String
    let value: String
    let iconName: String
    let color: Color
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: iconName)
                .font(.system(size: 16))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.primary)
            
            Text(title.uppercased())
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(colorScheme == .light ? Color(UIColor.secondarySystemGroupedBackground) : Color.white.opacity(0.02))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(colorScheme == .light ? Color.black.opacity(0.04) : Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}


