import SwiftUI

struct ScoreBadge: View {
    let title: String
    let score: Int
    let color: Color
    
    @Environment(\.colorScheme) var colorScheme
    
    private var badgeBackgroundColor: Color {
        colorScheme == .light ? Color(UIColor.secondarySystemGroupedBackground) : Color.white.opacity(0.03)
    }
    
    private var badgeBorderColor: Color {
        colorScheme == .light ? Color.black.opacity(0.06) : Color.white.opacity(0.05)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption.bold().monospaced())
                .foregroundColor(.secondary)
                .tracking(1)
            
            Text("\(score)")
                .font(.system(size: 40, weight: .black, design: .rounded))
                .foregroundColor(color)
        }
        .frame(minWidth: 120)
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(badgeBackgroundColor) // Glass backdrop
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    LinearGradient(
                        colors: [color.opacity(0.4), badgeBorderColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}
