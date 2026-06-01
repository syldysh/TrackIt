//
//  PlanningFinishedStateView.swift
//  TrackIt
//
//  Финальный экран режима планирования.
//  Показывается, когда задачи закончились, и сам закрывает режим через небольшой таймер.
//

import SwiftUI

struct PlanningFinishedStateView: View {
    let onAutoDismiss: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var contentVisible = false
    @State private var checkmarkSettled = false
    @State private var confettiVisible = false
    @State private var autoDismissWorkItem: DispatchWorkItem? = nil

    var body: some View {
        ZStack {
            if confettiVisible && !reduceMotion {
                CompletionConfettiView()
                    .transition(.opacity)
            }

            VStack {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: Constants.checkmarkSize))
                        .foregroundColor(.brandGreen)
                        .scaleEffect(checkmarkScale)
                        .opacity(contentVisible ? 1 : 0)
                    Text("Всё запланировано!")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                        .opacity(contentVisible ? 1 : 0)
                        .offset(y: contentVisible ? 0 : 6)
                }
                Spacer()
            }
        }
        .onAppear(perform: startCompletionAnimation)
        .onDisappear(perform: cancelScheduledWork)
    }

    private var checkmarkScale: CGFloat {
        if reduceMotion {
            return contentVisible ? 1 : 0.98
        }
        return checkmarkSettled ? 1 : 0.76
    }

    private func startCompletionAnimation() {
        guard autoDismissWorkItem == nil else { return }

        if reduceMotion {
            withAnimation(.easeOut(duration: Constants.reducedMotionFadeDuration)) {
                contentVisible = true
                checkmarkSettled = true
            }
            scheduleAutoDismiss(after: Constants.reducedMotionAutoDismissDelay)
        } else {
            withAnimation(.easeOut(duration: Constants.confettiFadeDuration)) {
                confettiVisible = true
            }
            withAnimation(.easeOut(duration: Constants.celebrationFadeDuration)) {
                contentVisible = true
            }
            withAnimation(.spring(response: 0.42, dampingFraction: 0.58)) {
                checkmarkSettled = true
            }

            scheduleAutoDismiss(after: Constants.autoDismissDelay)
        }
    }

    private func scheduleAutoDismiss(after delay: TimeInterval) {
        let dismiss = DispatchWorkItem {
            onAutoDismiss()
        }
        autoDismissWorkItem = dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: dismiss)
    }

    private func cancelScheduledWork() {
        autoDismissWorkItem?.cancel()
        autoDismissWorkItem = nil
    }

    private enum Constants {
        static let checkmarkSize: CGFloat = 56
        static let confettiFadeDuration: TimeInterval = 0.12
        static let celebrationFadeDuration: TimeInterval = 0.24
        static let autoDismissDelay: TimeInterval = 2.1
        static let reducedMotionFadeDuration: TimeInterval = 0.32
        static let reducedMotionAutoDismissDelay: TimeInterval = 1.2
    }
}
