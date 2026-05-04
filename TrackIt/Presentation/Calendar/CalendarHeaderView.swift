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
        HStack(spacing: 8) {
            navButton(icon: "chevron.left") { vm.goToPrev() }

            Spacer(minLength: 6)

            titleButton

            Spacer(minLength: 6)

            if vm.shouldShowTodayButton {
                todayButton
            }
            navButton(icon: "chevron.right") { vm.goToNext() }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }

    private var titleButton: some View {
        Button {
            withAnimation(.smoothSpring) { showViewMenu.toggle() }
        } label: {
            HStack(spacing: 6) {
                Text(vm.headerMonthYear)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(.label))
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                    .layoutPriority(1)
                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(.secondaryLabel))
            }
        }
    }

    private var todayButton: some View {
        Button {
            withAnimation(.smoothSpring) { vm.goToToday() }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 12, weight: .semibold))
                Text("Сегодня")
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }
            .padding(.horizontal, 10)
            .frame(height: 32)
            .frame(maxWidth: 88)
            .foregroundColor(.white)
            .background(Color.brandAccent)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
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
