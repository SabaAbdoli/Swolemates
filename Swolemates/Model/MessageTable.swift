//
//  QueryFromMessageTable.swift
//  Swolemates
//
//  Created by Apple on 4/8/23.
//

import Foundation
import Supabase
import SupabaseStorage
import PostgREST
import Realtime

struct MessageTable {
    
    func fetchingOnlineData(_ client:SupabaseClient) {
        
        client.realtime.connect()
        client.realtime.onOpen {
            print("Socket opened.")
        }
        
        client.realtime.onError { error in
            print("Socket error: ", error.localizedDescription)
        }
        
        client.realtime.onClose {
            print("Socket closed")
        }
    
        client.realtime.channel(.table("Messages", schema: "public")).subscribe()
    }
    
    func loadMessageandMembers(_ client:SupabaseClient,_ groupId:String) async throws -> ([Message],[User]){
           
            let messages = try await client.database.from("Message").select().equals(column: "groupID", value: groupId).order(column: "created_at", ascending: true).execute().decoded(to: [Message].self)
            let members = try await client.database.from("users").select(columns: "username").equals(column: "groupID", value: groupId).execute().decoded(to: [User].self)
            return (messages,members)
    }
    
}
