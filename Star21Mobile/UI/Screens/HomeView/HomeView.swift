//
//  HomeView.swift
//  Star21Mobile
//
//  Created by Jason Tse on 2/12/2023.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: ViewModel

    let counters: [CounterArg] = [
        .init(iconName: "pencil", count: 5, title: "On-going", color: .red),
        .init(iconName: "checkmark.circle.fill", count: 12, title: "Completed", color: .teal),
        .init(iconName: "bookmark.fill", count: 3, title: "Saved", color: .black)
    ]

    let notifications: [NotificationEntity] = [
        .init(id: 1, title: "New Ticket", description: "new reply content, new reply content", content: "new reply content, new reply content", avatarUrl: nil, redirectUrl: nil, createdAt: Date(), updatedAt: Date(), status: .unread)
    ]

    var body: some View {
        VStack {
            List {
                HStack(spacing: 12) {
                    ForEach(counters) { counter in
                        Counter(counter)
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
                .frame(minWidth: 0, maxWidth: .infinity)
                Section(
                    header: HStack {
                        Text("New Activities")
                            .textCase(nil)
                            .font(.title)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Spacer()
                        Button("See all") {

                        }
                        .textCase(nil)
                    }
                ) {
                    ForEach(notifications) { notification in
                        NotificationTile(notification: notification)
                    }
                }
            }
            .refreshable {
            }
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
            .onSubmit(of: .search) {
            }
        }
        .listStyle(InsetGroupedListStyle())
        .toolbar {
            ToolbarItem(placement: .principal) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 32)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: .init())
    }
}
