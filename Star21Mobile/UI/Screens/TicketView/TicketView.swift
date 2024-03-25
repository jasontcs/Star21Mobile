//
//  TicketView.swift
//  Star21Mobile
//
//  Created by Jason Tse on 17/11/2023.
//

import SwiftUI

struct TicketView: View {

    @StateObject var viewModel: ViewModel

    let request: OnlineRequestEntity?
    let requestId: Int?

    init(viewModel: ViewModel, request: AppRouting.Tickets) {
        _viewModel = StateObject(wrappedValue: viewModel)
        switch request {
        case .entity(let request):
            self.request = request
            self.requestId = nil
        case .id(let requestId):
            self.request = nil
            self.requestId = requestId
        }
    }

    var body: some View {
        GeometryReader {  _ in
            if let request = viewModel.request.value {
                List {
                    Section {
                        FieldTile(title: "Created", value: "\(request.createdAt)")
                        FieldTile(title: "Last Activity", value: "\(request.updatedAt)")

                    }
                    Section {
                        FieldTile(title: "ID", value: "#\(request.id)")
                        FieldTile(title: "Status", value: "\(request.status)", isTag: true)
                        FieldTile(title: "Priority", value: "\(request.priority)")
                        ForEach(request.customFields, id: \.self) { field in
                            FieldTile(custom: field)
                        }
                    }

                    if let comments = request.comments {
                        Section {
                            ForEach(comments) { comment in
                                CommentTile(comment: comment)
                            }
                        } header: {
                            Text("Comments")
                        }
                    }
                }
                .navigationTitle(request.subject)
            }
        }
        .task {
            if let request {
                viewModel.setActiveRequest(request)
            }
            if let requestId {
                await viewModel.getActiveRequest(requestId)
            }
            await viewModel.fetchDetails()
        }
        .onDisappear {
            viewModel.setActiveRequest(nil)
        }
    }
}

struct TicketView_Previews: PreviewProvider {
    static var previews: some View {
        TicketView(viewModel: .init(), request: .entity(MockData.onlineTicket))
    }
}
