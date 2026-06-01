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
        if expandedFAQIDs.contains(id) {
            expandedFAQIDs.remove(id)
        } else {
            expandedFAQIDs.insert(id)
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
