//
//  PlanningCardView.swift
//  TrackIt
//
//  Карточка задачи в режиме быстрого планирования.
//

import SwiftUI

struct PlanningCardView: View {
    let task: Task
    let totalRemaining: Int
    let offset: CGSize

    private var progress: CGFloat {
        let ax = abs(offset.width)
        let ay = offset.height
        switch activeDirection {
        case .right: return min(ax / 120, 1)
        case .left:  return min(ax / 120, 1)
        case .down:  return min(ay / 120, 1)
        case .none:  return 0
        }
    }

    private var activeDirection: SwipeDirection {
        if offset.width > 20 { return .right }
        if offset.width < -20 { return .left }
        if offset.height > 20 { return .down }
        return .none
    }

    private enum SwipeDirection { case none, left, right, down }

    var body: some View {
        ZStack {
            colorBackdrop
            stackCards
            mainCard
        }
    }

    // MARK: - Цветная подложка

    @ViewBuilder
    private var colorBackdrop: some View {
        switch activeDirection {
        case .right:
            backdropCard(color: .brandGreen, icon: "calendar.badge.plus", progress: progress)
        case .left:
            backdropCard(color: .brandOrange, icon: "arrow.uturn.left", progress: progress)
        case .down:
            backdropCard(color: .brandRed, icon: "trash", progress: progress)
        case .none:
            EmptyView()
        }
    }

    private func backdropCard(color: Color, icon: String, progress: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(color.opacity(Double(progress) * 0.35))
            .frame(height: 420)
            .padding(.horizontal, 20)
            .overlay(
                Image(systemName: icon)
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(color.opacity(Double(progress)))
            )
    }

    // MARK: - Stack Effect

    private var stackCards: some View {
        ForEach(Array((1...2).reversed()), id: \.self) { i in
            if totalRemaining > i {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .frame(height: 420)
                    .padding(.horizontal, CGFloat(24 + i * 8))
                    .offset(y: CGFloat(i * 10))
                    .opacity(i == 1 ? 0.6 : 0.3)
            }
        }
    }

    // MARK: - Main Card

    private var mainCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            RoundedRectangle(cornerRadius: 4)
                .fill(topBarColor)
                .frame(height: 6)

            VStack(alignment: .leading, spacing: 12) {
                badge
                Text(task.title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(.label))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                Divider()
                swipeHints
            }
            .padding(20)
        }
        .frame(height: 420)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.12), radius: 16, y: 4)
        .padding(.horizontal, 20)
        .offset(offset)
        .rotationEffect(.degrees(Double(offset.width / 30)))
        .animation(.dragFollow, value: offset)
    }

    private var topBarColor: Color {
        switch activeDirection {
        case .right: return .brandGreen
        case .left:  return .brandOrange
        case .down:  return .brandRed
        case .none:  return .brandAccent
        }
    }

    private var badge: some View {
        HStack(spacing: 4) {
            Image(systemName: "bolt.fill")
                .font(.system(size: 11))
                .foregroundColor(.brandAccent)
            Text("Требует планирования")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.brandAccent)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.brandAccent.opacity(0.12))
        .cornerRadius(12)
    }

    private var swipeHints: some View {
        HStack(spacing: 0) {
            hintLabel("arrow.left", "Пропустить", color: .brandOrange,
                      active: activeDirection == .left)
            Spacer()
            hintLabel("arrow.down", "Удалить", color: .brandRed,
                      active: activeDirection == .down)
            Spacer()
            hintLabel("arrow.right", "Запланировать", color: .brandGreen,
                      active: activeDirection == .right, trailing: true)
        }
        .padding(.top, 8)
    }

    private func hintLabel(_ icon: String, _ text: String, color: Color,
                           active: Bool, trailing: Bool = false) -> some View {
        HStack(spacing: 4) {
            if !trailing {
                Image(systemName: icon).font(.system(size: 11, weight: .semibold))
            }
            Text(text).font(.system(size: 13, weight: active ? .bold : .medium))
            if trailing {
                Image(systemName: icon).font(.system(size: 11, weight: .semibold))
            }
        }
        .foregroundColor(color)
        .opacity(active ? 1 : 0.6)
    }
}
