import SwiftUI

// MARK: - Confetti Particle Struct
struct ConfettiParticle: Identifiable {
    let id = UUID()
    let color: Color
    let size: CGFloat
    var xOffset: CGFloat
    var yOffset: CGFloat
    var rotation: Double
}

// MARK: - Custom Confetti View
struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    let colors: [Color] = [.red, .blue, .green, .yellow, .pink, .purple, .orange]
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    Rectangle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .rotationEffect(.degrees(particle.rotation))
                        .position(x: particle.xOffset, y: particle.yOffset)
                }
            }
            .onAppear {
                generateParticles(width: geo.size.width, height: geo.size.height)
                triggerAnimation(height: geo.size.height)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false) // Allows tapping buttons underneath the falling particles
    }
    
    private func generateParticles(width: CGFloat, height: CGFloat) {
        var temp: [ConfettiParticle] = []
        for _ in 0..<100 { // 100 pieces of confetti
            let size = CGFloat.random(in: 6...14)
            let particle = ConfettiParticle(
                color: colors.randomElement() ?? .red,
                size: size,
                xOffset: CGFloat.random(in: 0...width),
                yOffset: CGFloat.random(in: -height...0), // Start offscreen
                rotation: Double.random(in: 0...360)
            )
            temp.append(particle)
        }
        particles = temp
    }
    
    private func triggerAnimation(height: CGFloat) {
        withAnimation(.easeOut(duration: 4.0)) {
            for i in 0..<particles.count {
                particles[i].yOffset += height + 100 // Fall to bottom
                particles[i].xOffset += CGFloat.random(in: -80...80) // Sway
                particles[i].rotation += Double.random(in: 360...1080) // Spin
            }
        }
    }
}

// MARK: - Reusable Result View
struct ResultView: View {
    let gameModeName: String
    let score: Int
    let highScore: Int
    let newHighScore: Bool
    
    let onRestart: () -> Void
    let onExit: () -> Void
    
    // Generates the customized text to share with friends
    var shareMessage: String {
        "I just scored \(score) on \(gameModeName) — beat that!"
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Header Title
                VStack(spacing: 8) {
                    Text(newHighScore ? "NEW RECORD!" : "GAME OVER")
                        .font(.system(size: 32, weight: .black, design: .monospaced))
                        .foregroundColor(newHighScore ? .yellow : .accentColor)
                        .tracking(3)
                        .shadow(color: (newHighScore ? Color.yellow : Color.accentColor).opacity(0.5), radius: 8)
                    
                    Text("Thanks for playing Game Arcadia")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.top, 40)
                
                // Score Badges side-by-side
                HStack(spacing: 20) {
                    ScoreBadge(title: "Your Score", score: score, color: .accentColor)
                    ScoreBadge(title: "Best Score", score: highScore, color: .yellow)
                }
                
                Spacer()
                
                // SwiftUI Native ShareLink
                ShareLink(item: shareMessage) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share Your Score")
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.yellow)
                    .cornerRadius(12)
                    .shadow(color: .yellow.opacity(0.3), radius: 6)
                }
                .padding(.horizontal)
                
                // Control Buttons
                VStack(spacing: 12) {
                    Button(action: onRestart) {
                        Text("Play Again")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.accentColor)
                            .cornerRadius(12)
                    }
                    
                    Button(action: onExit) {
                        Text("Back to Hub")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            
            // Show confetti overlay ONLY when a new high score is achieved!
            if newHighScore {
                ConfettiView()
            }
        }
    }
}

#Preview {
    ResultView(
        gameModeName: "Tap Frenzy",
        score: 42,
        highScore: 80,
        newHighScore: true,
        onRestart: {},
        onExit: {}
    )
}
