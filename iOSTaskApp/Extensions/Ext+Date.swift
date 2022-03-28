import Foundation

extension Date {

    func toString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter.string(from: self)
    }
    
    
}
