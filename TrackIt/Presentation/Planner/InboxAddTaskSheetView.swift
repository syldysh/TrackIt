//
//  InboxAddTaskSheetView.swift
//  TrackIt
//
//  Bottom sheet добавления новой задачи во «Входящие».
//

import SwiftUI

struct InboxAddTaskSheetView: View {
    @EnvironmentObject var vm: InboxViewModel

    @ObservedObject var dragState: ModalDragState
    let inputFocused: FocusState<Bool>.Binding
    let onCommit: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 0) {
                sheetHeader
                hint
                textField
                sheetButtons
            }
            .background(Color(.systemBackground))
            .cornerRadius(20, corners: [.topLeft, .topRight])
            .modalDragOffset(dragState)
        }
        .ignoresSafeArea(edges: .bottom)
    }

    // MARK: - Content

    private var sheetHeader: some View {
        ModalDragHandle(dragState: dragState, onDismiss: onDismiss) {
            HStack {
                Text("Новая задача")
                    .font(.system(size: 20, weight: .semibold))
                Spacer()
                Button { onDismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(.secondaryLabel))
                        .frame(width: 32, height: 32)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 12)
    }

    private var hint: some View {
        (Text("Задачу можно будет запланировать через режим планирования ")
            + Text(Image(systemName: "bolt.fill")).foregroundColor(.orange))
            .font(.system(size: 13))
            .foregroundColor(Color(.secondaryLabel))
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
    }

    private var textField: some View {
        TextField("Что нужно сделать?", text: $vm.newText)
            .focused(inputFocused)
            .font(.system(size: 17))
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(.systemGray6))
            .cornerRadius(16)
            .padding(.horizontal, 20)
            .submitLabel(.done)
            .onSubmit { onCommit() }
            .padding(.bottom, 20)
    }

    private var sheetButtons: some View {
        HStack(spacing: 12) {
            Button { onDismiss() } label: {
                Text("Отмена")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.red)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
            }
            Button { onCommit() } label: {
                Text("Добавить")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(vm.canAdd ? Color.brandAccent : Color.brandAccent.opacity(0.35))
                    .animation(.smoothSpring, value: vm.canAdd)
                    .cornerRadius(16)
            }
            .disabled(!vm.canAdd)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
    }
}
