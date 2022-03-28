import Foundation
import UIKit
import Combine

class LoginViewController: UIViewController, Animatable {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    @Published var errorString: String = ""
    @Published var isLoginSuccessfull = false
    
    weak var delegate: LoginVCDelegate?
    
    private var subscribers = Set<AnyCancellable>()
    
    private let authManager = AuthManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observeForm()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailTextField.becomeFirstResponder()
    }
    
    private func observeForm() {
        $errorString.sink { (errorMessage) in
            self.errorLabel.text = errorMessage
        }.store(in: &subscribers)
        
        $isLoginSuccessfull.sink {(isSuccessful) in
            if isSuccessful {
                self.delegate?.didLogin()
            }
        }.store(in: &subscribers)
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        
        guard let email = emailTextField.text,
                !email.isEmpty,
                let password = passwordTextField.text,
                !password.isEmpty else {
            errorString = "Incomplete form"
        return }
        
        self.showLoadingAnimation()
        
        authManager.login(withEmail: email, password: password) { result in
            self.hideLoadingAnimation()
            switch result {
            case .success:
                self.isLoginSuccessfull = true
            case.failure(let error):
                self.errorString = error.localizedDescription
            }
        }
    }
    
    @IBAction func signupButtonTapped(_sender: UIButton) {
        guard let email = emailTextField.text,
                !email.isEmpty,
                let password = passwordTextField.text,
                !password.isEmpty else {
            errorString = "Incomplete form"
        return }
        
        self.showLoadingAnimation()
        
        authManager.signUp(withEmail: email, password: password) { result in
            self.hideLoadingAnimation()
            switch result {
            case .success:
                self.showToast(state: .success, message: "Signed up successfuly")
                self.emailTextField.text = ""
                self.passwordTextField.text = ""
            case.failure(let error):
                self.errorString = error.localizedDescription
            }
        }
    }
}
