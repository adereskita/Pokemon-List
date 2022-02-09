//
//  Connectivity.swift
//  MyPokemon
//
//  Created by Ade Reskita on 08/02/22.
//

import Foundation
import Alamofire

class Connectivity {
    class var isConnectedToInternet: Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
}
