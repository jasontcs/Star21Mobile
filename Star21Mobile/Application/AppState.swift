//
//  AppState.swift
//  Star21Mobile
//
//  Created by Jason Tse on 6/11/2023.
//

import SwiftUI
import Combine

final class AppState {
    @Published var session: AsyncSnapshot<SessionEntity> = .nothing
    @Published var activeRequest: AsyncSnapshot<any RequestEntity> = .nothing
    @Published var uploadAttachments: [UploadAttachmentEntity] = []
    @Published var requests: AsyncSnapshot<[OnlineRequestEntity]> = .nothing
    @Published var ticketForms: AsyncSnapshot<[TicketFormEntity]> = .nothing
    @Published var showLoading = false
    @Published var authenticationState: AuthenticationState = .mobileChallenge(token: "") // fast
}
