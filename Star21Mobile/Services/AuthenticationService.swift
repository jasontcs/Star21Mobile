//
//  AuthenticationService.swift
//  Star21Mobile
//
//  Created by Jason Tse on 8/11/2023.
//

import Combine
import Foundation

protocol AuthenticationServiceProtocol {
    func login()
}

struct AuthenticationService: AuthenticationServiceProtocol {
    let appState: AppState

    func login() {
        Task {
            appState.session = .withData(
                SessionEntity(
                    uid: 8243630924559,
                    token: "d7181450045b91457d8c43af5ac5e82fa16b9a6d64d5909bc5e336ff347bd79b"
                )
            )
        }
    }

}
