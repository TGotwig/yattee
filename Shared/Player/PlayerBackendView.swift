import SwiftUI

struct PlayerBackendView: View {
    #if os(iOS)
        @Environment(\.verticalSizeClass) private var verticalSizeClass
    #endif
    @ObservedObject private var player = PlayerModel.shared

    var body: some View {
        ZStack(alignment: .top) {
            Group {
                switch player.activeBackend {
                case .mpv:
                    player.mpvPlayerView
                case .appleAVPlayer:
                    player.avPlayerView
                }
            }
            .overlay(GeometryReader { proxy in
                Color.clear
                    .onAppear { player.playerSize = proxy.size }
                    .onChange(of: proxy.size) { _ in player.playerSize = proxy.size }
                    .onChange(of: player.controls.presentingOverlays) { _ in player.playerSize = proxy.size }
            })
            #if os(iOS)
            .padding(.top, player.playingFullScreen && verticalSizeClass == .regular ? 20 : 0)
            #endif

            #if !os(tvOS)
                PlayerGestures()
                PlayerControls()
                #if os(iOS)
                    .padding(.top, controlsTopPadding)
                    .padding(.bottom, controlsBottomPadding)
                #endif
            #else
                hiddenControlsButton
            #endif
        }
        #if os(iOS)
        .statusBarHidden(player.playingFullScreen)
        #endif
    }

    #if os(iOS)
        var controlsTopPadding: Double {
            guard player.playingFullScreen else { return 0 }

            if UIDevice.current.userInterfaceIdiom != .pad {
                return verticalSizeClass == .compact ? SafeArea.insets.top : 0
            } else {
                return SafeArea.insets.top.isZero ? SafeArea.insets.bottom : SafeArea.insets.top
            }
        }

        var controlsBottomPadding: Double {
            guard player.playingFullScreen else { return 0 }

            if UIDevice.current.userInterfaceIdiom != .pad {
                return player.playingFullScreen && verticalSizeClass == .compact ? SafeArea.insets.bottom : 0
            } else {
                return player.playingFullScreen ? SafeArea.insets.bottom : 0
            }
        }
    #endif

    #if os(tvOS)
        private var hiddenControlsButton: some View {
            VStack {
                Button {
                    player.controls.show()
                } label: {
                    EmptyView()
                }
                .offset(y: -100)
                .buttonStyle(.plain)
                .background(Color.clear)
                .foregroundColor(.clear)
            }
        }
    #endif
}

struct PlayerBackendView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerBackendView()
            .injectFixtureEnvironmentObjects()
    }
}
