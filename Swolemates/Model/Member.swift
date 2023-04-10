//
//  Member.swift
//  Swolemates
//
//

import Foundation
import RealmSwift
class Member: Object {
    @objc dynamic var username:String = ""
    let groups = LinkingObjects(fromType: Group.self, property: "membersName")
}
