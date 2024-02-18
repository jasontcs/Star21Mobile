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
            NavigationStack(path: $appRouting.path) {
                AuthenticationView(viewModel: .init())
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .environmentObject(appRouting)
        }
        .onReceive(appState.$showLoading) { showLoading = $0 }
        .onChange(of: appRouting.path) { path in
            print(path)
        }
        .onChange(of: appRouting.tab) { tab in
            print(tab)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(appRouting: .init())
    }
}
