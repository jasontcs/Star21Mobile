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

    var appConfig: Factory<AppConfig> {
        self { DevAppConfig() }.singleton
    }

    var webRepository: Factory<ZendeskWebRepositoryProtocol> {

        let zendeskWebRepository = ZendeskWebRepository(
            session: session,
            baseURL: Container.shared.appConfig().zendeskApiBaseUrl
        )

        return self { zendeskWebRepository }.singleton
    }

    var userInfoRepository: Factory<UserInfoRepositoryProtocol> {
        self { UserInfoRepository() }.singleton
    }

    var appState: Factory<AppState> {
        self { AppState() }.singleton
    }

    var ticketsService: Factory<TicketsServiceProtocol> {
        self { TicketsService(
                appState: self.appState(),
                webRepository: self.webRepository(),
                userInfoRepository: self.userInfoRepository()
            )
        }.singleton
    }

    var authenticationService: Factory<AuthenticationServiceProtocol> {
        self { AuthenticationService(appState: self.appState()) }.singleton
    }
}
