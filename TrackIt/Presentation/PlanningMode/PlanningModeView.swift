//
//  PlanningModeView.swift
//  TrackIt
//
//  Режим быстрого планирования: карточки задач пролистываются свайпами.
//  Вправо — запланировать, влево — пропустить, вниз — удалить.
//

import SwiftUI

struct PlanningModeView: View {
    @EnvironmentObject var vm: InboxViewModel
    @Binding var isPresented: Bool
    let initialQueue: [Task]

    @State private var queue: [Task]? = nil
    @State private var currentIndex = 0
    @State private var offset: CGSize = .zero
    @State private var lockedAxis: SwipeAxis? = nil
    @State private var swipeHandled = false
    @State private var showScheduler = false
    @State private var pendingTask: Task? = nil

    enum SwipeAxis { case horizontal, vertical }

    private var activeQueue: [Task] { queue ?? initialQueue }
    private var currentTask: Task? { activeQueue[safe: currentIndex] }
    private func ensureQueue() { if queue == nil { queue = initialQueue } }
    private var remaining: Int { max(0, activeQueue.count - currentIndex) }
    private var isFinished: Bool { activeQueue.isEmpty || currentIndex >= activeQueue.count }

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    guard !showScheduler else { return }
                    dismiss()
                }

            VStack(spacing: 0) {
                header
                counter
                if isFinished {
                    finishedState
                } else {
                    Spacer()
                    cardSection
                    Spacer()
                    Text("Свайп: ← пропустить · → запланировать · ↓ удалить")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.4))
                        .padding(.bottom, 16)
                }
            }

            if showScheduler, let task = pendingTask {
                SchedulePickerView(
                    task: task,
                    onSchedule: { date, time, duration in scheduleTask(task, on: date, time: time, duration: duration) },
                    onCancel: { cancelSchedule() }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(20)
            }
        }
        .animation(.sheetSpring, value: showScheduler)
        .onAppear { if queue == nil { queue = initialQueue } }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 8) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.brandAccent)
                    .frame(width: 32, height: 32)
            }
            Image(systemName: "bolt.fill")
                .font(.system(size: 16))
                .foregroundColor(.brandOrange)
            Text("Режим планирования")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    private var counter: some View {
        HStack {
            Spacer()
            Text("\(remaining) \(RuDate.pluralTasks(remaining)) осталось")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.6))
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.12))
                .cornerRadius(16)
            Spacer()
        }
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    // MARK: - Card

    @ViewBuilder
    private var cardSection: some View {
        if let task = currentTask {
            PlanningCardView(
                task: task,
                totalRemaining: remaining,
                offset: offset
            )
            .gesture(
                DragGesture()
                    .onChanged { v in
                        if lockedAxis == nil && (abs(v.translation.width) > 10 || abs(v.translation.height) > 10) {
                            lockedAxis = abs(v.translation.width) >= abs(v.translation.height) ? .horizontal : .vertical
                        }
                        switch lockedAxis {
                        case .horizontal:
                            offset = CGSize(width: v.translation.width, height: 0)
                        case .vertical:
                            offset = CGSize(width: 0, height: max(v.translation.height, 0))
                        case nil:
                            break
                        }
                    }
                    .onEnded { v in
                        handleSwipe(v, task: task)
                        lockedAxis = nil
                    }
            )
        }
    }

    // MARK: - Finished

    private var finishedState: some View {
        VStack {
            Spacer()
            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundColor(.brandGreen)
                Text("Всё запланировано!")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    if isFinished { dismiss() }
                }
            }
            Spacer()
        }
    }

    // MARK: - Swipe Handling

    private func handleSwipe(_ value: DragGesture.Value, task: Task) {
        guard !swipeHandled else { return }
        let tx = offset.width
        let ty = offset.height

        if tx > 90 && lockedAxis == .horizontal {
            swipeHandled = true
            withAnimation(.smoothSpring) { offset = .zero }
            pendingTask = task
            showScheduler = true
            swipeHandled = false
        } else if tx < -90 && lockedAxis == .horizontal {
            swipeHandled = true
            withAnimation(.smoothSpring) { offset = CGSize(width: -500, height: 0) }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                offset = .zero
                currentIndex += 1
                swipeHandled = false
            }
        } else if ty > 100 && lockedAxis == .vertical {
            swipeHandled = true
            withAnimation(.smoothSpring) { offset = CGSize(width: 0, height: 500) }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                offset = .zero
                ensureQueue()
                vm.delete(task)
                removeCurrentTaskFromQueue()
                swipeHandled = false
            }
        } else {
            withAnimation(.smoothSpring) { offset = .zero }
        }
    }

    private func scheduleTask(_ task: Task, on date: Date, time: String? = nil, duration: Int16 = 0) {
        vm.scheduleFromInbox(task, date: date, time: time, duration: duration)
        removeCurrentTaskFromQueue()
        showScheduler = false
        pendingTask = nil
    }

    private func cancelSchedule() {
        showScheduler = false
        pendingTask = nil
    }

    private func dismiss() {
        withAnimation(.sheetSpring) { isPresented = false }
    }

    private func removeCurrentTaskFromQueue() {
        ensureQueue()
        guard var queue, queue.indices.contains(currentIndex) else { return }
        queue.remove(at: currentIndex)
        if currentIndex >= queue.count && currentIndex > 0 {
            currentIndex = queue.count - 1
        }
        self.queue = queue
    }
}
