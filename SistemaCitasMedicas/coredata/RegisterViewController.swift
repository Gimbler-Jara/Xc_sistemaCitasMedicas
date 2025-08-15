//
//  RegisterViewController.swift
//  SistemaCitasMedicas
//
//  Created by Emerson Jara Gamarra on 13/08/25.
//

import UIKit

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var txtNombre: UITextField!
    @IBOutlet weak var txtApellido: UITextField!
    @IBOutlet weak var txtDni: UITextField!
    @IBOutlet weak var txtTelefono: UITextField!
    @IBOutlet weak var txtCorreo: UITextField!
    @IBOutlet weak var txtContrasena: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func btnRegistrar(_ sender: UIButton) {
        guard
            let dni=txtDni.text,
            let nom=txtNombre.text,
            let ape=txtApellido.text,
            let email=txtCorreo.text,
            let tel=txtTelefono.text,
            let pass=txtContrasena.text,
            !dni.isEmpty, !nom.isEmpty, !ape.isEmpty, !email.isEmpty, !pass.isEmpty else {
            return alert("Completa todos los campos obligatorios")
        }
        let req = RegistroRequestDTO(dni: dni, nombre: nom, apellido: ape, email: email, telefono: tel, password: pass, fotoUrl : nil)
        APIClientUIKit.shared.register(req) { res in
            switch res {
            case .success(_):
                // Autologin
                APIClientUIKit.shared.login(.init(email: email, password: pass)) { r in
                    switch r {
                    case .success(let auth):
                        Session.shared.token = auth.token
                        Session.shared.paciente = auth.paciente
                        Session.shared.emailLogin = email
                        
                        //sacar un mensaje de exito y limpiar los campos
                        self.showSuccessThen {
                            self.clearForm()
                            self.dismiss(animated: true)
                        }
                    case .failure(let e):
                        self.alert(self.message(from: e))
                    }
                }
            case .failure(let e):
                self.alert(self.message(from: e))
            }
        }
    }
    
    private func clearForm() {
        [txtNombre, txtApellido, txtDni, txtCorreo, txtTelefono, txtContrasena]
            .forEach { $0?.text = "" }
        view.endEditing(true)
    }
    
    private func showSuccessThen(_ action: @escaping () -> Void) {
        let ac = UIAlertController(title: "Éxito",
                                   message: "Registro completado",
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default) { _ in action() })
        present(ac, animated: true)
    }
    
    @IBAction func btnLogin(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
}
