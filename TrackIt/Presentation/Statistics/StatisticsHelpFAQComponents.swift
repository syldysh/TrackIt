//
//  StatisticsHelpFAQComponents.swift
//  TrackIt
//
//  FAQ-модель и строки для экрана помощи.
//

import SwiftUI

struct FAQDisclosureRow: View {
    let item: HelpFAQ
    let isExpanded: Bool
    let action: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            answerText
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: toggle)
        .animation(expandAnimation, value: isExpanded)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: HelpRowLayout.iconSpacing) {
            StatisticsSettingsIcon(systemName: "questionmark.circle.fill", size: HelpRowLayout.iconSize, fontSize: 15)
                .frame(width: HelpRowLayout.iconColumnWidth, alignment: .center)

            Text(item.question)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(.label))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .layoutPriority(1)

            Image(systemName: "chevron.down")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(.tertiaryLabel))
                .frame(width: HelpRowLayout.chevronSize, height: HelpRowLayout.chevronSize)
                .rotationEffect(.degrees(isExpanded ? Constants.expandedChevronRotation : Constants.collapsedChevronRotation))
                .animation(expandAnimation, value: isExpanded)
        }
        .padding(.horizontal, HelpRowLayout.rowPadding)
        .frame(minHeight: HelpRowLayout.collapsedHeight, alignment: .center)
    }

    @ViewBuilder
    private var answerText: some View {
        if isExpanded {
            Text(item.answer)
                .font(.system(size: 15))
                .foregroundColor(Color(.secondaryLabel))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, HelpRowLayout.answerTopPadding)
                .padding(.leading, HelpRowLayout.textLeading)
                .padding(.trailing, HelpRowLayout.answerTrailing)
                .padding(.bottom, HelpRowLayout.answerBottomPadding)
                .transition(answerTransition)
        }
    }

    private var expandAnimation: Animation {
        reduceMotion ? Constants.reduceMotionAnimation : Constants.expandAnimation
    }

    private var answerTransition: AnyTransition {
        reduceMotion
            ? .opacity
            : .opacity.combined(with: .offset(y: -Constants.answerVerticalOffset))
    }

    private func toggle() {
        withAnimation(expandAnimation) {
            action()
        }
    }

    private enum Constants {
        static let expandAnimation: Animation = .easeInOut(duration: 0.26)
        static let reduceMotionAnimation: Animation = .easeInOut(duration: 0.16)
        static let answerVerticalOffset: CGFloat = 6
        static let collapsedChevronRotation = 0.0
        static let expandedChevronRotation = 180.0
    }
}

struct HelpSettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String?
    let chevron: String?

    var body: some View {
        HStack(alignment: .top, spacing: HelpRowLayout.iconSpacing) {
            StatisticsSettingsIcon(systemName: icon, size: HelpRowLayout.iconSize, fontSize: 15)
                .frame(width: HelpRowLayout.iconColumnWidth, alignment: .center)

            VStack(alignment: .leading, spacing: 6) {
                titleRow

                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 15))
                        .foregroundColor(Color(.secondaryLabel))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .layoutPriority(1)
        }
        .padding(HelpRowLayout.rowPadding)
        .contentShape(Rectangle())
    }

    private var titleRow: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(.label))
                .fixedSize(horizontal: false, vertical: true)
                .layoutPriority(1)

            Spacer(minLength: 8)

            if let chevron {
                Image(systemName: chevron)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(.tertiaryLabel))
                    .frame(width: HelpRowLayout.chevronSize, height: HelpRowLayout.chevronSize)
            }
        }
    }
}

struct HelpFAQ: Identifiable {
    let id: String
    let question: String
    let answer: String

    init(question: String, answer: String) {
        self.id = question
        self.question = question
        self.answer = answer
    }

    static let items: [HelpFAQ] = [
        HelpFAQ(
            question: "Как считается прогресс?",
            answer: "Прогресс показывает, какой процент задач выполнен за неделю."
        ),
        HelpFAQ(
            question: "Как считается страйк дней?",
            answer: "Страйк дней растёт, если выполняется хотя бы одна задача на день."
        ),
        HelpFAQ(
            question: "Почему тренд продуктивности может быть пустым?",
            answer: "Тренд может быть пустым, если за последние 7 дней не было выполненных задач."
        ),
        HelpFAQ(
            question: "Как запланировать задачу?",
            answer: "Задачу можно запланировать сразу при создании, либо через планировщик."
        ),
        HelpFAQ(
            question: "Где хранятся мои задачи?",
            answer: "Задачи хранятся в приложении TrackIt локально."
        )
    ]
}

enum HelpRowLayout {
    static let rowPadding: CGFloat = 14
    static let iconSize: CGFloat = 34
    static let iconColumnWidth: CGFloat = 34
    static let iconSpacing: CGFloat = 12
    static let chevronSize: CGFloat = 18
    static let collapsedHeight: CGFloat = 64
    static let answerTopPadding: CGFloat = -10
    static let answerBottomPadding: CGFloat = 12
    static let answerTrailing: CGFloat = rowPadding + chevronSize
    static var textLeading: CGFloat { rowPadding + iconColumnWidth + iconSpacing }
    static var dividerLeading: CGFloat { rowPadding + iconColumnWidth + iconSpacing }
}
