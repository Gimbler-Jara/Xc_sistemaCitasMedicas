//
//  CitaRequestDTO.swift
//  SistemaCitasMedicas
//
//  Created by Emerson Jara Gamarra on 13/08/25.
//

import UIKit

struct CitaRequestDTO: Codable {
    let pacienteId: Int;
    let doctorId: Int;
    let fecha: String;
    let slotId: Int
}
