import Defaults
import Foundation
import SwiftUI

struct PlayerQueueView: View {
    var sidebarQueue: Bool
    @Binding var fullScreen: Bool

    @FetchRequest(sortDescriptors: [.init(key: "watchedAt", ascending: false)])
    var watches: FetchedResults<Watch>

    @ObservedObject private var player = PlayerModel.shared

    @Default(.saveHistory) private var saveHistory

    var body: some View {
        List {
            Group {
                if player.playbackMode == .related {
                    autoplaying
                }
                playingNext
                if sidebarQueue {
                    related
                }
            }
            .listRowBackground(Color.clear)
            #if !os(iOS)
                .padding(.vertical, 5)
                .listRowInsets(EdgeInsets())
            #endif
            Color.clear.padding(.bottom, 50)
                .listRowBackground(Color.clear)
                .backport
                .listRowSeparator(false)
        }
        #if os(macOS)
        .listStyle(.inset)
        #elseif os(iOS)
        .listStyle(.grouped)
        .backport
        .scrollContentBackground(false)
        #else
        .listStyle(.plain)
        #endif
    }

    @ViewBuilder var autoplaying: some View {
        Section(header: autoplayingHeader) {
            if let item = player.autoplayItem {
                PlayerQueueRow(item: item, autoplay: true)
            } else {
                Group {
                    if player.currentItem.isNil {
                        Text("Not Playing")
                    } else {
                        Text("Finding something to play...")
                    }
                }
                .foregroundColor(.secondary)
            }
        }
    }

    var autoplayingHeader: some View {
        HStack {
            Text("Autoplaying Next")
            Spacer()
            Button {
                player.setRelatedAutoplayItem()
            } label: {
                Label("Find Other", systemImage: "arrow.triangle.2.circlepath.circle")
                    .labelStyle(.iconOnly)
            }
            .disabled(player.currentItem.isNil)
            .buttonStyle(.plain)
        }
    }

    var playingNext: some View {
        Section(header: Text("Queue")) {
            if player.queue.isEmpty {
                Text("Queue is empty")
                    .foregroundColor(.secondary)
            }

            ForEach(player.queue) { item in
                PlayerQueueRow(item: item, fullScreen: $fullScreen)
                    .onAppear {
                        player.loadQueueVideoDetails(item)
                    }
                    .contextMenu {
                        removeButton(item)
                        removeAllButton()

                        if let video = item.video {
                            VideoContextMenuView(video: video)
                        }
                    }
            }
        }
    }

    private var visibleWatches: [Watch] {
        watches.filter { $0.videoID != player.currentVideo?.videoID }
    }

    @ViewBuilder private var related: some View {
        if let related = player.currentVideo?.related, !related.isEmpty {
            Section(header: Text("Related")) {
                ForEach(related) { video in
                    PlayerQueueRow(item: PlayerQueueItem(video), fullScreen: $fullScreen)
                        .contextMenu {
                            VideoContextMenuView(video: video)
                        }
                        .id(video.videoID)
                }
            }
            .transaction { t in t.disablesAnimations = true }
        }
    }

    private func removeButton(_ item: PlayerQueueItem) -> some View {
        Button {
            player.remove(item)
        } label: {
            Label("Remove from the queue", systemImage: "trash")
        }
    }

    private func removeAllButton() -> some View {
        Button {
            player.removeQueueItems()
        } label: {
            Label("Clear the queue", systemImage: "trash.fill")
        }
    }
}

struct PlayerQueueView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            PlayerQueueView(sidebarQueue: true, fullScreen: .constant(true))
        }
        .injectFixtureEnvironmentObjects()
    }
}
