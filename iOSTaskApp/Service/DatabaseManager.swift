import FirebaseFirestore
import FirebaseFirestoreSwift

class DatabaseManager {
    
    //MARK: - Properties
    
    private let db = Firestore.firestore()
    private lazy var tasksCollection = db.collection("tasks")
    private var listener: ListenerRegistration?
    
    //MARK: - Helper Functions
    
    func addTask(_ task: Task, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            _ = try tasksCollection.addDocument(from: task, completion: { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            })
        } catch (let error) {
            completion(.failure(error))
        }
    }
    
    func addTasksListener(forDoneTasks isDone: Bool, uid: String,completion: @escaping(Result<[Task], Error>) -> Void) {
        listener = tasksCollection
            .whereField("uid", isEqualTo: uid)
            .whereField("isDone", isEqualTo: isDone )
            .order(by: "createdAt", descending: true)
            .addSnapshotListener({ snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                var tempTasks = [Task]()
                snapshot?.documents.forEach({ document in
                    if let task = try? document.data(as: Task.self) {
                        tempTasks.append(task)
                    }
                })
                completion(.success(tempTasks))
            }
        })
    }
    
    func updateTaskStatus(id: String, isDone: Bool, completion: @escaping(Result<Void, Error>) -> Void) {
        var fields: [String: Any] = [:]
        
        if isDone {
            fields = ["isDone" : true, "doneAt": Date()]
        } else {
            fields = ["isDone" : false, "doneAt": FieldValue.delete()]
        }
        
        tasksCollection.document(id).updateData(fields) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
        
    }
    
    func deleteTask(id: String, completion: @escaping(Result<Void, Error>) -> Void) {
        tasksCollection.document(id).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
                
        }
    }
    
    func editTask(id: String, title: String, deadline: String, completion: @escaping(Result<Void, Error>) -> Void) {
        let data: [String: Any] = ["title": title, "dateLine": deadline as Any]
        tasksCollection.document(id).updateData(data) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
