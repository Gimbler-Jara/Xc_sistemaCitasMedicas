//
//  APIClientUIKit.swift
//  SistemaCitasMedicas
//
//  Created by Emerson Jara Gamarra on 13/08/25.
//

import UIKit

final class APIClientUIKit {
    static let shared = APIClientUIKit()
    private init() {}
    
    var baseURL = URL(string: "http://localhost:8080/api")!
    
    // ✅ GET/DELETE sin body
    private func buildRequest(
        path: String,
        method: String = "GET"
    ) throws -> URLRequest {
        let url = baseURL.appending(path: path)
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
#if DEBUG
        print("➡️ \(method) \(url.absoluteString) (sin body)")
#endif
        return req
    }
    
    // ✅ POST/PUT/PATCH con body (genérico)
    private func buildRequest<T: Encodable>(
        path: String,
        method: String,
        body: T
    ) throws -> URLRequest {
        let url = baseURL.appending(path: path)
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let data = try JSONEncoder().encode(body)
        req.httpBody = data
#if DEBUG
        print("➡️ \(method) \(url.absoluteString)")
        print("BODY:", String(data: data, encoding: .utf8) ?? "nil")
#endif
        return req
    }
    
    
    
    private func run<T: Decodable>(_ req: URLRequest, completion: @escaping (Result<T, Error>) -> Void) {
        URLSession.shared.dataTask(with: req) { data, resp, err in
            if let err = err { return DispatchQueue.main.async { completion(.failure(err)) } }
            guard let http = resp as? HTTPURLResponse, let data = data else {
                return DispatchQueue.main.async { completion(.failure(URLError(.badServerResponse))) }
            }
#if DEBUG
            print("⬅️ STATUS:", http.statusCode)
            print("RESP:", String(data: data, encoding: .utf8) ?? "nil")
#endif
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            if (200..<300).contains(http.statusCode) {
                do { let obj = try decoder.decode(T.self, from: data)
                    DispatchQueue.main.async { completion(.success(obj)) } }
                catch { DispatchQueue.main.async { completion(.failure(error)) } }
            } else {
                if let apiErr = try? decoder.decode(ApiErrorDTO.self, from: data) {
                    DispatchQueue.main.async { completion(.failure(apiErr)) }
                } else {
                    DispatchQueue.main.async { completion(.failure(URLError(.badServerResponse))) }
                }
            }
        }.resume()
    }
    
    
    // MARK: Endpoints
    func register(_ payload: RegistroRequestDTO, completion: @escaping (Result<PacienteDTO, Error>) -> Void) {
        do { let req = try buildRequest(path: "/auth/register", method: "POST", body: payload); run(req, completion: completion) }
        catch { completion(.failure(error)) }
    }
    
    func login(_ payload: LoginRequestDTO, completion: @escaping (Result<AuthResponseDTO, Error>) -> Void) {
        do {
            let req = try buildRequest(path: "/auth/login", method: "POST", body: payload)
            run(req, completion: completion)
        } catch { completion(.failure(error)) }
    }
    
    
    // Para backend sin JWT real: /pacientes/me?email=...
    func me(email: String, completion: @escaping (Result<PacienteDTO, Error>) -> Void) {
        let url = baseURL.appending(path: "/pacientes/me").appending(queryItems: [.init(name: "email", value: email)])
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        run(req, completion: completion)
    }
    
    // GET /especialidades
    func especialidades(completion: @escaping (Result<[EspecialidadDTO], Error>) -> Void) {
        do {
            let req = try buildRequest(path: "/especialidades");
            run(req, completion: completion) }
        catch { completion(.failure(error)) }
    }
    
    // GET /doctores?especialidadId=...
    func doctores(especialidadId: Int, completion: @escaping (Result<[DoctorDTO], Error>) -> Void) {
        let url = baseURL.appending(path: "/doctores").appending(queryItems: [.init(name: "especialidadId", value: String(especialidadId))])
        var req = URLRequest(url: url);
        req.httpMethod = "GET";
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        run(req, completion: completion)
    }
    
    // GET /doctores/{id}/slots?fecha=...
    func slots(doctorId: Int, fecha: String, completion: @escaping (Result<[SlotDTO], Error>) -> Void) {
        let path = "/doctores/\(doctorId)/slots"
        let url = baseURL.appending(path: path).appending(queryItems: [.init(name: "fecha", value: fecha)])
        var req = URLRequest(url: url);
        req.httpMethod = "GET";
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        run(req, completion: completion)
    }
    
    // POST /citas
    func reservar(_ payload: CitaRequestDTO, completion: @escaping (Result<CitaDTO, Error>) -> Void) {
        do {
            let req = try buildRequest(path: "/citas", method: "POST", body: payload);
            run(req, completion: completion)
        }catch { completion(.failure(error)) }
    }
    
    func misCitas(pacienteId: Int, completion: @escaping (Result<[CitaDTO], Error>) -> Void) {
        let url = baseURL.appending(path: "/citas/mias").appending(queryItems: [.init(name: "pacienteId", value: String(pacienteId))])
        var req = URLRequest(url: url); req.httpMethod = "GET"; req.setValue("application/json", forHTTPHeaderField: "Accept")
        run(req, completion: completion)
    }
}
