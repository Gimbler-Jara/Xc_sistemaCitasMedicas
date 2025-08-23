

import UIKit

class CitasViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tvPaciente: UITableView!
    
    private var citas: [CitaDTO] = []
    private var infoMostrada = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tvPaciente.dataSource = self
        tvPaciente.delegate = self
        
        tvPaciente.rowHeight = 130
        
        cargarCitas()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mostrarMensajeSiCorresponde()
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
                print(list)
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
        confirmarCancelacion(at: indexPath)
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
    
    private func confirmarCancelacion(at indexPath: IndexPath) {
        let c = citas[indexPath.row]
        let titulo = "Cancelar cita"
        let mensaje = "¿Seguro que deseas cancelar la cita con \(c.doctorNombre) el \(formatearFecha(c.fecha)) a las \(c.hora)?"
        
        let ac = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Sí, cancelar", style: .destructive, handler: { [weak self] _ in
            self?.cancelarCita(at: indexPath)
        }))
        present(ac, animated: true)
    }
    
    private func mostrarMensajeSiCorresponde() {
        guard !infoMostrada else { return }
        infoMostrada = true
        
        let ac = UIAlertController(
            title: "Sistemas",
            message: "Para cancelar una cita, selecciona la fila correspondiente.",
            preferredStyle: .alert
        )
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil)) // .default en lugar de .destructive
        present(ac, animated: true)
    }
    
    private func cancelarCita(at indexPath: IndexPath) {
        let cita = citas[indexPath.row]
        
        APIClientUIKit.shared.cancelar(citaId: Int(cita.id)) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self.citas.remove(at: indexPath.row)
                    self.tvPaciente.deleteRows(at: [indexPath], with: .automatic)
                    self.alert("Cita cancelada correctamente ✅")
                case .failure(let e):
                    self.alert(self.message(from: e))
                }
            }
        }
    }
    
    
    
}
