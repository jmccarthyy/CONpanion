//
//  User.swift
//  CONpanion
//
//  Created by jake mccarthy on 09/02/2024.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: firstName + lastName) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        
        //change to else -> display default image
        else {
            return ""
        }
    }
}
