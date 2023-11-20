//
//  AuthenticationView.swift
//  Star21Mobile
//
//  Created by Jason Tse on 9/11/2023.
//

import SwiftUI

struct AuthenticationView: View {
    @ObservedObject private(set) var viewModel: ViewModel

    var body: some View {
        if viewModel.authenticated {
            MainView()
        } else {
            LoginView(viewModel: .init())
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView(viewModel: .init())
    }
}
