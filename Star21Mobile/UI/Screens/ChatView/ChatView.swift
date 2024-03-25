//
//  ChatView.swift
//  Star21Mobile
//
//  Created by Jason Tse on 5/12/2023.
//

import SwiftUI
import Factory
import CoreLocationUI

struct ChatView: View {

    @EnvironmentObject private var appRouting: AppRouting
//    @Injected(\.userInfoService) private var userInfo
//    @StateObject var userInfo = UserInfoRepository()
    @State var address: String?
    @State var ip: String?
    @State var model = ""
    @State var os = ""
    @State var version: String?

    var body: some View {
        VStack {
            Button {
                appRouting.navigateToTicket(.id(8516))
            } label: {
                Text("GO")
            }
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)

            if let address {
                Text(address)
            }

            if let ip {
                Text(ip)
            }

            Text(model)
            Text(os)
            if let version {
                Text(version)
            }

            LocationButton(.currentLocation) {
                Task {
//                    ip = userInfo.ipAddress
//                    model = userInfo.deviceModel
//                    os = userInfo.osVersion
//                    version = userInfo.appVersion
//                    (_, address) = await userInfo.getLocation()
                }
            }
        }
        .navigationTitle("Home")
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
