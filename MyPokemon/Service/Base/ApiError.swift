//
//  ApiError.swift
//  MyPokémon
//
//  Created by Ade Reskita on 08/02/22.
//

import Foundation

enum ApiError: Error {
    case forbidden              // Status code 403
    case notFound               // Status code 404
    case conflict               // Status code 409
    case internalServerError    // Status code 500
}
