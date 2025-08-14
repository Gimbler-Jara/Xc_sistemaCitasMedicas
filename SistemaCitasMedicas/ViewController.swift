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
        performSegue(withIdentifier: "home", sender: nil)
    }
    
    
    @IBAction func btnRegistrar(_ sender: UIButton) {
        performSegue(withIdentifier: "registro", sender: nil)
    }
    

}

