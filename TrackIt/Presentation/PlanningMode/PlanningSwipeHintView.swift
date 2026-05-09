//
//  PlanningSwipeHintView.swift
//  TrackIt
//
//  Нижняя подсказка жестов в режиме планирования.
//

import SwiftUI

struct PlanningSwipeHintView: View {
    var body: some View {
        Text("← Пропустить   → Запланировать   ↓ Удалить")
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white.opacity(0.5))
            .multilineTextAlignment(.center)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
    }
}
