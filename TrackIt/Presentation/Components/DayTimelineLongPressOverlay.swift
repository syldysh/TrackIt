//
//  DayTimelineLongPressOverlay.swift
//  TrackIt
//
//  Long press с координатой, который не забирает scroll у дневного таймлайна.
//

import SwiftUI
import UIKit

struct DayTimelineLongPressOverlay: UIViewRepresentable {
    let minimumDuration: TimeInterval
    let onBegan: (CGFloat) -> Void
    let onEnded: (CGFloat) -> Void
    let onCancelled: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true

        let recognizer = UILongPressGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleLongPress(_:))
        )
        recognizer.minimumPressDuration = minimumDuration
        recognizer.allowableMovement = Constants.allowableMovement
        recognizer.cancelsTouchesInView = false
        recognizer.delaysTouchesBegan = false
        recognizer.delaysTouchesEnded = false
        recognizer.delegate = context.coordinator
        view.addGestureRecognizer(recognizer)
        context.coordinator.recognizer = recognizer

        return view
    }

    func updateUIView(_ view: UIView, context: Context) {
        context.coordinator.parent = self
        context.coordinator.recognizer?.minimumPressDuration = minimumDuration
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var parent: DayTimelineLongPressOverlay
        weak var recognizer: UILongPressGestureRecognizer?

        init(parent: DayTimelineLongPressOverlay) {
            self.parent = parent
        }

        @objc func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
            let y = recognizer.location(in: recognizer.view).y

            switch recognizer.state {
            case .began:
                parent.onBegan(y)
            case .ended:
                parent.onEnded(y)
            case .cancelled, .failed:
                parent.onCancelled()
            default:
                break
            }
        }

        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            true
        }
    }

    private enum Constants {
        static let allowableMovement: CGFloat = 10
    }
}
