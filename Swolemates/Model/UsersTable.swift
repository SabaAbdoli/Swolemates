//
//  queryFromUserTable.swift
//  Swolemates
//


import Foundation
import Supabase
import UIKit

class UsersTable {
  
    let client = SupabaseClient(supabaseURL: URL(string: Constants.urlString)! , supabaseKey: Constants.apiKey)
    
    func insert(_ client:SupabaseClient , _ user: User ) async throws {
        try await  client.database.from("users").insert(values: user).execute()
    }

    
    func addMember(_ userID:String,_ client:SupabaseClient, _ groupID:String ) async throws {
    
                let a = try await client.database.from("users").select(columns: "username").equals(column: "username", value: userID).execute().decoded(to: [User].self)
                if a != []{
                    var newMember = User()
                    newMember.username = userID
                    newMember.groupID = groupID
                    
                    try await insert(client, newMember)
                }else{
                    throw NewMemError.notRegisteredUser
                  }
    }

    
}
