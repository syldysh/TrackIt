//
//  StatisticsHelpFeedbackView.swift
//  TrackIt
//
//  Экран помощи и обратной связи раздела статистики.
//

import SwiftUI

struct StatisticsHelpFeedbackView: View {
    @Environment(\.openURL) private var openURL
    @State private var expandedFAQIDs: Set<String> = []
    @State private var showsMailError = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                introCard
                faqSection
                feedbackSection
            }
            .padding(16)
        }
        .background(Color(.secondarySystemBackground))
        .navigationTitle("Помощь")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Не удалось открыть почту", isPresented: $showsMailError) {
            Button("ОК", role: .cancel) {}
        } message: {
            Text("Напишите нам на \(FeedbackMailHelper.recipient).")
        }
    }

    private var introCard: some View {
        StatisticsSettingsIntroCard(
            title: "Помощь и обратная связь",
            subtitle: "Здесь собраны ответы на частые вопросы и возможность оставить обратную связь."
        ) {
            StatisticsSettingsIcon(systemName: "questionmark.circle.fill")
        }
    }

    private var faqSection: some View {
        StatisticsSettingsGroup(title: "Частые вопросы") {
            ForEach(HelpFAQ.items) { item in
                FAQDisclosureRow(
                    item: item,
                    isExpanded: expandedFAQIDs.contains(item.id)
                ) {
                    toggleFAQ(item.id)
                }

                if item.id != HelpFAQ.items.last?.id {
                    Divider().padding(.leading, HelpRowLayout.dividerLeading)
                }
            }
        }
    }

    private var feedbackSection: some View {
        StatisticsSettingsGroup(title: "Обратная связь") {
            Button(action: openFeedbackEmail) {
                HelpSettingsRow(
                    icon: "envelope.fill",
                    title: "Написать разработчику",
                    subtitle: FeedbackMailHelper.recipient,
                    chevron: "chevron.right"
                )
            }
            .buttonStyle(.plain)
        }
    }

    private func toggleFAQ(_ id: String) {
        withAnimation(.snappySpring) {
            if expandedFAQIDs.contains(id) {
                expandedFAQIDs.remove(id)
            } else {
                expandedFAQIDs.insert(id)
            }
        }
    }

    private func openFeedbackEmail() {
        guard let url = FeedbackMailHelper.makeFeedbackURL() else {
            showsMailError = true
            return
        }

        openURL(url) { accepted in
            if !accepted {
                showsMailError = true
            }
        }
    }
}

private struct FAQDisclosureRow: View {
    let item: HelpFAQ
    let isExpanded: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HelpSettingsRow(
                icon: "questionmark.circle.fill",
                title: item.question,
                subtitle: isExpanded ? item.answer : nil,
                chevron: "chevron.down",
                chevronRotation: .degrees(isExpanded ? 180 : 0),
                rowAlignment: isExpanded ? .top : .center,
                minHeight: isExpanded ? nil : HelpRowLayout.collapsedMinHeight
            )
        }
        .buttonStyle(.plain)
    }
}

private struct HelpSettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String?
    let chevron: String?
    var chevronRotation: Angle = .zero
    var rowAlignment: VerticalAlignment = .top
    var minHeight: CGFloat? = nil

    var body: some View {
        HStack(alignment: rowAlignment, spacing: HelpRowLayout.iconSpacing) {
            StatisticsSettingsIcon(systemName: icon, size: HelpRowLayout.iconSize, fontSize: 15)
                .frame(width: HelpRowLayout.iconColumnWidth, alignment: .center)

            VStack(alignment: .leading, spacing: 6) {
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
                            .frame(
                                width: HelpRowLayout.chevronSize,
                                height: HelpRowLayout.chevronSize,
                                alignment: .center
                            )
                            .rotationEffect(chevronRotation)
                    }
                }

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
        .frame(minHeight: minHeight, alignment: rowAlignment == .center ? .center : .top)
        .contentShape(Rectangle())
    }
}

private struct HelpFAQ: Identifiable {
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

private enum HelpRowLayout {
    static let rowPadding: CGFloat = 14
    static let iconSize: CGFloat = 34
    static let iconColumnWidth: CGFloat = 34
    static let iconSpacing: CGFloat = 12
    static let chevronSize: CGFloat = 18
    static let collapsedMinHeight: CGFloat = 76
    static var dividerLeading: CGFloat { rowPadding + iconColumnWidth + iconSpacing }
}
