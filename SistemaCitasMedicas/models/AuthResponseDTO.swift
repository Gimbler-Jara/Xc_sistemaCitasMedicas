

import UIKit

struct AuthResponseDTO: Codable {
    let token: String;
    let paciente: PacienteDTO
}
