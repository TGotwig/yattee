import Defaults
import SwiftUI

struct AccountsMenuView: View {
    @ObservedObject private var model = AccountsModel.shared

    @Default(.accounts) private var accounts
    @Default(.instances) private var instances
    @Default(.accountPickerDisplaysUsername) private var accountPickerDisplaysUsername
    @Default(.accountPickerDisplaysAnonymousAccounts) private var accountPickerDisplaysAnonymousAccounts

    @ViewBuilder var body: some View {
        if !instances.isEmpty {
            Menu {
                ForEach(allAccounts, id: \.id) { account in
                    Button {
                        model.setCurrent(account)
                    } label: {
                        HStack {
                            Text(accountButtonTitle(account: account))

                            Spacer()

                            if model.current == account {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    if !accountPickerDisplaysUsername || !(model.current?.isPublic ?? true) {
                        Image(systemName: "globe")
                    }

                    if accountPickerDisplaysUsername {
                        label
                            .labelStyle(.titleOnly)
                    }
                }
            }
            .disabled(allAccounts.isEmpty)
            .transaction { t in t.animation = .none }
        }
    }

    private var label: some View {
        Label(model.current?.description ?? "Select Account", systemImage: "globe")
    }

    private var allAccounts: [Account] {
        let anonymousAccounts = accountPickerDisplaysAnonymousAccounts ? instances.map(\.anonymousAccount) : []
        return accounts + anonymousAccounts + [model.publicAccount].compactMap { $0 }
    }

    private func accountButtonTitle(account: Account) -> String {
        account.isPublic ? account.description : "\(account.description) — \(account.instance.shortDescription)"
    }
}
