//
//  PacienteDTO.swift
//  SistemaCitasMedicas
//
//  Created by Emerson Jara Gamarra on 13/08/25.
//

import UIKit

struct PacienteDTO: Codable {
    let id: Int;
    let nombreCompleto: String;
    let email: String;
    let fotoUrl: String?
}
