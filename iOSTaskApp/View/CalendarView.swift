import UIKit
import FSCalendar

class CalendarView: UIView {
    
    weak var delegate: CalendarViewDelegate?
    
    private lazy var calendar: FSCalendar = {
        let calendar = FSCalendar()
        calendar.delegate = self
        return calendar
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Select deadline"
        label.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var removeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Remove", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemRed
        button.addTarget(self, action: #selector(removeButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, calendar, removeButton])
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .white
        addSubview(stackView)
        stackView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor,
                         paddingTop: 24, paddingLeft: 24, paddingBottom: 24, paddingRight: 24, height: 240)
    }
    
    @objc func removeButtonTapped(_ sender: UIButton) {
        if let selectedDate = calendar.selectedDate {
            calendar.deselect(selectedDate)
            delegate?.calendarViewDidTapRemoveButton()
        }
    }
}

extension CalendarView: FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        delegate?.calendarViewDidSelectDate(date: date)
    }
}
