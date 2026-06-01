//
//  PlanningSwipeHintView.swift
//  TrackIt
//
//  Подсказки жестов в режиме планирования.
//

import SwiftUI

struct PlanningSwipeHintView: View {
    var body: some View {
        VStack(spacing: Layout.verticalSpacing) {
            HStack(spacing: Layout.horizontalSpacing) {
                hint("Пропустить", systemImage: "arrow.left")
                    .frame(maxWidth: .infinity, alignment: .leading)
                hint(
                    "Запланировать",
                    systemImage: "arrow.right",
                    iconPlacement: .trailing
                )
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }

            hint("Удалить", systemImage: "arrow.down")
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .foregroundColor(.white.opacity(Layout.opacity))
        .lineLimit(1)
        .minimumScaleFactor(Layout.minimumScaleFactor)
    }

    private func hint(
        _ title: String,
        systemImage: String,
        iconPlacement: HintIconPlacement = .leading,
        fontSize: CGFloat = Layout.fontSize
    ) -> some View {
        HStack(spacing: Layout.iconSpacing) {
            if iconPlacement == .leading {
                Image(systemName: systemImage)
            }
            Text(title)
            if iconPlacement == .trailing {
                Image(systemName: systemImage)
            }
        }
        .font(.system(size: fontSize, weight: .semibold))
        .lineLimit(1)
        .minimumScaleFactor(Layout.minimumScaleFactor)
    }
}

private enum Layout {
    static let fontSize: CGFloat = 14
    static let horizontalSpacing: CGFloat = 12
    static let verticalSpacing: CGFloat = 12
    static let iconSpacing: CGFloat = 8
    static let minimumScaleFactor = 0.72
    static let opacity = 0.5
}

private enum HintIconPlacement {
    case leading
    case trailing
}
