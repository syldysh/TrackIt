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

    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundColor(.brandGreen)
                Text("Всё запланировано!")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    onAutoDismiss()
                }
            }
            Spacer()
        }
    }
}
