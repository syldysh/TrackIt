import SwiftUI

struct CalendarViewMenuOverlay: View {
    @EnvironmentObject var vm: CalendarViewModel
    @Binding var isPresented: Bool
    @Binding var weekModalDate: Date?

    var body: some View {
        ZStack(alignment: .top) {
            Color.clear.ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { withAnimation(.smoothSpring) { isPresented = false } }

            VStack(spacing: 0) {
                ForEach(CalViewMode.allCases, id: \.self) { mode in
                    menuButton(for: mode)
                    if mode != .day { Divider().padding(.leading, 50) }
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.16), radius: 20, y: 8)
            .frame(width: 220)
            .padding(.top, 48)
        }
        .zIndex(50)
    }

    private func menuButton(for mode: CalViewMode) -> some View {
        Button {
            withAnimation(.smoothSpring) {
                if mode == .week { vm.syncMonthToSelected() }
                vm.viewMode = mode
                weekModalDate = nil
                isPresented = false
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: mode.icon)
                    .font(.system(size: 16))
                    .foregroundColor(vm.viewMode == mode ? .brandAccent : Color(.secondaryLabel))
                    .frame(width: 22)
                Text(mode.label)
                    .font(.system(size: 16))
                    .foregroundColor(vm.viewMode == mode ? .brandAccent : Color(.label))
                Spacer()
                if vm.viewMode == mode {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.brandAccent)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
    }
}
