//
//  CitasViewCell.swift
//  SistemaCitasMedicas
//
//  Created by Emerson Jara Gamarra on 13/08/25.
//

import UIKit

class CitasViewCell: UITableViewCell {

    @IBOutlet weak var lblMedico: UILabel!
    @IBOutlet weak var lblEspecialidad: UILabel!
    @IBOutlet weak var lblFecha: UILabel!
    @IBOutlet weak var lblHora: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
