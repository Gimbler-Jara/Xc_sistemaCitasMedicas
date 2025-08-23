

import UIKit

extension UIViewController {
    
    func alert(_ msg: String, title: String = "Aviso") {
        let ac = UIAlertController(title: title, message: msg, preferredStyle: .alert);
        ac.addAction(UIAlertAction(title: "OK", style: .default));
        present(ac, animated: true)
    }
    
    func message(from error: Error) -> String {
        if let api = error as? ApiErrorDTO { return api.message }
        return error.localizedDescription
    }
    
}
