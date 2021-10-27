//
// SceneDelegate.swift
//
// Created by JechtSh0t on 10/26/21.
// Copyright © 2021 Brook Street Games LLC. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = scene as? UIWindowScene else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = TranslationViewController()
        window?.makeKeyAndVisible()
    }
}
