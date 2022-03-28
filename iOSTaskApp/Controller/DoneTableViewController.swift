import Foundation
import UIKit
import Loaf

class DoneTableViewController: UITableViewController, Animatable{
    
    private var tasks: [Task] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    private let databaseManager = DatabaseManager()
    private let authManager = AuthManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listenToTask()
    }
    
    private func listenToTask() {
        guard let uid = authManager.getUserId() else {return}
        databaseManager.addTasksListener(forDoneTasks: true, uid: uid) { result in
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
        databaseManager.updateTaskStatus(id: id, isDone: false) { result in
            switch result {
            case.success:
                self.showToast(state: .info, message: "Moved to Ongoing")
            case.failure(let error):
                self.showToast(state: .error, message: error.localizedDescription)
            }
        }
    }
    
}

extension DoneTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! DoneTaskTableViewCell
        let task = tasks[indexPath.item]
        cell.configure(with: task)
        cell.actionButtonDidTap = { [weak self] in
            self?.handleactionButton(for: task)
            
        }
        return cell
    }
}
