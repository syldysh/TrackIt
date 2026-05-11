//
//  AppInfoProvider.swift
//  TrackIt
//
//  Собирает базовую информацию о приложении из Bundle.
//

import Foundation

struct AppInfo {
    let name: String
    let version: String
    let author: String
}

struct AppInfoProvider {
    static func current(bundle: Bundle = .main) -> AppInfo {
        AppInfo(
            name: bundle.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "TrackIt",
            version: bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Неизвестно",
            author: "Сылдыс Шогжал"
        )
    }
}
