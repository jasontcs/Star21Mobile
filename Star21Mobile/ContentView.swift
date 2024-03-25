//
//  ContentView.swift
//  Star21Mobile
//
//  Created by Jason Tse on 4/11/2023.
//

import SwiftUI
import Factory
import Combine

struct ContentView: View {

    @ObservedObject private (set) var appRouting: AppRouting
    @Injected(\.appState) private (set) var appState
    @State private var showLoading = false

    var body: some View {
        LoadingView(isShowing: $showLoading) {
            AuthenticationView(viewModel: .init())
                .environmentObject(appRouting)
        }
        .onReceive(appState.$showLoading) { showLoading = $0 }
        .onChange(of: appRouting.ticketsPath) { path in
            print("ticketsPath: \(path)")
        }
        .onChange(of: appRouting.newTicketPath) { paths in
            let descriptions = paths.map {
                switch $0 {
                case .question(let question): return question.title
                case .submit: return "submit"
                }
            }
            print("newTicketPath: \(descriptions)")
        }
        .onChange(of: appRouting.tab) { tab in
            print("tab: \(tab)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(appRouting: .init())
    }
}
