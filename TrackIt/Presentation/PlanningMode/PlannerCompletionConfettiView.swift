//
//  PlannerCompletionConfettiView.swift
//  TrackIt
//
//  Системное конфетти для финального состояния режима планирования.
//

import SwiftUI

struct PlannerCompletionConfettiView: View {
    @State private var isExpanded = false

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(0..<Constants.particleCount, id: \.self) { index in
                    particle(at: index)
                        .frame(width: size(for: index).width, height: size(for: index).height)
                        .foregroundStyle(color(for: index))
                        .rotationEffect(.degrees(isExpanded ? endRotation(for: index) : startRotation(for: index)))
                        .position(startPosition(for: index, in: proxy.size))
                        .offset(isExpanded ? endOffset(for: index, in: proxy.size) : .zero)
                        .scaleEffect(isExpanded ? Constants.finalScale : Constants.initialScale)
                        .opacity(isExpanded ? 0 : Constants.initialOpacity)
                        .animation(
                            .easeOut(duration: duration(for: index))
                                .delay(delay(for: index)),
                            value: isExpanded
                        )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                isExpanded = false
                DispatchQueue.main.async {
                    isExpanded = true
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private func particle(at index: Int) -> some View {
        switch index % Constants.shapeVariants {
        case 0:
            Circle()
        case 1:
            Capsule()
        default:
            RoundedRectangle(cornerRadius: Constants.rectangleCornerRadius, style: .continuous)
        }
    }

    private func startPosition(for index: Int, in containerSize: CGSize) -> CGPoint {
        let column = CGFloat(index % Constants.columns)
        let row = CGFloat(index / Constants.columns)
        let xStep = containerSize.width / CGFloat(Constants.columns + 1)
        let yStep = containerSize.height * Constants.startAreaHeight / CGFloat(Constants.rows + 1)
        let xJitter: CGFloat = index.isMultiple(of: 2) ? Constants.jitter : -Constants.jitter

        return CGPoint(
            x: xStep * (column + 1) + xJitter,
            y: yStep * (row + 1) + Constants.topInset
        )
    }

    private func endOffset(for index: Int, in containerSize: CGSize) -> CGSize {
        let direction: CGFloat = index.isMultiple(of: 2) ? 1 : -1
        let drift = CGFloat((index % Constants.driftVariants) + 1) * Constants.driftStep
        let fall = containerSize.height * Constants.fallRatio

        return CGSize(
            width: direction * drift,
            height: min(fall, Constants.maxFallDistance)
        )
    }

    private func color(for index: Int) -> Color {
        Constants.colors[index % Constants.colors.count]
    }

    private func size(for index: Int) -> CGSize {
        let base = Constants.baseSize + CGFloat(index % Constants.sizeVariants)
        if index % Constants.shapeVariants == 1 {
            return CGSize(width: base * 0.7, height: base * 1.6)
        }
        return CGSize(width: base, height: base)
    }

    private func startRotation(for index: Int) -> Double {
        Double((index % Constants.rotationVariants) * Constants.rotationStep)
    }

    private func endRotation(for index: Int) -> Double {
        startRotation(for: index) + Double(index.isMultiple(of: 2) ? 160 : -160)
    }

    private func duration(for index: Int) -> TimeInterval {
        Constants.baseDuration + TimeInterval(index % Constants.durationVariants) * Constants.durationStep
    }

    private func delay(for index: Int) -> TimeInterval {
        TimeInterval(index % Constants.delayVariants) * Constants.delayStep
    }

    private enum Constants {
        static let particleCount = 24
        static let columns = 6
        static let rows = 4
        static let shapeVariants = 3
        static let sizeVariants = 4
        static let driftVariants = 4
        static let rotationVariants = 6
        static let durationVariants = 4
        static let delayVariants = 5

        static let baseSize: CGFloat = 8
        static let initialScale: CGFloat = 1.25
        static let finalScale: CGFloat = 0.72
        static let initialOpacity: Double = 0.86
        static let startAreaHeight: CGFloat = 0.58
        static let topInset: CGFloat = 12
        static let jitter: CGFloat = 10
        static let driftStep: CGFloat = 18
        static let fallRatio: CGFloat = 0.34
        static let maxFallDistance: CGFloat = 210
        static let rectangleCornerRadius: CGFloat = 2
        static let rotationStep = 24

        static let baseDuration: TimeInterval = 1.25
        static let durationStep: TimeInterval = 0.12
        static let delayStep: TimeInterval = 0.04

        static let colors: [Color] = [
            .brandGreen.opacity(0.88),
            .brandOrange.opacity(0.82),
            .brandAccent.opacity(0.78),
            .brandYellow.opacity(0.82),
            .white.opacity(0.72)
        ]
    }
}
