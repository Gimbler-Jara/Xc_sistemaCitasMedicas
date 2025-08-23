

import UIKit

final class Session {
    static let shared = Session()
    private init() {}
    
    var paciente: PacienteDTO?
    var token: String?
    var emailLogin: String?
}
