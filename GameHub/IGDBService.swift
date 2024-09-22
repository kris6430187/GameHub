// IGDBService.swift

import Foundation
import Alamofire

class IGDBService {
    static let shared = IGDBService()
    
    private let clientID = "fhnvgqyhcufns125esnbjl1iqacqxy"
    private let accessToken = "mpfty6g3ugf1m2isb38p547j7v61x8"
    private let baseURL = "https://api.igdb.com/v4"
    
    private init() {}
    
    func fetchGames(with query: String, completion: @escaping (Result<[Game], Error>) -> Void) {
        let url = "\(baseURL)/games"
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Client-ID": clientID,
            "Accept": "application/json"
        ]
        
        AF.request(url, method: .post, parameters: [:], encoding: HTTPBodyEncoding(body: query), headers: headers)
            .validate()
            .responseDecodable(of: [Game].self) { response in
                switch response.result {
                case .success(let games):
                    completion(.success(games))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}

struct HTTPBodyEncoding: ParameterEncoding {
    let body: String
    
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = body.data(using: .utf8)
        return request
    }
}
