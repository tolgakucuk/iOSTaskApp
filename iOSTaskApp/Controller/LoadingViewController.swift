import Foundation
import UIKit

class LoadingViewController: UIViewController {
    
    let authManager = AuthManager()
    let navigationManager = NavigationManager()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showInitialScreen()
    }
    
    func showInitialScreen() {
        if authManager.isLoggedIn() {
            navigationManager.show(scene: .tasks)
        } else {
            navigationManager.show(scene: .onboarding)
        }
    }
}
