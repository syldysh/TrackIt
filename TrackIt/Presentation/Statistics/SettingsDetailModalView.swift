//
//  SettingsDetailModalView.swift
//  TrackIt
//
//  Модальное окно для пунктов настроек и поддержки.
//  Показывает нужный текст по выбранному разделу и закрывается через общий drag.
//

import SwiftUI

struct SettingsDetailModalView: View {
    let destination: SettingsDestination
    @ObservedObject var dragState: ModalDragState
    let onDismiss: () -> Void

    private var maxContentHeight: CGFloat {
        UIScreen.main.bounds.height * 0.68
    }

    var body: some View {
        VStack(spacing: 0) {
            dragArea
            Divider()
            AdaptiveSheetContent(maxHeight: maxContentHeight) {
                content
                    .padding(16)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.15), radius: 20, y: 8)
        .modalDragOffset(dragState)
    }

    private var dragArea: some View {
        ModalDragHandle(dragState: dragState, onDismiss: onDismiss) {
            header
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: destination.icon)
                .font(.system(size: 15))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(Color.brandAccent)
                .cornerRadius(8)
            Text(destination.title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Color(.label))
                .lineLimit(1)
                .minimumScaleFactor(0.82)
            Spacer()
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(.secondaryLabel))
                    .frame(width: 32, height: 32)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    @ViewBuilder
    private var content: some View {
        switch destination {
        case .notifications:
            NotificationSettingsContent()
        case .help:
            HelpFeedbackContent()
        case .privacy:
            PrivacyPolicyContent()
        case .about:
            AboutAppContent()
        }
    }
}
