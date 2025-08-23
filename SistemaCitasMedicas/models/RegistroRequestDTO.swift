

import UIKit

struct RegistroRequestDTO: Codable {
    let dni, nombre, apellido, email, telefono, password: String;
    let fotoUrl: String?
}
