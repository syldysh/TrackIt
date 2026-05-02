//
//  CalendarHeaderView.swift
//  TrackIt
//
//  Верхняя панель календаря с месяцем и стрелками навигации.
//  Также открывает меню выбора режима просмотра.
//

import SwiftUI

struct CalendarHeaderView: View {
    @EnvironmentObject var vm: CalendarViewModel
    @Binding var showViewMenu: Bool

    var body: some View {
        HStack(spacing: 0) {
            navButton(icon: "chevron.left") { vm.goToPrev() }

            Spacer()

            Button {
                withAnimation(.smoothSpring) { showViewMenu.toggle() }
            } label: {
                HStack(spacing: 6) {
                    Text(vm.headerMonthYear)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color(.label))
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                        .layoutPriority(1)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(.secondaryLabel))
                }
            }

            Spacer()

            navButton(icon: "chevron.right") { vm.goToNext() }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }

    private func navButton(icon: String, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.smoothSpring) { action() }
        } label: {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(.secondaryLabel))
                .frame(width: 32, height: 32)
                .background(Color(.systemGray6))
                .clipShape(Circle())
        }
    }
}
