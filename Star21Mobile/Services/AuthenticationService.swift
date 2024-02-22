//
//  AuthenticationService.swift
//  Star21Mobile
//
//  Created by Jason Tse on 8/11/2023.
//

import Combine
import Foundation

protocol AuthenticationServiceProtocol {
    func login(email: String) async
    func verifyEmail(code: String) async
    func resendEmailVerificationCode() async
    func login(mobile: Int) async
    func verifyMobile(code: String) async
    func resendMobileVerificationCode() async
    func logout() async
}

struct AuthenticationService: AuthenticationServiceProtocol {

    let appState: AppState

    func login(email: String) async {
        guard case .emailPending = appState.authenticationState else { return }
        print("login: \(email)")
        try? await Task.sleep(until: .now + .seconds(1), clock: .continuous)
        let token = "abcd1234"
        print("login token: \(token)")
        appState.authenticationState = .emailChallenge(token: token)
    }

    func verifyEmail(code: String) async {
        guard case let .emailChallenge(token) = appState.authenticationState else { return }
        print("verifyEmail: \(code) token:\(token)")
        try? await Task.sleep(until: .now + .seconds(1), clock: .continuous)
        appState.authenticationState = .mobilePending(token: token)
    }

    func resendEmailVerificationCode() async {
        guard case let .emailChallenge(token) = appState.authenticationState else { return }
        print("resendEmailVerificationCode: \(token)")
        try? await Task.sleep(until: .now + .seconds(1), clock: .continuous)
    }

    func login(mobile: Int) async {
        guard case let .mobilePending(token) = appState.authenticationState else { return }
        print("login mobile: \(mobile) token: \(token)")
        try? await Task.sleep(until: .now + .seconds(1), clock: .continuous)
        appState.authenticationState = .mobileChallenge(token: token)
    }

    func verifyMobile(code: String) async {
        guard case let .mobileChallenge(token) = appState.authenticationState else { return }
        print("verifyMobile: \(code) token: \(token)")
        try? await Task.sleep(until: .now + .seconds(5), clock: .continuous)
        appState.authenticationState = .complete
        appState.session = .withData(
            SessionEntity(
                uid: 8243630924559,
                token: "7eebc7c1c3ab23136d886a010ec490f0aa13d564bcc9de523f2db9c968fff9e2"
            )
        )
    }

    func resendMobileVerificationCode() async {
        guard case let .mobileChallenge(token) = appState.authenticationState else { return }
        print("resendMobileVerificationCode: \(token)")
        try? await Task.sleep(until: .now + .seconds(1), clock: .continuous)
    }

    func logout() async {
        guard case let .complete = appState.authenticationState else { return }
        try? await Task.sleep(until: .now + .seconds(1), clock: .continuous)
        appState.session = .nothing
        appState.authenticationState = .emailPending
    }
}
