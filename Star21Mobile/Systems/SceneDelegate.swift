//
//  SceneDelegate.swift
//  Star21Mobile
//
//  Created by Jason Tse on 6/11/2023.
//

import UIKit
import SwiftUI
import Factory

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var systemEventsHandler: SystemEventsHandler?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let container = Container.shared
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: ContentView(viewModel: .init()))
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}
