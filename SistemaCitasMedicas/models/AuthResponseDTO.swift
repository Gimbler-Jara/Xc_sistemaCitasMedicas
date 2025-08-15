//
//  AuthResponseDTO.swift
//  SistemaCitasMedicas
//
//  Created by Emerson Jara Gamarra on 13/08/25.
//

import UIKit

struct AuthResponseDTO: Codable {
    let token: String;
    let paciente: PacienteDTO
}
