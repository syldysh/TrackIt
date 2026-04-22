//
//  Color+Brand.swift
//  TrackIt
//
//  Семантические цвета приложения.
//

import SwiftUI

extension Color {

    // MARK: - Основные цвета бренда

    // Основной синий акцент (кнопки, выделение, ссылки)
    static let brandAccent = Color(.systemBlue)

    // Оранжевый — режим планирования, вторичные действия
    static let brandOrange = Color(.systemOrange)

    // Красный — удаление, отмена
    static let brandRed = Color(.systemRed)

    // Зелёный — выполнено, успех
    static let brandGreen = Color(.systemGreen)

    // Фиолетовый — индикатор времени
    static let brandPurple = Color(.systemPurple)

    // Жёлтый — закрепление задач
    static let brandYellow = Color(.systemYellow)

    // Цвет блоков задач на таймлайне
    static let taskBlock = Color(.systemBlue).opacity(0.15)
}
