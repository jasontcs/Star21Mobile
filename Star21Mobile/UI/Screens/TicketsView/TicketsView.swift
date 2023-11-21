//
//  TicketsView.swift
//  Star21Mobile
//
//  Created by Jason Tse on 4/11/2023.
//

import SwiftUI

struct TicketsView: View {
    @ObservedObject private(set) var viewModel: ViewModel

    var body: some View {
        VStack {
            if let tickets = viewModel.tickets.value {
                List {
                    Section {
                        Picker("Status", selection: $viewModel.searchStatus) {
                            Text("Any")
                                .tag(Optional<RequestStatus>.none)
                            ForEach(RequestStatus.allCases, id: \.rawValue) { status in
                                Text(status.rawValue)
                                    .tag(Optional(status))
                            }
                        }
                        .onChange(of: viewModel.searchStatus) { _ in
                            Task { await viewModel.fetchTickets() }
                        }
                    }
                    ForEach(tickets) { ticket in
                        NavigationLink(destination: TicketView(viewModel: .init(), request: ticket)) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(ticket.subject)
                                        .lineLimit(1)
                                    Text(ticket.description)
                                        .foregroundColor(.gray)
                                        .lineLimit(1)
                                }
                                Spacer()
                                Text(ticket.status.rawValue)
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .refreshable {
                    await viewModel.fetchTickets()
                }
                .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
                .onSubmit(of: .search) {
                    Task { await viewModel.fetchTickets() }
                }
            } else {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
        }
        .navigationTitle("Tickets")
        .frame(maxHeight: .infinity)
        .task {
            Task { await viewModel.fetchTickets() }
        }
    }
}

struct TicketsView_Previews: PreviewProvider {
    static var previews: some View {
        TicketsView(viewModel: .init())
    }
}
