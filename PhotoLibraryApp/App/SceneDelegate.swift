//
//  SceneDelegate.swift
//  PhotoLibraryApp
//
//  Created by Ana Dzebniauri on 07.09.25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = createTabbar()
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
    }
    
    private func createTabbar() -> UITabBarController {
        let tabbar = UITabBarController()
        UITabBar.appearance().tintColor = UIColor.systemBlue
        tabbar.viewControllers = [createNASAPhotosNC()]
        return tabbar
    }
    
    private func createNASAPhotosNC() -> UINavigationController {
        let nasaPhotosVC = NASAPhotosViewController()
        nasaPhotosVC.title = "NASA Photos"
        nasaPhotosVC.tabBarItem = UITabBarItem(title: "Photos", image: UIImage(systemName: "photo.on.rectangle"), tag: 0)
        return UINavigationController(rootViewController: nasaPhotosVC)
    }
}
