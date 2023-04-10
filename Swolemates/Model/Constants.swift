//
//  Constants.swift
//  Swolemates
//
//

import Foundation

struct Constants {
    
    static let urlString = "urlString"
    static let apiKey = "apiKey"
    
    
    static let loginSegue = ""
    static let registerSegue = ""
    static let chatTableReusableCell = ""
   
    static func imageURLBank() -> String {
        
        
        return "https://www.healthier.qld.gov.au/wp-content/uploads/2015/07/\(String(format: "%02d", Int.random (in: 1...30)))_\(["M","F"].randomElement()!)_WIP02.gif"
    }
    
}
