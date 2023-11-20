//
//  ContentView.swift
//  Star21Mobile
//
//  Created by Jason Tse on 4/11/2023.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject private(set) var viewModel: ViewModel

    var body: some View {
        AuthenticationView(viewModel: .init())
    }
}

extension ContentView {
    @MainActor
    final class ViewModel: ObservableObject {

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: .init())
    }
}
