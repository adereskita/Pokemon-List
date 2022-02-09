//
//  ApiRouter.swift
//  MyPokémon
//
//  Created by Ade Reskita on 08/02/22.
//

import Foundation
import Alamofire

enum ApiRouter: URLRequestConvertible {
    
// endpoint name
    case getPokemon(offset: String, limit: String)
    case getAbility(offset: String)
    case getSearchPokemon(type: String)
    case getDescription(id: String)
    case getSpecies(id: String)
    case getMove(id: String)
    case getMoves(id: String)

    
// MARK: - URLRequestConvertible
    func asURLRequest() throws -> URLRequest {
        let url = try Constants.URL.asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        
// Http method
        urlRequest.httpMethod = method.rawValue
        
// Common Headers
        urlRequest.setValue(Constants.ContentType.json.rawValue, forHTTPHeaderField: Constants.HttpHeaderField.acceptType.rawValue)
        urlRequest.setValue(Constants.ContentType.json.rawValue, forHTTPHeaderField: Constants.HttpHeaderField.contentType.rawValue)
        
// Encoding
        let encoding: ParameterEncoding = {
            switch method {
            case .get:
                return URLEncoding.default
            default:
                return JSONEncoding.default
            }
        }()
        
        return try encoding.encode(urlRequest, with: parameters)
    }
    
    // MARK: - HttpMethod
    // This returns the HttpMethod type. It's used to determine the type if several endpoints are peresent
    private var method: HTTPMethod {
        switch self {
        case .getPokemon:
            return .get
        case .getAbility:
            return .get
        case .getDescription:
            return .get
        case .getSearchPokemon:
            return .get
        case .getSpecies:
            return .get
        case .getMove:
            return .get
        case .getMoves:
            return .get
        }
    }
    
    // MARK: - Path
    // the part following base url
    private var path: String {
        switch self {
        case .getPokemon:
            return "pokemon/"
        case .getAbility:
            return "ability/"
        case .getDescription(let id):
            return "pokemon/\(id)/"
        case .getSearchPokemon(let searchText):
            return "type/\(searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!.lowercased())/"
        case .getSpecies(let id):
            return "pokemon-species/\(id)/"
        case .getMove(let id):
            return "pokemon/\(id)/"
        case .getMoves(let id):
            return "move/\(id)/"
        }
    }
    
    // MARK: - Parameters
    // the queries, optional
    private var parameters: Parameters? {
        switch self {
        case .getPokemon(let offset, let limit):
            return [Constants.Parameters.offset: offset, Constants.Parameters.limit: limit]
        case .getAbility(let offset):
            return [Constants.Parameters.offset: offset, Constants.Parameters.limit: "10"]
        case .getDescription:
            return nil
        case .getSearchPokemon:
            return nil
        case .getSpecies:
            return nil
        case .getMove:
            return nil
        case .getMoves:
            return nil
        }
    }
}


