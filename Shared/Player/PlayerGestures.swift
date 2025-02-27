import SwiftUI

struct PlayerGestures: View {
    private var player = PlayerModel.shared
    @ObservedObject private var model = PlayerControlsModel.shared

    var body: some View {
        HStack(spacing: 0) {
            gestureRectangle
                .tapRecognizer(
                    tapSensitivity: 0.2,
                    singleTapAction: { singleTapAction() },
                    doubleTapAction: {
                        player.backend.seek(relative: .secondsInDefaultTimescale(-10), seekType: .userInteracted)
                    },
                    anyTapAction: {
                        model.update()
                    }
                )

            gestureRectangle
                .tapRecognizer(
                    tapSensitivity: 0.2,
                    singleTapAction: { singleTapAction() },
                    doubleTapAction: {
                        player.backend.togglePlay()
                    }
                )

            gestureRectangle
                .tapRecognizer(
                    tapSensitivity: 0.2,
                    singleTapAction: { singleTapAction() },
                    doubleTapAction: {
                        player.backend.seek(relative: .secondsInDefaultTimescale(10), seekType: .userInteracted)
                    }
                )
        }
    }

    func singleTapAction() {
        if model.presentingOverlays {
            withAnimation(PlayerControls.animation) {
                model.hideOverlays()
            }
        } else {
            model.toggle()
        }
    }

    var gestureRectangle: some View {
        Color.clear
            .contentShape(Rectangle())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct PlayerGestures_Previews: PreviewProvider {
    static var previews: some View {
        PlayerGestures()
    }
}
