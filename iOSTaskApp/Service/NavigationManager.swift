import Foundation
import UIKit

class NavigationManager {
    static let shared = NavigationManager()
    
    enum Scene {
        case onboarding
        case tasks
    }
    
    func show(scene: Scene) {
        var controller: UIViewController
        switch scene {
        case .onboarding:
            controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OnboardingViewController")
        case .tasks:
            controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TasksViewController")
        }
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let sceneDelegate = windowScene.delegate as? SceneDelegate, let window = sceneDelegate.window else {return}
        window.rootViewController = controller
        UIView.transition(with: window, duration: 0.2, options: .transitionCrossDissolve, animations: {}, completion: nil)
        
    }
}
