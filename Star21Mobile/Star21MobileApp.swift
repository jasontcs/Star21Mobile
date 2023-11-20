//
//  Star21MobileApp.swift
//  Star21Mobile
//
//  Created by Jason Tse on 4/11/2023.
//

import SwiftUI

@main
struct Star21MobileApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: .init())
        }
    }
}
