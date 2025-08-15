//
//  RegistroRequestDTO.swift
//  SistemaCitasMedicas
//
//  Created by Emerson Jara Gamarra on 13/08/25.
//

import UIKit

struct RegistroRequestDTO: Codable {
    let dni, nombre, apellido, email, telefono, password: String;
    let fotoUrl: String?
}
