//
//  InboxView.swift
//  TrackIt
//
//  Экран планировщика со списком задач без даты.
//  Отсюда можно быстро добавить задачу или перейти в режим планирования.
//

import SwiftUI

struct InboxView: View {
    @EnvironmentObject var vm: InboxViewModel

    @StateObject private var addTaskDragState = ModalDragState(dismissDistance: 100, predictedDismissDistance: 190)
    @StateObject private var scheduleTaskDragState = ModalDragState(dismissDistance: 100, predictedDismissDistance: 190)
    @StateObject private var editTaskDragState = ModalDragState()
    @State private var showPlanningMode = false
    @State private var taskToSchedule: Task?
    @FocusState private var inputFocused: Bool

    var body: some View {
        ZStack {
            if showPlanningMode {
                Color.black.opacity(0.72)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .zIndex(9)

                PlanningModeView(isPresented: $showPlanningMode, initialQueue: vm.inboxTasks)
                    .environmentObject(vm)
                    .transition(.move(edge: .trailing))
                    .id("planning")
                    .zIndex(10)
            } else {
                mainContent
                floatingButtons
                if vm.showAddModal {
                    ModalDimBackground(dragState: addTaskDragState, baseOpacity: 0.3, onTap: dismissAddFromBackground)
                        .transition(.opacity)
                        .zIndex(19)
                }
                if vm.showAddModal {
                    InboxAddTaskSheetView(
                        dragState: addTaskDragState,
                        inputFocused: $inputFocused,
                        onCommit: commit,
                        onDismiss: { finishAddDismiss() },
                        onBackgroundTap: dismissAddFromBackground
                    )
                    .environmentObject(vm)
                        .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .identity))
                        .zIndex(20)
                }
                if taskToSchedule != nil {
                    scheduleTaskSheet
                        .zIndex(30)
                }
                InboxTaskEditorOverlayView(
                    formVM: vm.taskEditorVM,
                    dragState: editTaskDragState,
                    inputFocused: $inputFocused,
                    onDismiss: finishTaskEditorDismiss,
                    onBackgroundTap: dismissTaskEditorFromBackground
                )
            }
        }
        .background(TabBarHider(hide: vm.showAddModal || vm.taskEditorVM.showAddTask || showPlanningMode || taskToSchedule != nil))
        .onChange(of: vm.showAddModal) { _, isPresented in
            if isPresented { addTaskDragState.reset() }
        }
        .onChange(of: taskToSchedule?.id) { _, taskID in
            if taskID != nil { scheduleTaskDragState.reset() }
        }
        .onChange(of: vm.taskEditorVM.showAddTask) { _, isPresented in
            if isPresented { editTaskDragState.reset() }
        }
    }

    private var mainContent: some View {
        NavigationStack {
            GeometryReader { proxy in
                ScrollView {
                    if vm.inboxTasks.isEmpty {
                        emptyState
                            .frame(minHeight: proxy.size.height, alignment: .center)
                    } else {
                        taskList
                    }
                }
                .scrollDisabled(vm.inboxTasks.isEmpty)
            }
            .background(Color(.secondarySystemBackground))
            .navigationTitle("Планировщик")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Button {
                withAnimation(.sheetSpring) { vm.showAddModal = true }
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 72, height: 72)
                    .background(Color.brandAccent)
                    .clipShape(Circle())
            }
            Text("Нет задач")
                .font(.system(size: 28, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.82)
            (Text("Нажмите + чтобы добавить задачу, а\nзатем запланируйте её с помощью ")
                + Text(Image(systemName: "bolt.fill")).foregroundColor(.orange))
                .font(.system(size: 17))
                .foregroundColor(Color(.secondaryLabel))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
    }

    private var taskList: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("ЗАДАЧИ — \(vm.inboxTasks.count)")
                .sectionHeaderStyle()
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                ForEach(vm.inboxTasks) { task in
                    InboxTaskRow(
                        task: task,
                        onSchedule: { openScheduleSheet(for: task) },
                        onDelete: { vm.delete(task) },
                        onEdit: { openTaskEditor(for: task) }
                    )
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 100)
    }

    @ViewBuilder
    private var floatingButtons: some View {
        if !vm.inboxTasks.isEmpty {
            VStack(spacing: 12) {
                Spacer()
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        Button {
                            withAnimation(.sheetSpring) { showPlanningMode = true }
                        } label: {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(Color.brandOrange)
                                .clipShape(Circle())
                                .shadow(color: .orange.opacity(0.35), radius: 12, y: 6)
                        }
                        Button {
                            withAnimation(.sheetSpring) { vm.showAddModal = true }
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(Color.brandAccent)
                                .clipShape(Circle())
                                .shadow(color: .blue.opacity(0.35), radius: 12, y: 6)
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 24)
                }
            }
        }
    }

    private var scheduleTaskSheet: some View {
        PlanningScheduleOverlayView(
            task: taskToSchedule,
            notificationService: vm.notificationService,
            calendarSyncService: vm.calendarSyncService,
            dragState: scheduleTaskDragState,
            onSchedule: scheduleSingleTask,
            onCancel: dismissScheduleSheet
        )
    }

    private func commit() {
        guard let title = vm.trimmedDraftTitle else { return }
        dismissAdd(clearDraftAfterClose: false) {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                vm.addInboxTask(title: title)
                if !vm.showAddModal {
                    vm.clearAddDraft()
                }
            }
        }
    }

    private func dismissAdd(clearDraftAfterClose: Bool = true, afterClose: (() -> Void)? = nil) {
        inputFocused = false
        addTaskDragState.dismiss {
            finishAddDismiss(clearDraftAfterClose: clearDraftAfterClose, afterClose: afterClose)
        }
    }

    private func finishAddDismiss(clearDraftAfterClose: Bool = true, afterClose: (() -> Void)? = nil) {
        vm.hideAddModal()
        afterClose?()
        guard clearDraftAfterClose else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + ModalDismissalTiming.cleanupDelay) {
            guard !vm.showAddModal else { return }
            vm.clearAddDraft()
        }
    }

    private func dismissAddFromBackground() {
        inputFocused = false
        DispatchQueue.main.async {
            dismissAdd()
        }
    }

    private func openScheduleSheet(for task: Task) {
        scheduleTaskDragState.reset()
        withAnimation(.sheetSpring) { taskToSchedule = task }
    }

    private func scheduleSingleTask(
        _ task: Task,
        date: Date,
        time: String?,
        duration: Int16,
        reminderEnabled: Bool,
        calendarSyncEnabled: Bool
    ) {
        vm.scheduleFromInbox(
            task,
            date: date,
            time: time,
            duration: duration,
            reminderEnabled: reminderEnabled,
            calendarSyncEnabled: calendarSyncEnabled
        )
        withAnimation(.sheetSpring) { taskToSchedule = nil }
    }

    private func dismissScheduleSheet() {
        withAnimation(.sheetSpring) { taskToSchedule = nil }
    }

    private func openTaskEditor(for task: Task) {
        editTaskDragState.reset()
        withAnimation(.sheetSpring) { vm.taskEditorVM.prepareEditTask(task) }
    }

    private func dismissTaskEditor() {
        inputFocused = false
        editTaskDragState.dismiss(onDismiss: finishTaskEditorDismiss)
    }

    private func finishTaskEditorDismiss() {
        vm.taskEditorVM.hideForm()
        DispatchQueue.main.asyncAfter(deadline: .now() + ModalDismissalTiming.cleanupDelay) {
            guard !vm.taskEditorVM.showAddTask else { return }
            vm.taskEditorVM.clearFormState()
        }
    }

    private func dismissTaskEditorFromBackground() {
        inputFocused = false
        DispatchQueue.main.async {
            dismissTaskEditor()
        }
    }
}
