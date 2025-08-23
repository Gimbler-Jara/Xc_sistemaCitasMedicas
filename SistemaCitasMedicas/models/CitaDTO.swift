

import UIKit

struct CitaDTO: Codable {
    let id: Int;
    let fecha: String;
    let hora: String;
    let especialidad: String;
    let doctorNombre: String;
    let estado: String
}
