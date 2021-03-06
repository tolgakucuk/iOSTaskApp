import Foundation
import FirebaseFirestoreSwift

struct Task: Identifiable, Codable {
    
    @DocumentID var id: String?
    @ServerTimestamp var createdAt: Date?
    let title: String
    var isDone: Bool = false
    var doneAt: Date?
    var dateLine: String
    let uid: String
}
