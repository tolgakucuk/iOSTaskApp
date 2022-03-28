import Foundation

protocol NewTaskVCDelegate: AnyObject {
    func didAddTask(_ task: Task)
    func didEditTask(_ task: Task)
}
