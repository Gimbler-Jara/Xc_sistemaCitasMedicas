//
//  DoctorDTO.swift
//  SistemaCitasMedicas
//
//  Created by Emerson Jara Gamarra on 13/08/25.
//

import UIKit

struct DoctorDTO: Codable {
    let id: Int;
    let nombreCompleto: String;
    let especialidadId: Int
}
