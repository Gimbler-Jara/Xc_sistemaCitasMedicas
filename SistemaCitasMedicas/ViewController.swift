

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var txtCorreo: UITextField!
    @IBOutlet weak var txtContrasena: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func btnBack(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
    @IBAction func btnLogin(_ sender: UIButton) {
        
        let email = (txtCorreo.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let pass  = (txtContrasena.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !email.isEmpty, !pass.isEmpty else { return alert("Completa email y contraseña") }
        
        let payload = LoginRequestDTO(email: email, password: pass)
        
        APIClientUIKit.shared.login(payload) { result in
            switch result {
            case .success(let auth):
                Session.shared.token = auth.token
                Session.shared.paciente = auth.paciente
                Session.shared.emailLogin = email
                
                UserDefaults.standard.set(auth.token, forKey: "token")
                UserDefaults.standard.set(email, forKey: "emailLogin")
                
                self.txtCorreo.text = ""
                self.txtContrasena.text = ""
                
                self.performSegue(withIdentifier: "home", sender: self)
                
            case .failure(let e):
                self.alert(self.message(from: e))
            }
        }
    }
    
    
    @IBAction func btnRegistrar(_ sender: UIButton) {
        performSegue(withIdentifier: "registro", sender: nil)
    }
    
}

