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
                    TicketsView(viewModel: .init())
                }
                if selectedTab == .search {
                    Text("Search")
                }
                if selectedTab == .plus {
                    NewTicketView(viewModel: .init())
                }
                if selectedTab == .notification {
                    Text("Notification")
                }
                if selectedTab == .profile {
                    Text("Profile")
                }
                Spacer()
                BottomBar(selectedTab: $selectedTab)
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
