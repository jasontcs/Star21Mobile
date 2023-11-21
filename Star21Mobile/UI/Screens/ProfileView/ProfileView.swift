//
//  ProfileView.swift
//  Star21Mobile
//
//  Created by Jason Tse on 21/11/2023.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject private(set) var viewModel: ViewModel

    var body: some View {
        Button("Logout", role: .destructive) {
            Task {
                await viewModel.logout()
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: .init())
    }
}
