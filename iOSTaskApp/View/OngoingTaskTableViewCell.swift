import UIKit

class OngoingTaskTableViewCell: UITableViewCell {
    
    var actionButtonDidTap: (() -> Void)?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var deadlineLabel: UILabel!
    
    func configure(with task: Task) {
        titleLabel.text = task.title
        deadlineLabel.text = "ends at \(task.dateLine) " 
    }
    
    @IBAction func actionButtonTapped(_ sender: UIButton) {
        actionButtonDidTap?()
    }
    
}
