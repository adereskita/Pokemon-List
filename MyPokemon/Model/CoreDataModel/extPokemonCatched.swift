//
//  extCatched.swift
//  MyPokémon
//
//  Created by Ade Reskita on 08/02/22.
//

import Foundation
import CoreData

extension PokemonCatched {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PokemonCatched> {
        return NSFetchRequest<PokemonCatched>(entityName: "PokemonCatched")
    }

//    @NSManaged public var id: NSManagedObjectID
    @NSManaged public var id: Int32
    @NSManaged public var pokeID: String?
    @NSManaged public var name: String?
    @NSManaged public var type: String?
    @NSManaged public var backgroundImage: String?

}

extension PokemonCatched: Identifiable {

}
