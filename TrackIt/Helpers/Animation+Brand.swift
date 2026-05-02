//
//  Animation+Brand.swift
//  TrackIt
//
//  Единые анимации для всего приложения.
//  Нужны, чтобы экраны и модалки двигались в одном стиле.
//

import SwiftUI

extension Animation {

    // Основная плавная пружина — для большинства переходов (тапы, переключения, раскрытия)
    static let smoothSpring = Animation.spring(response: 0.4, dampingFraction: 0.88)

    // Быстрая пружина — для мелких тоглов (чекбоксы, меню, иконки)
    static let snappySpring = Animation.spring(response: 0.28, dampingFraction: 0.88)

    // Пружина для появления / закрытия шитов и модалок
    static let sheetSpring = Animation.spring(response: 0.42, dampingFraction: 0.9)

    // Следование за пальцем при драге — почти без отскока, высокая отзывчивость
    static let dragFollow = Animation.interactiveSpring(response: 0.22, dampingFraction: 0.92, blendDuration: 0)
}
