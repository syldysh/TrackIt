//
//  SceneDelegate.swift
//  TrackIt
//
//  Created by Сылдыс Шогжал on 09.02.2026.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // Composition root — единственное место, где собираются все зависимости.
    // Репозиторий создаётся один, ViewModel-и получают его через init (DI).
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let repository: any TaskRepositoryProtocol = TaskRepository()
        let calendarVM   = CalendarViewModel(repository: repository)
        let inboxVM      = InboxViewModel(repository: repository)
        let statisticsVM = StatisticsViewModel(repository: repository)

        let calendarVC = makeHosted(CalendarView().environmentObject(calendarVM),     title: "Календарь",    image: "calendar")
        let inboxVC    = makeHosted(InboxView().environmentObject(inboxVM),           title: "Планировщик",  image: "tray")
        let statsVC    = makeHosted(StatisticsView().environmentObject(statisticsVM), title: "Прогресс",     image: "chart.bar")

        let tab = UITabBarController()
        tab.viewControllers = [calendarVC, inboxVC, statsVC]

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        tab.tabBar.standardAppearance = appearance
        tab.tabBar.scrollEdgeAppearance = appearance
        tab.tabBar.tintColor = .systemBlue

        let w = UIWindow(windowScene: windowScene)
        w.rootViewController = tab
        // overrideUserInterfaceStyle не задаём — окно следует системной теме iOS
        w.makeKeyAndVisible()
        self.window = w
    }

    private func makeHosted<V: View>(_ view: V, title: String, image: String) -> UINavigationController {
        let host = UIHostingController(rootView: view)
        host.tabBarItem = UITabBarItem(title: title, image: UIImage(systemName: image), tag: 0)
        let nav = UINavigationController(rootViewController: host)
        nav.setNavigationBarHidden(true, animated: false)
        return nav
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        PersistenceController.shared.save()
    }


}

