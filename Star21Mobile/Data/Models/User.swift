//
//  User.swift
//  Star21Mobile
//
//  Created by Jason Tse on 13/11/2023.
//

import Foundation

struct GetUserResponse: ResponseModel {
    let user: User
}

struct User: Codable, Hashable, Identifiable {
    let id: Int
    let name: String
    let email: String
    let tags: [String]
}
