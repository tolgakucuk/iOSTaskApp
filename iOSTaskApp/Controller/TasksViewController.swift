import UIKit

class TasksViewController: UIViewController, Animatable{
    
    
    @IBOutlet weak var menuSegmentedControl: UISegmentedControl!
    @IBOutlet weak var ongoingTasksContainerView: UIView!
    @IBOutlet weak var doneTasksContainerView: UIView!
    
    private let databaseManager = DatabaseManager()
    private let authManager = AuthManager()
    private let navigationManager = NavigationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        setupSegmentedControl()
        
    }

    private func setupSegmentedControl() {
        menuSegmentedControl.removeAllSegments()
        
        MenuSection.allCases.enumerated().forEach { (index, section) in
            menuSegmentedControl.insertSegment(withTitle: section.rawValue, at: index, animated: false)
        }
        
        menuSegmentedControl.selectedSegmentIndex = 0
        showContainerView(for: .ongoing)
    }
    
    private func logoutUser() {
        authManager.logout { result in
            switch result {
            case.success:
                self.navigationManager.show(scene: .onboarding)
            case.failure(let error):
                self.showToast(state: .error, message: error.localizedDescription)
            }
            
        }
    }
    
    private func showMenuOptions() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let logoutAction = UIAlertAction(title: "Logout", style: .default) { _ in
            self.logoutUser()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(logoutAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            showContainerView(for: .ongoing)
        case 1:
            showContainerView(for: .done)
        default:
            break
        }
    }
    
    @IBAction func menuButtonTapped(_sender: UIButton)  {
        showMenuOptions()
    }
    
    private func showContainerView(for section: MenuSection) {
        switch section {
        case .ongoing:
            ongoingTasksContainerView.isHidden = false
            doneTasksContainerView.isHidden = true
        case .done:
            ongoingTasksContainerView.isHidden = true
            doneTasksContainerView.isHidden = false
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showNewTask",
           let destination = segue.destination as? NewTaskViewController {
            destination.delegate = self
        } else if segue.identifier == "showOngoingTask" {
            let destination = segue.destination as? OngoingTableViewController
            destination?.delegate = self
        } else if segue.identifier == "showEditTask", let destination = segue.destination as? NewTaskViewController, let taskToEdit = sender as? Task {
            destination.delegate = self
            destination.taskToEdit = taskToEdit
        }
        
    }
    
    private func deleteTask(id: String) {
        databaseManager.deleteTask(id: id) { result in
            switch result {
            case.success:
                self.showToast(state: .success, message: "Task deleted successfully")
            case.failure(let error):
                self.showToast(state: .error, message: error.localizedDescription)
            
            }
        }
    }
    
    private func showEditTask(task: Task) {
        performSegue(withIdentifier: "showEditTask", sender: task)
    }
    
    @IBAction func addButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "showNewTask", sender: nil)
    }
}

extension TasksViewController: OngoingTasksTVCDelegate {
    func showOptions(for task: Task) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            guard let id = task.id else {return}
            self.deleteTask(id: id)
        }
        let editAction = UIAlertAction(title: "Edit", style: .destructive) { _ in
            self.showEditTask(task: task)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        alertController.addAction(editAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension TasksViewController: NewTaskVCDelegate {
    func didEditTask(_ task: Task) {
        presentedViewController?.dismiss(animated: true, completion: {
            guard let id = task.id else {return}
            self.databaseManager.editTask(id: id, title: task.title, deadline: task.dateLine) { result in
                switch result {
                case.success:
                    self.showToast(state: .success, message: "Task updated")
                case.failure(let error):
                    self.showToast(state: .error, message: error.localizedDescription)
                }
            }
        })
    }
    
    func didAddTask(_ task: Task) {
        presentedViewController?.dismiss(animated: true, completion: { [unowned self] in
            self.databaseManager.addTask(task) { result in
                switch result {
                case .success:
                    print("Task eklendi")
                case .failure(let error):
                    print("error: \(error.localizedDescription)")
                }
            }
        })
    }
}
