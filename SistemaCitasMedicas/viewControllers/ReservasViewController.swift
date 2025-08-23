

import UIKit

class ReservasViewController: UIViewController , UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var txtEspecialidad: UITextField!
    @IBOutlet weak var txtMedico: UITextField!
    @IBOutlet weak var txtFecha: UITextField!
    @IBOutlet weak var txtHorario: UITextField!
    
    // MARK: Pickers
    private let especialidadPicker = UIPickerView()
    private let medicoPicker = UIPickerView()
    private let horarioPicker = UIPickerView()
    private let datePicker = UIDatePicker()
    
    // MARK: Data
    private var especialidades: [EspecialidadDTO] = []
    private var doctores: [DoctorDTO] = []
    private var slots: [SlotDTO] = []
    
    // Selección actual
    private var selectedEspecialidad: EspecialidadDTO?
    private var selectedDoctor: DoctorDTO?
    private var selectedFecha: String? // YYYY-MM-DD
    private var selectedSlot: SlotDTO?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePickers()
        loadEspecialidades()
    }
    
    @IBAction func btnCerrarSesion(_ sender: UIButton) {
        Session.shared.token = nil
        Session.shared.paciente = nil
        Session.shared.emailLogin = nil
        
        //limpiar persistencia
        UserDefaults.standard.removeObject(forKey: "token")
        UserDefaults.standard.removeObject(forKey: "emailLogin")
        
        dismiss(animated: true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let tz = datePicker.timeZone ?? .current
        datePicker.minimumDate = startOfTomorrow(timeZone: tz)
        if let min = datePicker.minimumDate, datePicker.date < min { datePicker.date = min }
    }
    
    
    @IBAction func btnCitas(_ sender: UIButton) {
        performSegue(withIdentifier: "citas", sender: self)
    }
    
    
    private func configurePickers() {
        // Delegados
        [especialidadPicker, medicoPicker, horarioPicker].forEach { picker in
            picker.dataSource = self
            picker.delegate = self
        }
        
        txtEspecialidad.inputView = especialidadPicker
        txtMedico.inputView = medicoPicker
        txtHorario.inputView = horarioPicker
        txtFecha.inputView = datePicker
        
        txtEspecialidad.inputAccessoryView = makeToolbar(done: #selector(doneEspecialidad), cancel: #selector(cancelInput))
        txtMedico.inputAccessoryView       = makeToolbar(done: #selector(doneMedico),       cancel: #selector(cancelInput))
        txtHorario.inputAccessoryView      = makeToolbar(done: #selector(doneHorario),      cancel: #selector(cancelInput))
        txtFecha.inputAccessoryView        = makeToolbar(done: #selector(doneFecha),        cancel: #selector(cancelInput))
        
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) { datePicker.preferredDatePickerStyle = .wheels }

        datePicker.timeZone = .current
        let tz = datePicker.timeZone ?? .current
        datePicker.minimumDate = startOfTomorrow(timeZone: tz)
        
        if let min = datePicker.minimumDate {
            datePicker.date = min
        }

        datePicker.addTarget(self, action: #selector(onDateChanged), for: .valueChanged)
    }
    
    private func makeToolbar(done: Selector, cancel: Selector) -> UIToolbar {
        let tb = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 44))
        let cancelItem = UIBarButtonItem(title: "Cancelar", style: .plain, target: self, action: cancel)
        let flex = UIBarButtonItem(systemItem: .flexibleSpace)
        let doneItem = UIBarButtonItem(title: "Hecho", style: .done, target: self, action: done)
        tb.items = [cancelItem, flex, doneItem]; return tb
    }
    
    @objc private func cancelInput() { view.endEditing(true) }
    
    // MARK: - Loaders
    private func loadEspecialidades() {
        APIClientUIKit.shared.especialidades { [weak self] res in
            guard let self = self else { return }
            switch res {
            case .success(let list):
                self.especialidades = list
                self.especialidadPicker.reloadAllComponents()
            case .failure(let e): self.alert(self.message(from: e))
            }
        }
    }
    
    private func loadDoctores(for especialidad: EspecialidadDTO) {
        APIClientUIKit.shared.doctores(especialidadId: especialidad.id) { [weak self] res in
            guard let self = self else { return }
            switch res {
            case .success(let list):
                self.doctores = list
                self.medicoPicker.reloadAllComponents()
                // reset dependientes
                self.selectedDoctor = nil; self.txtMedico.text = nil
                self.selectedSlot = nil; self.txtHorario.text = nil
            case .failure(let e): self.alert(self.message(from: e))
            }
        }
    }
    
    private func loadSlotsIfPossible() {
        guard
            let doc = selectedDoctor,
            let fecha = selectedFecha
        else { return }
        
        APIClientUIKit.shared.slots(doctorId: doc.id, fecha: fecha) { [weak self] res in
            guard let self = self else { return }
            switch res {
            case .success(let list):
                self.slots = list
                self.horarioPicker.reloadAllComponents()
                self.selectedSlot = nil; self.txtHorario.text = nil
            case .failure(let e): self.alert(self.message(from: e))
            }
        }
    }
    
    // MARK: - Done actions
    @objc private func doneEspecialidad() {
        let row = especialidadPicker.selectedRow(inComponent: 0)
        guard especialidades.indices.contains(row) else { return }
        selectedEspecialidad = especialidades[row]
        txtEspecialidad.text = selectedEspecialidad?.nombre
        view.endEditing(true)
        // cargar doctores
        loadDoctores(for: selectedEspecialidad!)
    }
    
    @objc private func doneMedico() {
        let row = medicoPicker.selectedRow(inComponent: 0)
        guard doctores.indices.contains(row) else { return }
        selectedDoctor = doctores[row]
        txtMedico.text = selectedDoctor?.nombreCompleto
        view.endEditing(true)
        // al elegir médico, si ya hay fecha seleccionada, cargar slots
        loadSlotsIfPossible()
    }
    
    @objc private func doneFecha() {
        let f = DateFormatter();
        f.dateFormat = "yyyy-MM-dd";
        f.locale = .init(identifier: "en_US_POSIX")
        selectedFecha = f.string(from: datePicker.date)
        txtFecha.text = selectedFecha
        view.endEditing(true)
        // al elegir fecha, si ya hay doctor seleccionado, cargar slots
        loadSlotsIfPossible()
    }
    
    @objc private func doneHorario() {
        let row = horarioPicker.selectedRow(inComponent: 0)
        guard slots.indices.contains(row) else { return }
        selectedSlot = slots[row]
        txtHorario.text = selectedSlot?.hora
        view.endEditing(true)
    }
    
    @objc private func onDateChanged() {
        // ver en tiempo real en el textfield
        let f = DateFormatter();
        f.dateFormat = "yyyy-MM-dd";
        f.locale = .init(identifier: "en_US_POSIX")
        f.timeZone = datePicker.timeZone ?? .current
        txtFecha.text = f.string(from: datePicker.date)
    }
    
    // MARK: - UIPicker DataSource/Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView === especialidadPicker { return especialidades.count }
        if pickerView === medicoPicker { return doctores.count }
        return slots.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView === especialidadPicker { return especialidades[row].nombre }
        if pickerView === medicoPicker { return doctores[row].nombreCompleto }
        return slots[row].hora
    }
    
    // MARK: - Acciones
    @IBAction func btnConfirmarReserva(_ sender: UIButton) {
        guard let paciente = Session.shared.paciente else { return alert("Debes iniciar sesión") }
        guard let doctor = selectedDoctor else { return alert("Selecciona un médico") }
        guard let fecha = selectedFecha else { return alert("Selecciona una fecha") }
        guard let slot = selectedSlot else { return alert("Selecciona un horario") }
        
        if let min = datePicker.minimumDate, datePicker.date < min {
            return alert("La fecha debe ser a partir de mañana.")
        }
        
        sender.isEnabled = false
        
        let payload = CitaRequestDTO(pacienteId: paciente.id, doctorId: doctor.id, fecha: fecha, slotId: slot.id)
        
        APIClientUIKit.shared.reservar(payload) { [weak self] res in
            guard let self = self else { return }
            sender.isEnabled = true
            switch res {
            case .success(_):
                let ac = UIAlertController(title: "Listo", message: "¡Cita reservada!", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    // Limpiar campos y variables seleccionadas
                    self.txtEspecialidad.text = ""
                    self.txtMedico.text = ""
                    self.txtFecha.text = ""
                    self.txtHorario.text = ""
                    self.selectedEspecialidad = nil
                    self.selectedDoctor = nil
                    self.selectedFecha = nil
                    self.selectedSlot = nil
                    self.doctores.removeAll()
                    self.slots.removeAll()
                }))
                self.present(ac, animated: true)
            case .failure(let e): self.alert(self.message(from: e))
            }
        }
    }
    
    private func startOfTomorrow(timeZone: TimeZone = .current) -> Date {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = timeZone
        let now = Date()
        let startOfToday = cal.startOfDay(for: now)
        // Suma 1 día al inicio del día actual → mañana 00:00
        return cal.date(byAdding: .day, value: 1, to: startOfToday)!
    }
}
