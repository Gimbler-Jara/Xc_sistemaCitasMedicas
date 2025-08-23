

import UIKit
import Alamofire

final class APIClientUIKit {
    static let shared = APIClientUIKit()
    private init() {}
    
    var baseURL = URL(string: "http://localhost:8080/api")!
    
    private func handleResponse<T: Decodable>(
        _ response: AFDataResponse<Data>,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        if let err = response.error, response.response == nil {
            return completion(.failure(err))
        }
        
        guard let data = response.data,
              let status = response.response?.statusCode else {
            return completion(.failure(URLError(.badServerResponse)))
        }
        
        do {
            if (200..<300).contains(status) {
                let obj = try JSONDecoder().decode(T.self, from: data)
                completion(.success(obj))
            } else {
                if let apiErr = try? JSONDecoder().decode(ApiErrorDTO.self, from: data) {
                    completion(.failure(apiErr))
                } else {
                    completion(.failure(URLError(.badServerResponse)))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    
    func register(_ payload: RegistroRequestDTO, completion: @escaping (Result<PacienteDTO, Error>) -> Void) {
        let url = "\(baseURL)/auth/register"
        AF.request(url,method: .post,parameters: payload,encoder: JSONParameterEncoder.default,headers: ["Accept": "application/json"])
            .validate(statusCode: 200..<600)
            .responseData { [weak self] resp in
                self?.handleResponse(resp, completion: completion)
            }
    }
    
    
    func login(_ payload: LoginRequestDTO, completion: @escaping (Result<AuthResponseDTO, Error>) -> Void) {
        let url = "\(baseURL)/auth/login"
        AF.request(url, method: .post,parameters: payload,encoder: JSONParameterEncoder.default,headers: ["Accept": "application/json"])
            .validate(statusCode: 200..<600)
            .responseData { [weak self] resp in
                self?.handleResponse(resp, completion: completion)
            }
    }
    
    func me(email: String, completion: @escaping (Result<PacienteDTO, Error>) -> Void) {
        let url = "\(baseURL)/pacientes/me"
        let params: Parameters = ["email": email]
        AF.request(url,method: .get,parameters: params,encoding: URLEncoding.default,headers: ["Accept": "application/json"])
            .validate(statusCode: 200..<600)
            .responseData { [weak self] resp in
                self?.handleResponse(resp, completion: completion)
            }
    }
    
    func especialidades(completion: @escaping (Result<[EspecialidadDTO], Error>) -> Void) {
        let url = "\(baseURL)/especialidades"
        AF.request(url,method: .get,headers: ["Accept": "application/json"])
            .validate(statusCode: 200..<600)
            .responseData { [weak self] resp in
                self?.handleResponse(resp, completion: completion)
            }
    }
    
    func doctores(especialidadId: Int, completion: @escaping (Result<[DoctorDTO], Error>) -> Void) {
        let url = "\(baseURL)/doctores"
        let params: Parameters = ["especialidadId": especialidadId]
        AF.request(url,method: .get,parameters: params,encoding: URLEncoding.default,headers: ["Accept": "application/json"])
            .validate(statusCode: 200..<600)
            .responseData { [weak self] resp in
                self?.handleResponse(resp, completion: completion)
            }
    }
    
    func slots(doctorId: Int, fecha: String, completion: @escaping (Result<[SlotDTO], Error>) -> Void) {
        let url = "\(baseURL)/doctores/\(doctorId)/slots"
        let params: Parameters = ["fecha": fecha]
        AF.request(url,method: .get,parameters: params,encoding: URLEncoding.default,headers: ["Accept": "application/json"])
            .validate(statusCode: 200..<600)
            .responseData { [weak self] resp in
                self?.handleResponse(resp, completion: completion)
            }
    }
    
    func reservar(_ payload: CitaRequestDTO, completion: @escaping (Result<CitaDTO, Error>) -> Void) {
        let url = "\(baseURL)/citas"
        AF.request(url,method: .post,parameters: payload,encoder: JSONParameterEncoder.default,headers: ["Accept": "application/json"])
            .validate(statusCode: 200..<600)
            .responseData { [weak self] resp in
                self?.handleResponse(resp, completion: completion)
            }
    }
    
    func misCitas(pacienteId: Int, completion: @escaping (Result<[CitaDTO], Error>) -> Void) {
        let url = "\(baseURL)/citas/mias"
        let params: Parameters = ["pacienteId": pacienteId]
        AF.request(url,method: .get,parameters: params,encoding: URLEncoding.default,headers: ["Accept": "application/json"])
            .validate(statusCode: 200..<600)
            .responseData { [weak self] resp in
                self?.handleResponse(resp, completion: completion)
            }
    }
    
    func cancelar(citaId: Int, completion: @escaping (Result<CitaDTO, Error>) -> Void) {
        let url = "\(baseURL)/citas/\(citaId)/cancelar"
        AF.request(url,method: .patch,headers: ["Accept": "application/json"])
            .validate(statusCode: 200..<600)
            .responseDecodable(of: CitaDTO.self) { [weak self] resp in
                guard self != nil else { return }
                switch resp.result {
                case .success(let dto):
                    completion(.success(dto))
                case .failure(let err):
                    completion(.failure(err))
                }
            }
    }
}
