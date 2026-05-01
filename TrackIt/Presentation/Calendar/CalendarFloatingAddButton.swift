import SwiftUI

struct CalendarFloatingAddButton: View {
    let action: () -> Void

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: action) {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.brandAccent)
                        .clipShape(Circle())
                        .shadow(color: .blue.opacity(0.35), radius: 12, y: 6)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 24)
            }
        }
    }
}
