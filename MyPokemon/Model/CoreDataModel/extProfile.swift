//
//  extProfile.swift
//  MyPokémon
//
//  Created by Ade Reskita on 08/02/22.
//

import Foundation
import CoreData


extension Profile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Profile> {
        return NSFetchRequest<Profile>(entityName: "Profile")
    }

    @NSManaged public var name: String?
    @NSManaged public var email: String?
    @NSManaged public var born: String?

}

extension Profile: Identifiable {

}
