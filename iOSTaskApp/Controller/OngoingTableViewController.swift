import Foundation
import UIKit

protocol OngoingTasksTVCDelegate: AnyObject {
    func showOptions(for task: Task)
}

class OngoingTableViewController: UITableViewController , Animatable{
    
    private let databaseManager = DatabaseManager()
    private let authManager = AuthManager()
    
    private var tasks: [Task] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    weak var delegate: OngoingTasksTVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listenToTask()
    }
    
    private func listenToTask() {
        guard let uid = authManager.getUserId() else {return}
        databaseManager.addTasksListener(forDoneTasks: false, uid: uid) { result in
            switch result {
            case.success(let tasks):
                self.tasks = tasks
            case.failure(let error):
                self.showToast(state: .error, message: error.localizedDescription)
            }
        }
    }
    
    private  func handleactionButton(for task: Task) {
        guard let id = task.id else {return}
        
        databaseManager.updateTaskStatus(id: id, isDone: true) { result in
            switch result {
            case.success:
                self.showToast(state: .info, message: "Moved to Done")
            case.failure(let error):
                self.showToast(state: .error, message: error.localizedDescription)
            }
        }
    }
}

extension OngoingTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! OngoingTaskTableViewCell
        let task = tasks[indexPath.row]
        cell.actionButtonDidTap = { [weak self] in
            self?.handleactionButton(for: task)
        }
        cell.configure(with: task)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let task = tasks[indexPath.row]
        delegate?.showOptions(for: task)
    }
}
