//
//  ProgressCelebrationView.swift
//  TrackIt
//
//  Позитивная анимация для экрана прогресса.
//

import SwiftUI

struct ProgressCelebrationView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        if !reduceMotion {
            CompletionConfettiView()
                .transition(.opacity)
        }
    }
}
