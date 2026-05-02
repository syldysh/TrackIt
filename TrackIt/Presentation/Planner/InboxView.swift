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
    @State private var showPlanningMode = false
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
                    addTaskSheet
                        .transition(.move(edge: .bottom))
                        .zIndex(20)
                }
            }
        }
        .background(TabBarHider(hide: vm.showAddModal || showPlanningMode))
        .onChange(of: vm.showAddModal) { _, isPresented in
            if isPresented { addTaskDragState.reset() }
        }
    }

    // MARK: - Main Content

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

    // MARK: - Empty State

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

    // MARK: - Task List

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
                        InboxTaskRow(task: task, onDelete: { vm.delete(task) })
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

    // MARK: - Floating Buttons

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

    // MARK: - Add Task Sheet

    private var addTaskSheet: some View {
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
            .offset(y: addTaskDragState.offset)
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private var sheetHeader: some View {
        ModalDragHandle(dragState: addTaskDragState, onDismiss: dismissAdd) {
            HStack {
                Text("Новая задача")
                    .font(.system(size: 20, weight: .semibold))
                Spacer()
                Button { dismissAdd() } label: {
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
            .focused($inputFocused)
            .font(.system(size: 17))
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(.systemGray6))
            .cornerRadius(16)
            .padding(.horizontal, 20)
            .submitLabel(.done)
            .onSubmit { commit() }
            .padding(.bottom, 20)
    }

    private var sheetButtons: some View {
        HStack(spacing: 12) {
            Button { dismissAdd() } label: {
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
            Button { commit() } label: {
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

    // MARK: - Actions

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
}
