import SwiftUI

struct FriendPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var friendVM = FriendViewModel()   // reuse existing
    @Binding var selection: [FriendProfile]

    var body: some View {
        NavigationStack {
            List(friendVM.friends) { friend in
                MultipleSelectionRow(
                    title: friend.full_name ?? friend.username,
                    isSelected: selection.contains(where: { $0.id == friend.id })
                ) {
                    if let idx = selection.firstIndex(where: { $0.id == friend.id }) {
                        selection.remove(at: idx)
                    } else {
                        selection.append(friend)
                    }
                }
            }
            .navigationTitle("Select friends")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .task { await friendVM.refresh() }
        }
    }
}

private struct MultipleSelectionRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title).foregroundColor(.primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark").foregroundColor(.accentColor)
                }
            }
        }
    }
}
