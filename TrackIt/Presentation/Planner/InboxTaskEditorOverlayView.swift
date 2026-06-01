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
    let onBackgroundTap: () -> Void

    var body: some View {
        if formVM.showAddTask {
            ModalDimBackground(dragState: dragState, baseOpacity: 0.3, onTap: onBackgroundTap)
                .transition(.opacity)
                .zIndex(29)

            AddTaskOverlay(
                formVM: formVM,
                addFocused: inputFocused,
                dragState: dragState,
                onDismiss: onDismiss,
                onBackgroundTap: onBackgroundTap
            )
            .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .identity))
            .zIndex(30)
        }
    }
}
