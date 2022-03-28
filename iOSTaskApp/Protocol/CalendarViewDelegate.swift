import Foundation

protocol CalendarViewDelegate: AnyObject {
    func calendarViewDidSelectDate(date: Date)
    func calendarViewDidTapRemoveButton()
}
