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

        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnRegistrar(_ sender: UIButton) {
    }
    
    @IBAction func btnLogin(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
}
