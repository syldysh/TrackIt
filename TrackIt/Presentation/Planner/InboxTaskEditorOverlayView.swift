//
//  InboxTaskEditorOverlayView.swift
//  TrackIt
//
//  Переиспользует общую форму редактирования задачи на экране планировщика.
//

import SwiftUI

struct InboxTaskEditorOverlayView: View {
    @ObservedObject var formVM: AddTaskViewModel
    @ObservedObject var dragState: ModalDragState
    let inputFocused: FocusState<Bool>.Binding
    let onDismiss: () -> Void

    var body: some View {
        if formVM.showAddTask {
            ModalDimBackground(dragState: dragState, baseOpacity: 0.3, onTap: onDismiss)
                .transition(.opacity)
                .zIndex(29)

            AddTaskOverlay(
                formVM: formVM,
                addFocused: inputFocused,
                dragState: dragState,
                onDismiss: onDismiss
            )
            .transition(.move(edge: .bottom))
            .zIndex(30)
        }
    }
}
