//
//  StatisticsAppInfoView.swift
//  TrackIt
//
//  Подпись версии приложения на экране прогресса.
//

import SwiftUI

struct StatisticsAppInfoView: View {
    let applicationInfo: AppInfo

    var body: some View {
        VStack(spacing: 4) {
            Text("\(applicationInfo.name) Version \(applicationInfo.version)")
                .font(.system(size: 13))
                .foregroundColor(Color(.secondaryLabel))
            Text("Made with love <3")
                .font(.system(size: 13))
                .foregroundColor(Color(.tertiaryLabel))
        }
        .padding(.vertical, 8)
    }
}
