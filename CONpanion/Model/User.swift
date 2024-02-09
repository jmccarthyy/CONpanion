//
//  User.swift
//  CONpanion
//
//  Created by jake mccarthy on 09/02/2024.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let fullName: String
    let email: String
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullName) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        
        //change to else -> display default image
        else {
            return ""
        }
    }
}

extension User {
    static var MOCK_USER = User(id: NSUUID().uuidString, fullName: "Jake McCarthy", email: "name@example.com")
}
