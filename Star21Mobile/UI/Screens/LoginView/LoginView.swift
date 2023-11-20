//
//  LoginView.swift
//  Star21Mobile
//
//  Created by Jason Tse on 9/11/2023.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject private(set) var viewModel: ViewModel

    var body: some View {
        Button("Login") {
            viewModel.login()
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(viewModel: .init())
    }
}
