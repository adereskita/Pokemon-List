//
//  ViewModel.swift
//  MyPokémon
//
//  Created by Ade Reskita on 08/02/22.
//

import Foundation
import RxSwift

class ViewModel {
    
    var offset = 0
    var limit = 0
    var searchText = ""
//    weak var delegate: DetailViewDelegate?
    
    // MARK: - Properties
    
    var pokeDetail: PokemonDesc? {
        didSet {
            self.didFinishFetch?()
            self.reloadList()
        }
    }
    
    var pokeMoves: [Move] = [] {
        didSet {
            self.reloadMove()
            self.reloadList()
        }
    }
    
    var pokemonMove: PokemonMoves? {
        didSet {
            self.didFinishFetch?()
        }
    }
    
    var pokeSpecies: PokemonSpecies? {
        didSet {
            self.didFinishFetch?()
        }
    }
    
    var pokeResult: [Result] = [] {
        didSet {
            self.reloadList()
        }
    }
    
    var pokeResultSearch: [Pokemon] = [] {
        didSet {
            self.reloadList()
        }
    }
    
    var error: Error? {
        didSet { self.showAlertClosure?() }
    }
    var isLoading: Bool = false {
        didSet { self.updateLoadingStatus?() }
    }
    
    var titleString: String?
    var flavText: String?
    var codeId: String?
    var row  = 0
    var imAvatar: URL?
    
// Dispose bag
    private let disposeBag = DisposeBag()
    
    // MARK: - Closures for callback, since we are not using the ViewModel to the View.
    var showAlertClosure: (() -> Void)?
    var errorMessage = {(message: String) -> Void in }
    var updateLoadingStatus: (() -> Void)?
    var didFinishFetch: (() -> Void)?
    var reloadList = {() -> Void in }
    var reloadMove = {() -> Void in }
    
    // MARK: - Network call
    func fetchPokemon(offset: Int, limit: Int) {
        ApiClient.getPokemon(offset: String(offset), limit: String(limit))
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { pokemonList in
                self.pokeResult = pokemonList.results!
                                
            }, onError: { error in
                switch error {
                case ApiError.conflict:
                    print("Conflict error")
                case ApiError.forbidden:
                    print("Forbidden error")
                case ApiError.notFound:
                    print("Not found error")
                default:
                    print("Unknown error:", error)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func fetchDetail(id: String) {
        // fetch pokemon data
        ApiClient.getDescription(id: id)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { details in
                self.pokeDetail = details
                
            }, onError: { error in
                switch error {
                case ApiError.conflict:
                    print("Conflict error")
                case ApiError.forbidden:
                    print("Forbidden error")
                case ApiError.notFound:
                    print("Not found error")
                default:
                    print("Unknown error:", error)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func fetchMoves(id: String) {
        // fetch pokemon data
        ApiClient.getMove(id: id)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { moveList in
                
                guard let moves = moveList.moves else {return}
                self.pokeMoves = moves
                self.row = moves.count
                
            }, onError: { error in
                switch error {
                case ApiError.conflict:
                    print("Conflict error")
                case ApiError.forbidden:
                    print("Forbidden error")
                case ApiError.notFound:
                    print("Not found error")
                default:
                    print("Unknown error:", error)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func fetchMove(id: String) {
        // fetch pokemon data specific on move
        ApiClient.getMoves(id: id)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { movesDetail in
                self.pokemonMove = movesDetail
                
                print("fetch move: \(self.pokemonMove)")

            }, onError: { error in
                switch error {
                case ApiError.conflict:
                    print("Conflict error")
                case ApiError.forbidden:
                    print("Forbidden error")
                case ApiError.notFound:
                    print("Not found error")
                default:
                    print("Unknown error:", error)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func fetchSpecies(id: String) {
        // fetch pokemon data specific on species
        ApiClient.getSpecies(id: id)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { species in
                self.pokeSpecies = species

            }, onError: { error in
                switch error {
                case ApiError.conflict:
                    print("Conflict error")
                case ApiError.forbidden:
                    print("Forbidden error")
                case ApiError.notFound:
                    print("Not found error")
                default:
                    print("Unknown error:", error)
                }
            })
            .disposed(by: disposeBag)
    }

    
    
    func fetchSearchPokemon(type: String) {
        ApiClient.getSearchPokemon(type: type)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { pokemonType in
                self.pokeResultSearch = pokemonType.pokemon!
                                
            }, onError: { error in
                switch error {
                case ApiError.conflict:
                    print("Conflict error")
                case ApiError.forbidden:
                    print("Forbidden error")
                case ApiError.notFound:
                    print("Not found error")
                default:
                    print("Unknown error:", error)
                }
            })
            .disposed(by: disposeBag)
    }
}
