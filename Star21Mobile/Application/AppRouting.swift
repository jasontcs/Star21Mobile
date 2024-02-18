//
//  AppRouting.swift
//  Star21Mobile
//
//  Created by Jason Tse on 24/11/2023.
//

import Combine
import SwiftUI

@MainActor
final class AppRouting: ObservableObject {

    init(tab: Tab = .home, path: NavigationPath = NavigationPath()) {
        self.tab = tab
        self.path = path
    }

    @Published var path: NavigationPath
    @Published var tab: Tab

    enum Tab {
        case home
        case tickets
        case newTicket
        case chat
        case profile
    }

    enum Ticket: Hashable {
        case entity(OnlineRequestEntity)
        case id(Int)
    }
}

extension AppRouting {
    func navigateToTicket(_ ticket: Ticket) {
        tab = .tickets
        path = NavigationPath([ticket])
    }
}
