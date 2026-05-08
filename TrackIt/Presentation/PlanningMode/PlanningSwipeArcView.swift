//
//  PlanningSwipeArcView.swift
//  TrackIt
//
//  Полукольцо прогресса свайпа в режиме планирования.
//

import SwiftUI

enum PlanningSwipeArcDirection {
    case none
    case left
    case right
    case down
}

struct PlannerSwipeArcShape: Shape {
    let direction: PlanningSwipeArcDirection
    var progress: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let clampedProgress = min(max(progress, 0), 1)
        guard direction != .none, clampedProgress > 0 else { return Path() }

        let radius = max(rect.width, rect.height) * 0.62
        let center = arcCenter(in: rect, radius: radius)
        let span = 42 + 148 * clampedProgress
        let startDegrees = centerAngle - span / 2
        let endDegrees = centerAngle + span / 2
        let startAngle = Angle.degrees(startDegrees)
        let endAngle = Angle.degrees(endDegrees)
        let startPoint = point(center: center, radius: radius, angle: startDegrees)
        let endPoint = point(center: center, radius: radius, angle: endDegrees)

        var path = Path()

        switch direction {
        case .right:
            path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: endPoint)
            path.addArc(center: center, radius: radius, startAngle: endAngle, endAngle: startAngle, clockwise: true)
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        case .left:
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: startPoint)
            path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        case .down:
            path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: startPoint)
            path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        case .none:
            break
        }
        path.closeSubpath()
        return path
    }

    private func arcCenter(in rect: CGRect, radius: CGFloat) -> CGPoint {
        switch direction {
        case .right:
            CGPoint(x: rect.maxX + radius * 0.34, y: rect.midY)
        case .left:
            CGPoint(x: rect.minX - radius * 0.34, y: rect.midY)
        case .down:
            CGPoint(x: rect.midX, y: rect.maxY + radius * 0.18)
        case .none:
            CGPoint(x: rect.midX, y: rect.midY)
        }
    }

    private func point(center: CGPoint, radius: CGFloat, angle degrees: Double) -> CGPoint {
        let radians = degrees * .pi / 180
        return CGPoint(
            x: center.x + CGFloat(cos(radians)) * radius,
            y: center.y + CGFloat(sin(radians)) * radius
        )
    }

    private var centerAngle: Double {
        switch direction {
        case .right: 180
        case .left: 0
        case .down: 270
        case .none: 0
        }
    }
}

struct PlanningSwipeArcView: View {
    let direction: PlanningSwipeArcDirection
    let progress: CGFloat

    private var clampedProgress: CGFloat {
        min(max(progress, 0), 1)
    }

    private var color: Color {
        switch direction {
        case .right: .brandGreen
        case .left: .brandOrange
        case .down: .brandRed
        case .none: .clear
        }
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                PlannerSwipeArcShape(direction: direction, progress: clampedProgress)
                    .fill(color.opacity(Double(clampedProgress) * 0.1))
                    .blur(radius: 20 * clampedProgress)

                PlannerSwipeArcShape(direction: direction, progress: clampedProgress)
                    .fill(color.opacity(0.05 + Double(clampedProgress) * 0.17))
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .opacity(Double(clampedProgress))
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
