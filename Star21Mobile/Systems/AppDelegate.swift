//
//  AppDelegate.swift
//  Star21Mobile
//
//  Created by Jason Tse on 6/11/2023.
//

import UIKit
import CoreData

import Swinject

final class AppDelegate: UIResponder, UIApplicationDelegate {

    lazy var systemEventsHandler: SystemEventsHandler? = {
        UIApplication.shared.connectedScenes
            .compactMap({ scene in scene.delegate as? SceneDelegate })
            .first?
            .systemEventsHandler
    }()

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

    }
}
