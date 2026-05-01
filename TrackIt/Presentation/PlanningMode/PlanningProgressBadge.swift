import SwiftUI

struct PlanningProgressBadge: View {
    let remaining: Int

    var body: some View {
        Text("\(remaining) \(RuDate.pluralTasks(remaining)) осталось")
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(.white.opacity(0.88))
            .lineLimit(1)
            .minimumScaleFactor(0.86)
            .padding(.horizontal, 18)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.20))
            .cornerRadius(20)
    }
}
