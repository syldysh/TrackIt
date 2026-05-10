//
//  AdaptiveSheetContent.swift
//  TrackIt
//
//  Контент sheet, который растёт по содержимому и скроллится только при нехватке места.
//

import SwiftUI

struct AdaptiveSheetContent<Content: View>: View {
    let maxHeight: CGFloat
    @ViewBuilder let content: () -> Content
    @State private var contentHeight: CGFloat = 0

    private var visibleHeight: CGFloat? {
        guard contentHeight > 0 else { return nil }
        return min(contentHeight, maxHeight)
    }

    var body: some View {
        ScrollView(showsIndicators: contentHeight > maxHeight) {
            content()
                .background(contentHeightReader)
        }
        .frame(height: visibleHeight)
        .scrollDisabled(contentHeight <= maxHeight)
        .onPreferenceChange(AdaptiveSheetContentHeightKey.self) { height in
            contentHeight = height
        }
    }

    private var contentHeightReader: some View {
        GeometryReader { proxy in
            Color.clear.preference(key: AdaptiveSheetContentHeightKey.self, value: proxy.size.height)
        }
    }
}

private struct AdaptiveSheetContentHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
