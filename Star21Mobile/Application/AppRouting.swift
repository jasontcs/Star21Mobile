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

    init(
        tab: Tab = .home,
        homePath: [Home] = [],
        ticketsPath: [Tickets] = [],
        newTicketPath: [NewTicket] = [],
        chatPath: [Chat] = [],
        profilePath: [Profile] = []
    ) {
        self.tab = tab
        self.homePath = homePath
        self.ticketsPath = ticketsPath
        self.newTicketPath = newTicketPath
        self.chatPath = chatPath
        self.profilePath = profilePath
    }

    @Published var tab: Tab {
        didSet {
            ticketsPath = []
            newTicketPath = []
        }
    }
    @Published var homePath: [Home]
    @Published var ticketsPath: [Tickets]
    @Published var newTicketPath: [NewTicket]
    @Published var chatPath: [Chat]
    @Published var profilePath: [Profile]

    enum Tab {
        case home
        case tickets
        case newTicket
        case chat
        case profile
    }

    enum Home: Hashable {

    }

    enum Tickets: Hashable {
        case entity(OnlineRequestEntity)
        case id(Int)
    }

    enum NewTicket: Hashable {
        case question(TicketFieldEntity)
        case submit
    }

    enum Chat: Hashable {

    }

    enum Profile: Hashable {

    }
}

extension AppRouting {
    func navigateToTicket(_ ticket: Tickets) {
        tab = .tickets
        ticketsPath = [ticket]
    }
}
