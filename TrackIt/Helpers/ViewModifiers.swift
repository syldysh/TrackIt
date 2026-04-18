//
//  ViewModifiers.swift
//  TrackIt
//
//  Переиспользуемые модификаторы и вспомогательные фигуры.
//

import SwiftUI

// MARK: - Card Style

// Стандартная карточка: белый фон, скруглённые углы, лёгкая тень.
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}

// MARK: - Rounded Corner (выборочное скругление)

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Section Header Style

// Стиль для заголовков секций: "ДАТА", "ВРЕМЯ" и т.д.
struct SectionHeader: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(Color(.secondaryLabel))
            .tracking(1)
    }
}

extension View {
    func sectionHeaderStyle() -> some View {
        modifier(SectionHeader())
    }
}

// MARK: - Comparable clamped

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
