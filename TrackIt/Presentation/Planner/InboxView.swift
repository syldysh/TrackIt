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
                    ModalDimBackground(dragState: addTaskDragState, baseOpacity: 0.3, onTap: dismissAdd)
                        .transition(.opacity)
                        .zIndex(19)
                }
                if vm.showAddModal {
                    InboxAddTaskSheetView(
                        dragState: addTaskDragState,
                        inputFocused: $inputFocused,
                        onCommit: commit,
                        onDismiss: dismissAdd
                    )
                    .environmentObject(vm)
                        .transition(.move(edge: .bottom))
                        .zIndex(20)
                }
                if taskToSchedule != nil {
                    scheduleTaskSheet
                        .zIndex(30)
                }
            }
        }
        .background(TabBarHider(hide: vm.showAddModal || showPlanningMode || taskToSchedule != nil))
        .onChange(of: vm.showAddModal) { _, isPresented in
            if isPresented { addTaskDragState.reset() }
        }
        .onChange(of: taskToSchedule?.id) { _, taskID in
            if taskID != nil { scheduleTaskDragState.reset() }
        }
    }

    private var mainContent: some View {
        ZStack {
            Color(.secondarySystemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Text("Планировщик")
                        .font(.system(size: 34, weight: .bold))
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 12)
                .background(Color(.systemBackground))

                if vm.inboxTasks.isEmpty {
                    emptyState
                } else {
                    taskList
                }
            }
        }
    }

    private var emptyState: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 16) {
                    Spacer(minLength: 24)
                    Button {
                        withAnimation(.sheetSpring) { vm.showAddModal = true }
                        inputFocused = true
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
                    Spacer(minLength: 24)
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: proxy.size.height)
                .padding(.horizontal, 24)
            }
        }
    }

    private var taskList: some View {
        ScrollView {
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
                            onDelete: { vm.delete(task) }
                        )
                        if task.id != vm.inboxTasks.last?.id {
                            Divider().padding(.leading, 20)
                        }
                    }
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 100)
        }
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
                            inputFocused = true
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
        withAnimation(.sheetSpring) { vm.commitTask() }
        inputFocused = false
    }

    private func dismissAdd() {
        withAnimation(.sheetSpring) {
            vm.showAddModal = false
            vm.newText = ""
        }
        inputFocused = false
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
}
