import SwiftUI

struct NotificationToggleSection: View {
    let isOn: Bool
    let message: String?
    let onChange: (Bool) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("УВЕДОМЛЕНИЕ")
                .sectionHeaderStyle()
                .padding(.leading, 24)
                .padding(.bottom, 8)

            VStack(alignment: .leading, spacing: 8) {
                Toggle(isOn: Binding(get: { isOn }, set: onChange)) {
                    HStack(spacing: 8) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.brandAccent)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Напомнить в выбранное время")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color(.label))
                                .lineLimit(2)
                                .minimumScaleFactor(0.88)
                            Text("Локальное уведомление для этой задачи")
                                .font(.system(size: 12))
                                .foregroundColor(Color(.secondaryLabel))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: .brandAccent))

                if let message, !message.isEmpty {
                    Text(message)
                        .font(.system(size: 12))
                        .foregroundColor(Color(.secondaryLabel))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(.systemGray6))
            .cornerRadius(16)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
}
