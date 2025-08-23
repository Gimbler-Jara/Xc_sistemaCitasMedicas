

import UIKit

struct ApiErrorDTO: Codable, Error {
    let message: String;
    let status: Int?
}
