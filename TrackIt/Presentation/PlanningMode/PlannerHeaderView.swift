import SwiftUI

struct PlannerHeaderView: View {
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Button(action: onDismiss) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.brandAccent)
                    .frame(width: 36, height: 36)
                    .background(Color.white.opacity(0.14))
                    .clipShape(Circle())
            }
            Image(systemName: "bolt.fill")
                .font(.system(size: 20))
                .foregroundColor(.brandOrange)
            Text("Режим планирования")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
                .layoutPriority(1)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 16)
    }
}
