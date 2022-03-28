import UIKit
import Combine

class NewTaskViewController: UIViewController {
    
    //MARK: - Properties
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deadlineLabel: UILabel!
    
    weak var delegate: NewTaskVCDelegate?
    
    private let authManager = AuthManager()
    
    private lazy var calendarView: CalendarView = {
        let view = CalendarView()
        view.delegate = self
        return view
    }()
    
    var taskToEdit: Task?
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupGesture()
        observeKeyboard()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        taskTextField.becomeFirstResponder()
    }
    
    //MARK: - Helper Functions
    
    private func setupView() {
        backgroundView.backgroundColor = UIColor.init(white: 0.3, alpha: 0.4)
        containerViewBottomConstraint.constant = -containerView.frame.height
        
        if let taskToEdit = self.taskToEdit {
            taskTextField.text = taskToEdit.title
            deadlineLabel.text = taskToEdit.dateLine
            saveButton.setTitle("Update", for: .normal)
        }
    }
    
    
    
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    private func observeKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func getKeyboardHeight(notification : Notification) -> CGFloat {
        guard let keyboardHeight =
                (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else {return 0}
        return keyboardHeight
    }
    
    private func showCalendar() {
        view.addSubview(calendarView)
        calendarView.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor,
                            paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
    }
    
    private func dismissCalendar() {
        calendarView.removeFromSuperview()
        taskTextField.becomeFirstResponder()
    }
    
    //MARK: - Selectors
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        let keyboardHeight = getKeyboardHeight(notification: notification)
        containerViewBottomConstraint.constant = keyboardHeight - (200 + 8)
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        containerViewBottomConstraint.constant = -containerView.frame.height
    }
    
    @objc private func dismissView() {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Actions
    
    
    @IBAction func calendarButtonClicked(_ sender: Any) {
        taskTextField.resignFirstResponder()
        showCalendar()
    }
    
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        guard let taskString = taskTextField.text else {return}
        guard let dateLine = deadlineLabel.text else {return}
        guard let uid = authManager.getUserId() else {return}
        
        var task = Task(title: taskString, dateLine: dateLine, uid: uid)
        
        if let id = taskToEdit?.id {
            task.id = id
        }
        
        if taskToEdit == nil {
            delegate?.didAddTask(task)
        } else {
            delegate?.didEditTask(task)
        }
        
        
    }
}

extension NewTaskViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if calendarView.isDescendant(of: view) {
            if touch.view?.isDescendant(of: calendarView) == false {
                dismissCalendar()
            }
            return false
        }
        
        return true
    }
}

extension NewTaskViewController: CalendarViewDelegate {
    func calendarViewDidSelectDate(date: Date) {
        dismissCalendar()
        deadlineLabel.text = date.toString()
    }
    
    func calendarViewDidTapRemoveButton() {
        dismissCalendar() 
        self.deadlineLabel.text = ""
    }
}
