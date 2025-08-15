//
//  AnyEncodable.swift
//  SistemaCitasMedicas
//
//  Created by Emerson Jara Gamarra on 14/08/25.
//

import UIKit

// MARK: - Helpers
struct AnyEncodable: Encodable {
    private let _encode:(Encoder) throws -> Void;
    init<T: Encodable>(_ e: T){_encode=e.encode};
    func encode(to encoder: Encoder) throws { try _encode(encoder) }
}

extension URL { func appending(queryItems: [URLQueryItem]) -> URL {
    var c = URLComponents(url: self, resolvingAgainstBaseURL: false)!;
    c.queryItems = (c.queryItems ?? []) + queryItems; return c.url! }
}

extension Date { static func yyyyMMdd(_ d: Date) -> String {
    let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd";
    f.locale = .init(identifier: "en_US_POSIX");
    f.timeZone = .current; return f.string(from: d) }
}

extension UIViewController {
    func alert(_ msg: String, title: String = "Aviso") { let ac = UIAlertController(title: title, message: msg, preferredStyle: .alert); ac.addAction(UIAlertAction(title: "OK", style: .default)); present(ac, animated: true) }
    func message(from error: Error) -> String {
        if let api = error as? ApiErrorDTO { return api.message }
        return error.localizedDescription
    }
}
