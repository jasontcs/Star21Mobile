//
//  AppContainer.swift
//  Star21Mobile
//
//  Created by Jason Tse on 8/11/2023.
//

import Factory
import Foundation

private let session = {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.timeoutIntervalForRequest = 60
    configuration.timeoutIntervalForResource = 120
    configuration.waitsForConnectivity = true
    configuration.httpMaximumConnectionsPerHost = 5
    configuration.urlCache = .shared
    return URLSession(configuration: configuration)
}()

extension Container {

    var webRepository: Factory<ZendeskWebRepositoryProtocol> {

        let zendeskWebRepository = ZendeskWebRepository(
            session: session,
            baseURL: "https://star21cloud1679352336.zendesk.com/api/v2/"
        )

        return self { zendeskWebRepository }
    }

    var appState: Factory<AppState> {
        self { AppState() }.shared
    }

    var ticketsService: Factory<TicketsServiceProtocol> {
        self { TicketsService(appState: self.appState(), webRepository: self.webRepository()) }.shared
    }

    var authenticationService: Factory<AuthenticationServiceProtocol> {
        self { AuthenticationService(appState: self.appState()) }.shared
    }
}
