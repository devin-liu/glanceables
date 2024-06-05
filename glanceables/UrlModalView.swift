import SwiftUI

var urlModal: some View {
    NavigationView {
        Form {
            Section(header: Text(isEditing ? "Edit URL" : "Add a new URL")) {
                TextField("Enter URL here", text: $urlString)
            }
            Section {
                Button("Save") {
                    if !urlString.isEmpty {
                        if isEditing, let index = selectedURLIndex {
                            urls[index] = urlString
                        } else {
                            urls.append(urlString)
                        }
                        resetModalState()
                    }
                }
            }
        }
        .navigationBarTitle(isEditing ? "Edit URL" : "New URL", displayMode: .inline)
        .navigationBarItems(trailing: Button("Cancel") {
            resetModalState()
        })
    }
}
