//
//  Session.swift
//  SistemaCitasMedicas
//
//  Created by Emerson Jara Gamarra on 13/08/25.
//

import UIKit

final class Session: NSObject {
    static let shared = Session()
       var paciente: PacienteDTO?
       var token: String?
       var emailLogin: String?
}
