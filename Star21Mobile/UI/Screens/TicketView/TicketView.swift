//
//  TicketView.swift
//  Star21Mobile
//
//  Created by Jason Tse on 17/11/2023.
//

import SwiftUI

struct TicketView: View {

    @ObservedObject private(set) var viewModel: ViewModel

    let request: OnlineRequestEntity

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
            viewModel.setActiveRequest(request)
            await viewModel.fetchDetails()
        }
    }
}

struct TicketView_Previews: PreviewProvider {
    static var previews: some View {
        TicketView(viewModel: .init(), request: MockData.onlineTicket)
    }
}
