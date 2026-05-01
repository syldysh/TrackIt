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

    // Composition root: DI for app-wide services and ViewModels.
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let repository: any TaskRepositoryProtocol = TaskRepository()
        let notificationService: any NotificationServiceProtocol = LocalNotificationManager.shared
        let calendarSyncService: any CalendarSyncServiceProtocol = CalendarSyncService.shared
        let calendarVM   = CalendarViewModel(
            repository: repository,
            notificationService: notificationService,
            calendarSyncService: calendarSyncService
        )
        let inboxVM      = InboxViewModel(
            repository: repository,
            notificationService: notificationService,
            calendarSyncService: calendarSyncService
        )
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

    func sceneDidEnterBackground(_ scene: UIScene) {
        PersistenceController.shared.save()
    }
}
