//
//  ApiErrorDTO.swift
//  SistemaCitasMedicas
//
//  Created by Emerson Jara Gamarra on 13/08/25.
//

import UIKit

struct ApiErrorDTO: Codable, Error {
    let message: String;
    let status: Int?
}
