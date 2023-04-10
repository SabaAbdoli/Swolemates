//
//  Message.swift
//  Swolemates
//
//

import Foundation
import PostgREST

struct Message: Codable, Hashable {
 var body: String?
 var sender: String?
 var groupID: String?

}
