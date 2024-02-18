//
//  ProfileView.swift
//  Star21Mobile
//
//  Created by Jason Tse on 21/11/2023.
//

import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel: ViewModel

    var body: some View {
        Form {
            List {
                if let info = viewModel.session.value?.info {
                    InfoTile(title: "Name", value: info.name)
                    InfoTile(title: "Email", value: info.email)
                }
            }
            Section {
                Button("Logout", role: .destructive) {
                    Task {
                        await viewModel.logout()
                    }
                }
            }
        }
        .navigationTitle("Profile")
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: .init())
    }
}
