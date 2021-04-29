//
//  NetworkService.swift
//  DigiIdentity_test
//
//  Created by Pavle Mijatovic on 29.4.21..
//

import Foundation

class NetworkService {
    
    typealias JSON = [String: Any]
    typealias HTTPHeaders = [String: String]
    
    // MARK: Request Methods
    public enum RequestMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
        case patch = "PATCH"
    }
    
    func load<M: Decodable>(urlString: String, path: String, method: RequestMethod, params: JSON?, headers: HTTPHeaders?, completion: @escaping (Result<M?, NetworkError>) -> ()) -> URLSessionDataTask? {
        
        let request = URLRequest(baseUrl: urlString, path: path, method: method, params: params, headers: headers)
        
        let urlSessionPinningDelegate = URLSessionPinningDelegate()
        
        let session = URLSession(
            configuration: URLSessionConfiguration.ephemeral,
            delegate: urlSessionPinningDelegate,
            delegateQueue: nil)
        
        let task = session.dataTask(with: request) { [weak self] (data, resp, err) in
            guard let `self` = self else { return }
            
            if let err = err {
                
                let err = urlSessionPinningDelegate.isSSLPinningInOrder ? NetworkError.error(err: err) : NetworkError.sslCertificateNotInOrder
                completion(.failure(err))
                return
            }
            
            guard let data = data else {
                completion(.failure(.unknown))
                return
            }
            
            guard let httpResponse = resp as? HTTPURLResponse, (200..<300) ~= httpResponse.statusCode else {
                let responseErr = self.getResponseError(httpResponse: resp as! HTTPURLResponse)
                completion(.failure(responseErr))
                return
            }
            
            do {
                guard data.count > 0 else {
                    completion(.success(nil))
                    return
                }
                let genericObject = try JSONDecoder().decode(M.self, from: data)
                completion(.success(genericObject))
            } catch let jsonErr {
                completion(.failure(.jsonDecodeErr(description: String(describing: jsonErr))))
            }
        }
        
        task.resume()
        return task
    }
}

extension NetworkService {
    func getResponseError(httpResponse: HTTPURLResponse) -> NetworkError {
        if httpResponse.statusCode == 404 {
            return .pageNotFound
        } else if (400..<500) ~= httpResponse.statusCode {
            return .clientRelated
        } else if (500..<600) ~= httpResponse.statusCode {
            return .serverRelated
        } else {
            return .unknown
        }
    }
}

extension URLRequest {
    init(baseUrl: String, path: String, method: NetworkService.RequestMethod, params: NetworkService.JSON?, headers: NetworkService.HTTPHeaders? = nil) {
        let url = URL(baseUrl: baseUrl, path: path, params: params, method: method)
        self.init(url: url)
        httpMethod = method.rawValue
        
        setValue("application/json", forHTTPHeaderField: "Accept")
        setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if headers != nil {
            for (key, value) in headers! {
                setValue(value, forHTTPHeaderField: key)
            }
        }
        
        switch method {
        case .post, .put, .patch:
            guard let params = params else { break }
            let dataForBody = try! JSONSerialization.data(withJSONObject: params, options: [])
            httpBody = dataForBody
        default:
            break
        }
    }
}

extension URL {
    init(baseUrl: String, path: String, params: NetworkService.JSON?, method: NetworkService.RequestMethod) {
        var components = URLComponents(string: baseUrl)!
        components.path += path
        
        switch method {
        case .get, .delete:
            guard let params = params else { break }
            components.queryItems = params.map {
                URLQueryItem(name: $0.key, value: String(describing: $0.value))
            }
        default:
            break
        }
        
        self = components.url!
    }
}

