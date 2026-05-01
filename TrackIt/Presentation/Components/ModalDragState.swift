import SwiftUI

final class ModalDragState: ObservableObject {
    @Published private(set) var offset: CGFloat = 0

    private let dismissDistance: CGFloat
    private let predictedDismissDistance: CGFloat
    private let dimFadeDistance: CGFloat
    private let dismissalOffset: CGFloat

    init(
        dismissDistance: CGFloat = 120,
        predictedDismissDistance: CGFloat = 220,
        dimFadeDistance: CGFloat = 260,
        dismissalOffset: CGFloat = UIScreen.main.bounds.height * 0.65
    ) {
        self.dismissDistance = dismissDistance
        self.predictedDismissDistance = predictedDismissDistance
        self.dimFadeDistance = dimFadeDistance
        self.dismissalOffset = dismissalOffset
    }

    var dimOpacityMultiplier: CGFloat {
        1 - min(max(offset / dimFadeDistance, 0), 1)
    }

    func reset() {
        setOffset(0)
    }

    func dragGesture(onDismiss: @escaping () -> Void) -> some Gesture {
        DragGesture(minimumDistance: 6)
            .onChanged { [weak self] value in
                guard let self else { return }
                setOffset(max(value.translation.height, 0))
            }
            .onEnded { [weak self] value in
                guard let self else { return }
                let distance = max(value.translation.height, 0)
                let predictedDistance = max(value.predictedEndTranslation.height, 0)

                if distance > dismissDistance || predictedDistance > predictedDismissDistance {
                    withAnimation(.easeOut(duration: 0.18)) {
                        self.offset = max(distance, self.dismissalOffset)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
                        onDismiss()
                    }
                } else {
                    withAnimation(.sheetSpring) {
                        self.offset = 0
                    }
                }
            }
    }

    private func setOffset(_ value: CGFloat) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            offset = value
        }
    }
}

struct ModalDimBackground: View {
    @ObservedObject var dragState: ModalDragState
    let baseOpacity: CGFloat
    let onTap: () -> Void

    var body: some View {
        Color.black
            .opacity(Double(baseOpacity))
            .background(.ultraThinMaterial)
            .opacity(Double(dragState.dimOpacityMultiplier))
            .ignoresSafeArea()
            .contentShape(Rectangle())
            .onTapGesture(perform: onTap)
    }
}

struct ModalDragHandle<Content: View>: View {
    @ObservedObject var dragState: ModalDragState
    let onDismiss: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(.systemGray4))
                .frame(width: dragState.offset > 0 ? 46 : 40, height: 4)
                .padding(.top, 10)
                .padding(.bottom, 4)
                .animation(.snappySpring, value: dragState.offset > 0)

            content()
        }
        .contentShape(Rectangle())
        .gesture(dragState.dragGesture(onDismiss: onDismiss))
    }
}
