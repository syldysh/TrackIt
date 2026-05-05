//
//  StreakModalView.swift
//  TrackIt
//
//  Модальное окно со стриком активности.
//  Показывает серию дней и короткий поддерживающий текст для пользователя.
//

import SwiftUI

struct StreakModalView: View {
    let streakDays: Int
    let supportText: String
    @ObservedObject var dragState: ModalDragState
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            dragArea
            Divider()
            ScrollView {
                content
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.15), radius: 20, y: 8)
        .modalDragOffset(dragState)
    }

    private var dragArea: some View {
        ModalDragHandle(dragState: dragState, onDismiss: onDismiss) {
            header
        }
    }

    private var header: some View {
        HStack {
            Text("Стрик активности")
                .font(.system(size: 17, weight: .semibold))
            Spacer()
            Text("\(streakDays) \(dayWord)")
                .font(.system(size: 13))
                .foregroundColor(Color(.secondaryLabel))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private var content: some View {
        VStack(spacing: 14) {
            Circle()
                .fill(Color.brandOrange.opacity(0.14))
                .frame(width: 76, height: 76)
                .overlay(
                    Image(systemName: "flame.fill")
                        .font(.system(size: 34))
                        .foregroundColor(.brandOrange)
                )

            Text("\(streakDays)")
                .font(.system(size: 44, weight: .bold))
                .foregroundColor(Color(.label))

            Text(dayWord)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color(.secondaryLabel))
                .padding(.top, -10)

            Text(supportText)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color(.label))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text("Возвращайтесь к задачам каждый день, чтобы серия росла.")
                .font(.system(size: 14))
                .foregroundColor(Color(.secondaryLabel))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .padding(.vertical, 32)
    }

    private var dayWord: String {
        let mod10 = streakDays % 10
        let mod100 = streakDays % 100
        if mod10 == 1 && mod100 != 11 { return "день" }
        if (2...4).contains(mod10) && !(12...14).contains(mod100) { return "дня" }
        return "дней"
    }
}
