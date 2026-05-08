//
//  ScheduleMonthPickerView.swift
//  TrackIt
//
//  Контролируемый календарь для режима планирования.
//  Сохраняет выбранный номер дня при переключении месяцев.
//

import SwiftUI

struct ScheduleMonthPickerView: View {
    @ObservedObject var formVM: SchedulePickerViewModel

    var body: some View {
        CalendarMonthPickerView(
            displayedMonth: formVM.displayedMonth,
            selectedDate: formVM.nativeDateSelection,
            minimumDate: formVM.today,
            canGoToPreviousMonth: formVM.canGoToPreviousMonth,
            showsTodayButton: formVM.shouldShowTodayButton,
            onPreviousMonth: { formVM.goToPreviousMonth() },
            onNextMonth: { formVM.goToNextMonth() },
            onToday: { formVM.goToToday() },
            onSelectDay: { formVM.selectDayInDisplayedMonth($0) }
        )
    }
}
