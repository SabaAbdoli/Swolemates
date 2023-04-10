//
//  Error.swift
//  Swolemates
//
//  Created by Apple on 4/9/23.
//

import Foundation
public enum NewMemError: Error {
    case notRegisteredUser
}

extension NewMemError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .notRegisteredUser:
            return NSLocalizedString("The User ID does not exist.",comment: "")
        }
    }
}
