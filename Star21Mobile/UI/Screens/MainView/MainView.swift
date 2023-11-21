//
//  MainView.swift
//  Star21Mobile
//
//  Created by Jason Tse on 10/11/2023.
//

import SwiftUI

struct MainView: View {

    @State var selectedTab: BottomBarSelectedTab = .home

    var body: some View {
        NavigationView {
            VStack {
                if selectedTab == .home {
                    Text("Home")
                        .navigationTitle("Home")
                }
                if selectedTab == .search {
                    TicketsView(viewModel: .init())
                }
                if selectedTab == .plus {
                    NewTicketView(viewModel: .init())
                }
                if selectedTab == .notification {
                    Text("Chat")
                }
                if selectedTab == .profile {
                    ProfileView(viewModel: .init())
                }
                Spacer()
                BottomBar(selectedTab: $selectedTab)
            }
            .toolbar {
                HotlineButton()
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
