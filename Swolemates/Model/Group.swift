//
//  Group.swift
//  Swolemates
//
//

import Foundation
import RealmSwift

class Group: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""
    let membersName = List<Member>()
}
