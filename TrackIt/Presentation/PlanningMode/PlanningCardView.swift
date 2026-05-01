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
    let onSkip: () -> Void
    let onDelete: () -> Void
    let onSchedule: () -> Void

    private static let hPadding: CGFloat = 20

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
        if offset.width > 20  { return .right }
        if offset.width < -20 { return .left }
        if offset.height > 20 { return .down }
        return .none
    }

    private enum SwipeDirection { case none, left, right, down }

    var body: some View {
        ZStack {
            mainCard
        }
        .background {
            colorBackdrop
        }
    }

    @ViewBuilder
    private var colorBackdrop: some View {
        switch activeDirection {
        case .right:
            backdropCard(color: .brandGreen,  icon: "calendar.badge.plus", progress: progress)
        case .left:
            backdropCard(color: .brandOrange, icon: "arrow.uturn.left",    progress: progress)
        case .down:
            backdropCard(color: .brandRed,    icon: "trash",               progress: progress)
        case .none:
            EmptyView()
        }
    }

    private func backdropCard(color: Color, icon: String, progress: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(color.opacity(Double(progress) * 0.35))
            .padding(.horizontal, Self.hPadding)
            .overlay(
                Image(systemName: icon)
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(color.opacity(Double(progress)))
            )
    }

    private var mainCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            RoundedRectangle(cornerRadius: 3)
                .fill(topBarColor)
                .frame(height: 5)

            VStack(alignment: .leading, spacing: 0) {
                badge
                    .padding(.bottom, 18)

                Text(task.title)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(Color(.label))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.78)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 20)

                Divider()

                actionIcons
                    .padding(.top, 10)
                    .padding(.bottom, 4)
            }
            .padding(20)
        }
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.14), radius: 20, y: 6)
        .padding(.horizontal, Self.hPadding)
        .offset(offset)
        .rotationEffect(.degrees(Double(offset.width / 30)))
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

    private var actionIcons: some View {
        HStack(spacing: 0) {
            iconButton("arrow.uturn.left", color: .brandOrange,
                       isActive: activeDirection == .left,   action: onSkip)
            Spacer()
            iconButton("trash",            color: .brandRed,
                       isActive: activeDirection == .down,   action: onDelete)
            Spacer()
            iconButton("calendar.badge.plus", color: .brandGreen,
                       isActive: activeDirection == .right,  action: onSchedule)
        }
    }

    private func iconButton(_ icon: String, color: Color,
                            isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(color)
                .frame(width: 52, height: 52)
                .background(color.opacity(isActive ? 0.22 : 0.12))
                .clipShape(Circle())
        }
        .scaleEffect(isActive ? 1.12 : 1.0)
        .animation(.smoothSpring, value: isActive)
    }
}
