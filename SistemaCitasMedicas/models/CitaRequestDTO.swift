

import UIKit

struct CitaRequestDTO: Codable {
    let pacienteId: Int;
    let doctorId: Int;
    let fecha: String;
    let slotId: Int
}
