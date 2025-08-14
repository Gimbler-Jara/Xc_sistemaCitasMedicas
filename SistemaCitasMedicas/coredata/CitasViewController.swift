//
//  CitasViewController.swift
//  SistemaCitasMedicas
//
//  Created by Emerson Jara Gamarra on 13/08/25.
//

import UIKit

class CitasViewController: UIViewController,UITableViewDataSource {
   
    

    
    @IBOutlet weak var tvPaciente: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
   
    
    @IBAction func btnRegresar(_ sender: UIButton) {
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
}
