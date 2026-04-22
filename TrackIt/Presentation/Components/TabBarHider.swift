//
//  TabBarHider.swift
//  TrackIt
//
//  Скрывает / показывает системный UITabBar.
//  Используется при открытии модальных оверлеев (добавление задачи, режим планирования).
//

import SwiftUI

struct TabBarHider: UIViewRepresentable {
    let hide: Bool

    func makeUIView(context: Context) -> UIView { UIView() }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            var responder: UIResponder? = uiView
            while let r = responder {
                if let tc = r as? UITabBarController {
                    UIView.animate(withDuration: 0.2) {
                        tc.tabBar.alpha = hide ? 0 : 1
                    }
                    tc.tabBar.isUserInteractionEnabled = !hide
                    return
                }
                responder = r.next
            }
        }
    }
}
