//
//  Constant.swift
//  MyPokémon
//
//  Created by Ade Reskita on 08/02/22.
//

import Foundation

struct Constants {
    
// The API's base URL
    
    static let URL = "https://pokeapi.co/api/v2/"

    // parameters (Queries)
    struct Parameters {
        static let limit = "limit"
        static let offset = "offset"
    }
    
// header fields
    enum HttpHeaderField: String {
        case authentication = "Authorization"
        case contentType = "Content-Type"
        case acceptType = "Accept"
        case acceptEncoding = "Accept-Encoding"
    }
    
    //use content type as (JSON)
    enum ContentType: String {
        case json = "application/json"
    }
}

