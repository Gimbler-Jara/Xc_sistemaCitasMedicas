import UIKit

final class ReservasViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet private weak var txtEspecialidad: UITextField!
    @IBOutlet private weak var txtMedico: UITextField!
    @IBOutlet private weak var txtFecha: UITextField!
    @IBOutlet private weak var txtHorario: UITextField!
    
    // MARK: Pickers
    private let especialidadPicker = UIPickerView()
    private let medicoPicker = UIPickerView()
    private let horarioPicker = UIPickerView()
    private let datePicker = UIDatePicker()
    
    // MARK: Data
    private var especialidades: [EspecialidadDTO] = [] { didSet { especialidadPicker.reloadAllComponents() } }
    private var doctores: [DoctorDTO] = [] { didSet { medicoPicker.reloadAllComponents() } }
    private var slots: [SlotDTO] = [] { didSet { horarioPicker.reloadAllComponents() } }
    
    // Selección actual (con observers para cargar dependencias)
    private var selectedEspecialidad: EspecialidadDTO? {
        didSet {
            txtEspecialidad.text = selectedEspecialidad?.nombre
            selectedDoctor = nil
            doctores.removeAll()
            selectedSlot = nil
            slots.removeAll()
            if let esp = selectedEspecialidad { loadDoctores(for: esp) }
        }
    }
    private var selectedDoctor: DoctorDTO? {
        didSet {
            txtMedico.text = selectedDoctor?.nombreCompleto
            selectedSlot = nil
            slots.removeAll()
            loadSlotsIfPossible()
        }
    }
    private var selectedFecha: String? {   // YYYY-MM-DD
        didSet {
            txtFecha.text = selectedFecha
            selectedSlot = nil
            slots.removeAll()
            loadSlotsIfPossible()
        }
    }
    private var selectedSlot: SlotDTO? {
        didSet { txtHorario.text = selectedSlot?.hora }
    }
    
    // MARK: Formatters / Calendar
    private static let ymdFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = .init(identifier: "en_US_POSIX")
        return f
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePickers()
        configureDatePicker()
        loadEspecialidades()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let tz = datePicker.timeZone ?? .current
        datePicker.minimumDate = startOfTomorrow(timeZone: tz)
        if let min = datePicker.minimumDate, datePicker.date < min { datePicker.date = min }
    }
    
    // MARK: - UI Actions
    @IBAction private func btnCerrarSesion(_ sender: UIButton) {
        let ac = UIAlertController(title: "Cerrar sesión", message: "¿Seguro que deseas cerrar sesión?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "No", style: .cancel))
        ac.addAction(UIAlertAction(title: "Sí, cerrar", style: .destructive) { [weak self] _ in
            Session.shared.token = nil
            Session.shared.paciente = nil
            Session.shared.emailLogin = nil
            UserDefaults.standard.removeObject(forKey: "token")
            UserDefaults.standard.removeObject(forKey: "emailLogin")
            self?.dismiss(animated: true)
        })
        present(ac, animated: true)
    }
    
    @IBAction private func btnCitas(_ sender: UIButton) {
        performSegue(withIdentifier: "citas", sender: self)
    }
    
    @IBAction private func btnConfirmarReserva(_ sender: UIButton) {
        guard let paciente = Session.shared.paciente else { return alert("Debes iniciar sesión") }
        guard let doctor = selectedDoctor else { return alert("Selecciona un médico") }
        guard let fecha = selectedFecha else { return alert("Selecciona una fecha") }
        guard let slot = selectedSlot else { return alert("Selecciona un horario") }
        if let min = datePicker.minimumDate, datePicker.date < min { return alert("La fecha debe ser a partir de mañana.") }
        
        sender.isEnabled = false
        let payload = CitaRequestDTO(pacienteId: paciente.id, doctorId: doctor.id, fecha: fecha, slotId: slot.id)
        
        APIClientUIKit.shared.reservar(payload) { [weak self] res in
            guard let self = self else { return }
            DispatchQueue.main.async {
                sender.isEnabled = true
                switch res {
                case .success:
                    let ac = UIAlertController(title: "Listo", message: "¡Cita reservada!", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default) { _ in self.resetAll() })
                    self.present(ac, animated: true)
                case .failure(let e):
                    self.alert(self.message(from: e))
                }
            }
        }
    }
    
    // MARK: - Config
    private func configurePickers() {
        [especialidadPicker, medicoPicker, horarioPicker].forEach {
            $0.dataSource = self; $0.delegate = self
        }
        txtEspecialidad.inputView = especialidadPicker
        txtMedico.inputView       = medicoPicker
        txtHorario.inputView      = horarioPicker
        txtFecha.inputView        = datePicker
        
        txtEspecialidad.inputAccessoryView = makeToolbar(done: #selector(doneEspecialidad), cancel: #selector(cancelInput))
        txtMedico.inputAccessoryView       = makeToolbar(done: #selector(doneMedico),       cancel: #selector(cancelInput))
        txtHorario.inputAccessoryView      = makeToolbar(done: #selector(doneHorario),      cancel: #selector(cancelInput))
        txtFecha.inputAccessoryView        = makeToolbar(done: #selector(doneFecha),        cancel: #selector(cancelInput))
    }
    
    private func configureDatePicker() {
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) { datePicker.preferredDatePickerStyle = .wheels }
        datePicker.timeZone = .current
        let tz = datePicker.timeZone ?? .current
        let min = startOfTomorrow(timeZone: tz)
        datePicker.minimumDate = min
        datePicker.date = min
        datePicker.addTarget(self, action: #selector(onDateChanged), for: .valueChanged)
    }
    
    private func makeToolbar(done: Selector, cancel: Selector) -> UIToolbar {
        let tb = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 44))
        tb.items = [
            UIBarButtonItem(title: "Cancelar", style: .plain, target: self, action: cancel),
            UIBarButtonItem(systemItem: .flexibleSpace),
            UIBarButtonItem(title: "Hecho", style: .done, target: self, action: done)
        ]
        return tb
    }
    
    @objc private func cancelInput() { view.endEditing(true) }
    
    // MARK: - Loaders
    private func loadEspecialidades() {
        APIClientUIKit.shared.especialidades { [weak self] res in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch res {
                case .success(let list): self.especialidades = list
                case .failure(let e):    self.alert(self.message(from: e))
                }
            }
        }
    }
    
    private func loadDoctores(for especialidad: EspecialidadDTO) {
        APIClientUIKit.shared.doctores(especialidadId: especialidad.id) { [weak self] res in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch res {
                case .success(let list): self.doctores = list
                case .failure(let e):    self.alert(self.message(from: e))
                }
            }
        }
    }
    
    private func loadSlotsIfPossible() {
        guard let doc = selectedDoctor, let fecha = selectedFecha else { return }
        APIClientUIKit.shared.slots(doctorId: doc.id, fecha: fecha) { [weak self] res in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch res {
                case .success(let list): self.slots = list
                case .failure(let e):    self.alert(self.message(from: e))
                }
            }
        }
    }
    
    // MARK: - Done actions (ahora solo asignan la selección)
    @objc private func doneEspecialidad() {
        let row = especialidadPicker.selectedRow(inComponent: 0)
        guard especialidades.indices.contains(row) else { return }
        selectedEspecialidad = especialidades[row]
        view.endEditing(true)
    }
    
    @objc private func doneMedico() {
        let row = medicoPicker.selectedRow(inComponent: 0)
        guard doctores.indices.contains(row) else { return }
        selectedDoctor = doctores[row]
        view.endEditing(true)
    }
    
    @objc private func doneFecha() {
        selectedFecha = Self.ymdFormatter.string(from: datePicker.date)
        view.endEditing(true)
    }
    
    @objc private func doneHorario() {
        let row = horarioPicker.selectedRow(inComponent: 0)
        guard slots.indices.contains(row) else { return }
        selectedSlot = slots[row]
        view.endEditing(true)
    }
    
    @objc private func onDateChanged() {
        // vista previa en tiempo real
        let f = Self.ymdFormatter
        f.timeZone = datePicker.timeZone ?? .current
        txtFecha.text = f.string(from: datePicker.date)
    }
    
    // MARK: - UIPicker DataSource/Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case especialidadPicker: return especialidades.count
        case medicoPicker:       return doctores.count
        default:                 return slots.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case especialidadPicker: return especialidades[row].nombre
        case medicoPicker:       return doctores[row].nombreCompleto
        default:                 return slots[row].hora
        }
    }
    
    // MARK: - Helpers
    private func resetAll() {
        txtEspecialidad.text = nil
        txtMedico.text = nil
        txtFecha.text = nil
        txtHorario.text = nil
        selectedEspecialidad = nil
        selectedDoctor = nil
        selectedFecha = nil
        selectedSlot = nil
        doctores.removeAll()
        slots.removeAll()
        
        // reset fecha al mínimo
        if let min = datePicker.minimumDate { datePicker.date = min }
    }
    
    private func startOfTomorrow(timeZone: TimeZone = .current) -> Date {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = timeZone
        let startOfToday = cal.startOfDay(for: Date())
        return cal.date(byAdding: .day, value: 1, to: startOfToday)!
    }
}
