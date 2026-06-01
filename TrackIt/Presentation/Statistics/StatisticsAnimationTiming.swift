//
//  StatisticsAnimationTiming.swift
//  TrackIt
//
//  Общие параметры анимаций экрана прогресса.
//

import SwiftUI

enum StatisticsAnimationTiming {
    static let entryRingAnimation = Animation.easeOut(duration: 0.9)
    static let positiveRingAnimation = Animation.interactiveSpring(response: 0.58, dampingFraction: 0.78)
    static let highlightAnimation = Animation.interactiveSpring(response: 0.34, dampingFraction: 0.68)
    static let reducedHighlightAnimation = Animation.easeOut(duration: 0.22)
    static let completionCelebrationDelayNanoseconds: UInt64 = 700_000_000
    static let highlightDurationNanoseconds: UInt64 = 1_550_000_000
}
