//
//  ViewController.swift
//  SistemaCitasMedicas
//
//  Created by Emerson Jara Gamarra on 13/08/25.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var txtCorreo: UITextField!
    @IBOutlet weak var txtContrasena: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
                
                // Limpiar campos
                DispatchQueue.main.async {
                    self.txtCorreo.text = ""
                    self.txtContrasena.text = ""
                    
                    // Ir a Home
                    self.performSegue(withIdentifier: "home", sender: self)
                }
            case .failure(let e):
                self.alert(self.message(from: e))
            }
        }
    }
    
    
    @IBAction func btnRegistrar(_ sender: UIButton) {
        performSegue(withIdentifier: "registro", sender: nil)
        
        
    }
    
    
}

