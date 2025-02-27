import Foundation
import SDWebImageSwiftUI
import SwiftUI

struct ChaptersView: View {
    @ObservedObject private var player = PlayerModel.shared

    var body: some View {
        if let chapters = player.currentVideo?.chapters, !chapters.isEmpty {
            List {
                Section(header: Text("Chapters")) {
                    ForEach(chapters) { chapter in
                        ChapterView(chapter: chapter)
                    }
                    Color.clear.frame(height: 50)
                        .listRowBackground(Color.clear)
                        .backport
                        .listRowSeparator(false)
                }
                .listRowBackground(Color.clear)
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
        } else {
            NoCommentsView(text: "No chapters information available".localized(), systemImage: "xmark.circle.fill")
        }
    }
}

struct ChaptersView_Previews: PreviewProvider {
    static var previews: some View {
        ChaptersView()
            .injectFixtureEnvironmentObjects()
    }
}
