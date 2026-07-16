import SwiftUI

struct ScoreBadge: View {
    let title: String
    let score: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption.bold().monospaced())
                .foregroundColor(.white.opacity(0.6))
                .tracking(1)
            
            Text("\(score)")
                .font(.system(size: 40, weight: .black, design: .rounded))
                .foregroundColor(color)
        }
        .frame(minWidth: 120)
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(Color.white.opacity(0.04))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(color.opacity(0.25), lineWidth: 1)
        )
    }
}
