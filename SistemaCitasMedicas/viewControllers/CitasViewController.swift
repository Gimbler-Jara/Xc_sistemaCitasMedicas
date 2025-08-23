

import UIKit

class CitasViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tvPaciente: UITableView!
    
    private var citas: [CitaDTO] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tvPaciente.dataSource = self
        tvPaciente.delegate = self
        
        tvPaciente.rowHeight = 130
        
        cargarCitas()
    }
    
    private func cargarCitas() {
        
        guard let paciente = Session.shared.paciente else {
            return alert("Debes iniciar sesión")
        }
        
        APIClientUIKit.shared.misCitas(pacienteId: paciente.id) {
            [weak self] res in
            guard let self = self else { return }
            switch res {
            case .success(let list):
                self.citas = list
                self.tvPaciente.reloadData()
            case .failure(let e):
                self.alert(self.message(from: e))
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        citas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "citasfila", for: indexPath) as! CitasViewCell
        let c = citas[indexPath.row]
        cell.lblEspecialidad.text = c.especialidad
        cell.lblMedico.text = c.doctorNombre
        cell.lblFecha.text = formatearFecha(c.fecha)
        cell.lblHora.text = c.hora
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    private func formatearFecha(_ iso: String) -> String {
        let inF = DateFormatter();
        inF.dateFormat = "yyyy-MM-dd";
        inF.locale = .init(identifier: "en_US_POSIX")
        
        let outF = DateFormatter();
        outF.dateFormat = "dd-MM-yy";
        outF.locale = .current
        if let d = inF.date(from: iso) { return outF.string(from: d) }
        return iso
    }
    
    
    @IBAction func btnRegresar(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
}
