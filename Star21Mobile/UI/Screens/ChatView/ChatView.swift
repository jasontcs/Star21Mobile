//
//  ChatView.swift
//  Star21Mobile
//
//  Created by Jason Tse on 5/12/2023.
//

import SwiftUI

struct ChatView: View {

    @EnvironmentObject private var appRouting: AppRouting
    var body: some View {
        VStack {
            Button {
                appRouting.navigateToTicket(.id(8516))
            } label: {
                Text("GO")
            }
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
        .navigationTitle("Home")
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
