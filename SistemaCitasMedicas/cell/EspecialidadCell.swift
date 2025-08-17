//
//  EspecialidadCell.swift
//  SistemaCitasMedicas
//
//  Created by Emerson Jara Gamarra on 17/08/25.
//

import UIKit

class EspecialidadCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .secondarySystemBackground
        
        titleLbl.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLbl.textColor = .label
    }
    
}
