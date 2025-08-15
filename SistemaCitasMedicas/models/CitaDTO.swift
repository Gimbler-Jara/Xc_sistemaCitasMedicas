//
//  CitaDTO.swift
//  SistemaCitasMedicas
//
//  Created by Emerson Jara Gamarra on 13/08/25.
//

import UIKit

struct CitaDTO: Codable {
    let id: Int;
    let fecha: String;
    let hora: String;
    let especialidad: String;
    let doctorNombre: String;
    let estado: String
}
