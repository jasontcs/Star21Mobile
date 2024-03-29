//
//  BottomBarView.swift
//  Star21Mobile
//
//  Created by Jason Tse on 10/11/2023.
//

import SwiftUI

struct BottomBar: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var selectedTab: AppRouting.Tab
    var body: some View {

        HStack(spacing: 10) {
            // Home
            Button {
                selectedTab = .home
            } label: {
                ZStack {
                    BottomBarButtonView(image: "house", text: "Home", isActive: selectedTab == .home)
                }
            }

            // Search
            Button {
                selectedTab = .tickets
            } label: {
                BottomBarButtonView(image: "magnifyingglass", text: "Search", isActive: selectedTab == .tickets)
            }

            Button {
                selectedTab = .newTicket

            } label: {
                VStack {
                    ZStack {
                        VStack(spacing: 3) {
                            RoundedRectangle(cornerRadius: 30)
                                .frame(width: 60, height: 60)
                                .foregroundColor(.purple)

                        }
                        VStack(spacing: 3) {
                            Image(systemName: "plus").font(.title).foregroundColor(.white)

                        }
                    }.padding(EdgeInsets(top: (UIDevice.isIPad ? -21 : -23), leading: 0, bottom: 0, trailing: 0))
                        Spacer()

                }
            }
            // Notification
            Button {
                selectedTab = .chat
            } label: {
                BottomBarButtonView(image: "ellipsis.message", text: "Chat", isActive: selectedTab == .chat)
            }
            // Profile
            Button {
                selectedTab = .profile
            } label: {

                BottomBarButtonView(image: "person", text: "Profile", isActive: selectedTab == .profile)
            }
        }
        .frame(height: 40)
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.5 : 0.2), radius: 10, x: 0, y: 0)

    }
}

struct BottomBar_Previews: PreviewProvider {
    static var previews: some View {
        BottomBar(selectedTab: .constant(.newTicket))
    }
}

struct BottomBarButtonView: View {

    var image: String
    var text: String
    var isActive: Bool

    var body: some View {
        HStack(spacing: 10) {
                GeometryReader {
                    _ in
                    VStack(spacing: UIDevice.isIPad ? 6 : 3) {
                        Rectangle()
                            .frame(height: 0)
                        Image(systemName: image)
                            .resizable()
                            .frame(width: UIDevice.isIPad ? 30 : 24, height: UIDevice.isIPad ? 30 : 24)
                            .foregroundColor(isActive ? .purple : .gray)
                        Text(text)
                            .font(.caption)
                            .foregroundColor(isActive ? .purple : .gray)
                    }
                }

        }
    }
}

extension UIDevice {
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    static var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
}
