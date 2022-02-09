//
//  ApiClient.swift
//  MyPokémon
//
//  Created by Ade Reskita on 08/02/22.
//

import Alamofire
import RxSwift

class ApiClient {
    
    static func getPokemon(offset: String, limit: String) -> Observable<Pokemons> {
        return request(ApiRouter.getPokemon(offset: offset, limit: limit))
    }
    static func getAbility(offset: String) -> Observable<Pokemons> {
        return request(ApiRouter.getAbility(offset: offset))
    }
    static func getDescription(id: String) -> Observable<PokemonDesc> {
        return request(ApiRouter.getDescription(id: id))
    }
    static func getSpecies(id: String) -> Observable<PokemonSpecies> {
        return request(ApiRouter.getSpecies(id: id))
    }
    static func getSearchPokemon(type: String) -> Observable<PokemonType> {
        return request(ApiRouter.getSearchPokemon(type: type))
    }
    static func getMove(id: String) -> Observable<PokemonDesc> {
        return request(ApiRouter.getMove(id: id))
    }
    static func getMoves(id: String) -> Observable<PokemonMoves> {
        return request(ApiRouter.getMoves(id: id))
    }
    
// MARK: - The request function to get results in an Observable
    private static func request<T: Codable> (_ urlConvertible: URLRequestConvertible) -> Observable<T> {
// an RxSwift observable, which will be the one to call the request when subscribed to
        return Observable<T>.create { observer in
// HttpRequest using AlamoFire (AF)
            let request = AF.request(urlConvertible).responseDecodable { (response: AFDataResponse<T>) in
                switch response.result {
                case .success(let value):
// return the value in onNext
                    observer.onNext(value)
                    observer.onCompleted()
                case .failure(let error):
                    switch response.response?.statusCode {
                    case 403:
                        observer.onError(ApiError.forbidden)
                    case 404:
                        observer.onError(ApiError.notFound)
                    case 409:
                        observer.onError(ApiError.conflict)
                    case 500:
                        observer.onError(ApiError.internalServerError)
                    default:
                        observer.onError(error)
                    }
                }
            }
            
 // return a disposable to stop the request
            return Disposables.create {
                request.cancel()
            }
        }
    }
}

